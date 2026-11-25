#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
把一批 Markdown 导入 VitePress 站点内容目录，并做「会被 Vue 编译」的语法兼容处理。

设计原则：只做机械且易错的转换，不做信息架构判断（分组 / slug / 菜单文案由人/Agent 决定）。

主要能力
  1) 按 map 复制到 <site-content>/<group>/<dst>
  2) 同批次内部互链自动改写为新相对路径
  3) 批次外的 ../ 相对链接降级为纯文本（避免死链）
  4) 行内代码里的 {{ ... }} -> <code v-pre>...</code>
  5) 裸泛型 ARRAY<STRING> / 裸标签 <ts> -> 反引号包裹
  6) 逐文件自检，发现阻断级问题非 0 退出

用法
  # 1. 先看自动建议的 slug（不写任何文件）
  python3 import_docs.py --src <源目录> --site-content <内容根> --group <分组名>

  # 2. 写映射并预演
  python3 import_docs.py --src ... --site-content ... --group <分组名> --map m.json --dry-run

  # 3. 正式执行
  python3 import_docs.py --src ... --site-content ... --group <分组名> --map m.json
"""
from __future__ import annotations

import argparse
import json
import os
import re
import signal
import sys
import urllib.parse

if hasattr(signal, 'SIGPIPE'):      # 允许 `| head` 之类提前关闭管道而不报 traceback
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)

# ---------------------------------------------------------------- 正则（已按坑验证）

FENCE = re.compile(r'^\s*(?:>\s*)*(```|~~~)')
CODE = re.compile(r'(`+)(?!`)(.+?)(?<!`)\1(?!`)')
# 泛型（ARRAY<STRING>）与裸标签（<ts>、<doc_id>）必须在同一次扫描里决定，
# 否则先包泛型再包标签会套成 `` `ARRAY`<STRING>`` ``
GEN_TAG = re.compile(
    r'(?<![`\w])([A-Z][A-Z0-9_]*(?:<[A-Z0-9_, ]+>)+)(?!`)'
    r'|</?([A-Za-z][A-Za-z0-9]*)(?:\s[^<>]*)?/?>'
)
WHITELIST = {
    'a', 'br', 'code', 'div', 'span', 'img', 'strong', 'em', 'p', 'ul', 'li',
    'table', 'thead', 'tbody', 'tr', 'td', 'th', 'sup', 'sub', 'details',
    'summary', 'hr', 'b', 'i', 'kbd', 'pre', 'blockquote',
}
# 同时拿到链接文案与目标：批次外 ../ 要降级成纯文本，必须能取到文案；
# (?<!!) 排除图片 ![](x.png)，图片路径不在改写范围内
LINK = re.compile(r'(?<!!)\[([^\]]+)\]\(([^)]+)\)')
HEADING = re.compile(r'^#\s+(.+)$', re.M)
INTERP = re.compile(r'\{\{(.+?)\}\}', re.S)

BLOCKING_TAG_HINT = 'Vue 会把裸 <Tag> 当 HTML 标签，构建报 Element is missing end tag'
VOID = {'br', 'hr', 'img', 'input', 'meta', 'link'}


# ---------------------------------------------------------------- 文本转换

def fix_text(seg: str, counter: dict) -> str:
    """纯文本段：泛型/裸标签用行内代码包起来；裸 {{ }} 用 <code v-pre> 包起来。"""
    def rep(m: re.Match) -> str:
        if m.group(1):
            counter['generic'] += 1
            return '`%s`' % m.group(1)
        if m.group(2).lower() in WHITELIST:
            return m.group(0)
        counter['tag'] += 1
        return '`%s`' % m.group(0)

    seg = GEN_TAG.sub(rep, seg)

    def rep_interp(m: re.Match) -> str:
        counter['vpre'] += 1
        return '<code v-pre>{{%s}}</code>' % m.group(1)

    return INTERP.sub(rep_interp, seg)


def fix_line(line: str, counter: dict) -> str:
    """行内代码里的 {{ }} 会被 Vue 当插值：换成 <code v-pre>。"""
    out, pos = [], 0
    for m in CODE.finditer(line):
        out.append(fix_text(line[pos:m.start()], counter))
        inner = m.group(2)
        if '{{' in inner:
            counter['vpre'] += 1
            out.append('<code v-pre>%s</code>' % inner)
        else:
            out.append(m.group(0))
        pos = m.end()
    out.append(fix_text(line[pos:], counter))
    return ''.join(out)


def rewrite_links(line: str, dst_rel: str, basename_map: dict, counter: dict) -> str:
    """同批次内部互链 -> 新相对路径；批次外 ../ -> 纯文本。

    改写与降级必须在同一个分支里判定：改写后的站内链接本身可能以 ../ 开头，
    若先改写再用"以 ../ 开头"去降级，会把刚修好的内链打回纯文本。
    """
    def rep(m: re.Match) -> str:
        text, raw = m.group(1), m.group(2).strip()
        if raw.startswith(('http://', 'https://', 'mailto:', '#')):
            return m.group(0)
        target = raw
        if target.startswith('<') and target.endswith('>'):
            target = target[1:-1]
        path_only = target.split(' ')[0]
        unquoted = urllib.parse.unquote(path_only)
        base = os.path.basename(unquoted)
        if unquoted.endswith('.md') and base in basename_map:
            new_rel = os.path.relpath(basename_map[base], os.path.dirname(dst_rel) or '.')
            if not new_rel.startswith('.'):
                new_rel = './' + new_rel
            counter['relink'] += 1
            return '[%s](%s)' % (text, new_rel)
        if path_only.startswith('../'):
            counter['demote'] += 1
            return text
        return m.group(0)

    return LINK.sub(rep, line)


def convert(text: str, dst_rel: str, basename_map: dict, overrides: dict) -> tuple[str, dict]:
    counter = {'relink': 0, 'demote': 0, 'vpre': 0, 'generic': 0, 'tag': 0}
    out, in_fence = [], False
    for line in text.split('\n'):
        if FENCE.match(line):
            in_fence = not in_fence
            out.append(line)
            continue
        if in_fence:
            out.append(line)
            continue
        line = rewrite_links(line, dst_rel, basename_map, counter)
        for old, new in overrides.items():
            if '](%s)' % old in line:
                line = line.replace('](%s)' % old, '](%s)' % new)
                counter['relink'] += 1
        out.append(fix_line(line, counter))
    return '\n'.join(out), counter


# ---------------------------------------------------------------- 自检

def scan_issues(text: str) -> list[str]:
    """报告会被 Vue 编译或导致死链的可疑行。"""
    issues, in_fence = [], False
    open_cnt, close_cnt = {}, {}
    for i, line in enumerate(text.split('\n'), 1):
        if FENCE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        # 1) 行内代码里残留 {{ （未被 <code v-pre> 覆盖）
        for m in CODE.finditer(line):
            if '{{' in m.group(2):
                issues.append('L%d 行内代码残留 {{ }}(%s)' % (i, BLOCKING_TAG_HINT.replace('裸 <Tag>', '{{ }}')))
        stripped = CODE.sub('', line)
        stripped = LINK.sub('', stripped)
        stripped = re.sub(r'<code v-pre>.*?</code>', '', stripped)   # 已处理过的插值
        # 1b) 正文（行内代码之外）残留 {{ }}：同样会被 Vue 当插值
        if '{{' in stripped:
            issues.append('L%d 正文残留 {{ }}（需 <code v-pre>）' % i)
        # 2) 裸标签 / 裸泛型
        for m in GEN_TAG.finditer(stripped):
            if m.group(1):
                issues.append('L%d 裸泛型 %s（需反引号）' % (i, m.group(1)[:40]))
            elif m.group(2).lower() not in WHITELIST:
                issues.append('L%d 裸标签 <%s>（需反引号）' % (i, m.group(2)))

        # 3) 白名单标签的开闭配平（只警告）：<div> 忘闭合同样会炸构建
        for m in re.finditer(r'<(/?)([A-Za-z][A-Za-z0-9]*)', stripped):
            tag = m.group(2).lower()
            if tag in VOID or tag not in WHITELIST:
                continue
            (close_cnt if m.group(1) else open_cnt)[tag] = \
                (close_cnt if m.group(1) else open_cnt).get(tag, 0) + 1

    for tag in sorted(set(open_cnt) | set(close_cnt)):
        if open_cnt.get(tag, 0) != close_cnt.get(tag, 0):
            issues.append('标签 <%s> 开 %d / 闭 %d 不平衡（警告，确认是否漏闭合）'
                          % (tag, open_cnt.get(tag, 0), close_cnt.get(tag, 0)))
    return issues


# ---------------------------------------------------------------- 主流程

def suggest_map(src: str) -> dict[str, str]:
    """按文件名里的 ASCII 片段猜 slug（仅供起步，需人工确认）。"""
    mapping, used = {}, set()
    for name in sorted(os.listdir(src)):
        if not name.endswith('.md') or name == 'README.md':
            continue
        stem = os.path.splitext(name)[0]
        ascii_part = re.sub(r'[^A-Za-z0-9]+', '-', stem).strip('-').lower()
        ascii_part = re.sub(r'-{2,}', '-', ascii_part) or 'doc'
        slug, n = ascii_part, 2
        while slug in used:
            slug = '%s-%d' % (ascii_part, n)
            n += 1
        used.add(slug)
        mapping[name] = slug + '.md'
    return mapping


def main() -> int:
    ap = argparse.ArgumentParser(description='把 Markdown 目录导入 VitePress 内容目录')
    ap.add_argument('--src', required=True, help='源目录（含 md）')
    ap.add_argument('--site-content', required=True, help='VitePress 内容根（含 .vitepress 的目录），如 <站点根>/content')
    ap.add_argument('--group', required=True, help='站内目标分组目录名，如 guide')
    ap.add_argument('--map', help='映射 JSON：{源文件名: 组内相对路径}；缺省只打印建议稿')
    ap.add_argument('--suggest-out', help='把建议稿写到指定路径（缺省只打印到标准输出）')
    ap.add_argument('--link-overrides', help='额外链接改写 JSON：{旧链接目标: 新目标}')
    ap.add_argument('--dry-run', action='store_true', help='只打印，不写文件')
    args = ap.parse_args()

    src = args.src.rstrip('/')
    content = args.site_content.rstrip('/')
    if not os.path.isdir(src):
        print('✗ 源目录不存在: %s' % src, file=sys.stderr)
        return 1
    if not os.path.isdir(os.path.join(content, '.vitepress')):
        print('✗ %s 下没有 .vitepress，--site-content 应指向 VitePress 内容根' % content, file=sys.stderr)
        return 1

    if not args.map:
        sugg = suggest_map(src)
        if args.suggest_out:
            with open(args.suggest_out, 'w', encoding='utf-8') as fh:
                json.dump(sugg, fh, ensure_ascii=False, indent=2)
            print('未提供 --map。建议稿已写入 %s（%d 条），slug 需人工按语义调整后再执行：'
                  % (args.suggest_out, len(sugg)))
        else:
            print('未提供 --map。下面是建议稿（%d 条，未写任何文件），slug 需人工按语义调整后再执行：'
                  % len(sugg))
        for k, v in sugg.items():
            print('  %-46s -> %s/%s' % (k, args.group, v))
        print('\n可直接复制到 --map 文件（值为相对 --group 的路径，不要带组名前缀）：')
        print(json.dumps(sugg, ensure_ascii=False, indent=2))
        return 0

    with open(args.map, encoding='utf-8') as fh:
        mapping = json.load(fh)
    overrides = {}
    if args.link_overrides:
        with open(args.link_overrides, encoding='utf-8') as fh:
            overrides = json.load(fh)

    missing = [s for s in mapping if not os.path.isfile(os.path.join(src, s))]
    if missing:
        print('✗ 源文件缺失: %s' % ', '.join(missing), file=sys.stderr)
        return 1

    basename_map = {os.path.basename(s): d.lstrip('./') for s, d in mapping.items()}
    rows, problems = [], 0

    for name, dst_rel in mapping.items():
        dst_rel = dst_rel.lstrip('./')
        out_path = os.path.join(content, args.group, dst_rel)
        text = open(os.path.join(src, name), encoding='utf-8').read()
        new_text, stat = convert(text, dst_rel, basename_map, overrides)
        h1 = HEADING.search(new_text)
        issues = scan_issues(new_text)
        blocking = [i for i in issues if '裸' in i or '残留' in i]
        problems += len(blocking)

        rows.append({
            'src': name,
            'dst': '%s/%s' % (args.group, dst_rel),
            'bytes': len(new_text.encode('utf-8')),
            'h1': bool(h1),
            'stat': stat,
            'issues': issues,
        })

        if not args.dry_run:
            os.makedirs(os.path.dirname(out_path), exist_ok=True)
            with open(out_path, 'w', encoding='utf-8') as fh:
                fh.write(new_text)

    print('%s %d 篇 -> %s/%s/' % ('[dry-run] 将导入' if args.dry_run else '已导入', len(rows), content, args.group))
    print('%-46s %8s %3s %3s %3s %3s %3s  %s' % ('源文件', '字节', 'vpr', 'gen', 'tag', 'rlk', 'dmt', 'H1'))
    for r in rows:
        s = r['stat']
        print('%-46s %8d %3d %3d %3d %3d %3d  %s' % (
            r['src'][:46], r['bytes'], s['vpre'], s['generic'], s['tag'],
            s['relink'], s['demote'], 'OK' if r['h1'] else '**无 H1，补 frontmatter title**'))

    no_h1 = [r['dst'] for r in rows if not r['h1']]
    if no_h1:
        print('\n⚠ 无 H1（建议补 frontmatter title）：')
        for d in no_h1:
            print('  - %s' % d)

    if problems:
        print('\n✗ 阻断级问题 %d 处（构建会失败）：' % problems)
        for r in rows:
            for i in r['issues']:
                if '裸' in i or '残留' in i:
                    print('  %s  %s' % (r['dst'], i))
        return 2

    warns = [(r['dst'], i) for r in rows for i in r['issues']
             if '裸' not in i and '残留' not in i]
    if warns:
        print('\n⚠ 非阻断提醒（人工确认）：')
        for d, i in warns:
            print('  %s  %s' % (d, i))

    print('\n下一步：写分组总览 index.md -> 改 .vitepress/site.ts 的 nav/sidebar -> 首页入口 -> pnpm build 逐页比对')
    return 0


if __name__ == '__main__':
    sys.exit(main())
