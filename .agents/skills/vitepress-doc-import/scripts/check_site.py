#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
导入后的站点校验：站内链接是否都有对应页面、sidebar 是否都指向真实页面、
构建产物是否逐页齐全。不依赖任何第三方库。

用法
  python3 check_site.py --site-content <站点根>/content --group <分组名> \
      --site-ts <站点根>/content/.vitepress/site.ts

退出码：0 全通过；1 有缺失（构建/点击都会出问题）
"""
from __future__ import annotations

import argparse
import os
import re
import sys
import urllib.parse
from glob import glob

LINK = re.compile(r'\]\(([^)]+)\)')
SIDEBAR_LINK = re.compile(r"link:\s*'([^']+)'")
SKIP_PREFIX = ('http://', 'https://', 'mailto:', '#', 'tel:')
# 静态资源走 public/，没有对应 md，不属于站内页面链接
ASSET_EXT = {
    '.svg', '.png', '.jpg', '.jpeg', '.gif', '.webp', '.ico', '.bmp', '.avif',
    '.pdf', '.zip', '.gz', '.txt', '.json', '.xml', '.js', '.css',
    '.mp4', '.webm', '.mp3', '.woff', '.woff2', '.ttf',
}


def is_asset(target: str) -> bool:
    """判断链接是否指向静态资源（按扩展名）。"""
    t = target.strip().strip('<>').split(' ')[0].split('#')[0].split('?')[0]
    return os.path.splitext(t)[1].lower() in ASSET_EXT


def resolve(content: str, target: str, base_dir: str) -> str | None:
    """把链接目标解析成内容目录下的文件路径；解析不出返回 None。"""
    t = target.strip()
    if t.startswith('<') and t.endswith('>'):
        t = t[1:-1]
    t = t.split(' ')[0].split('#')[0].split('?')[0]
    if not t or t in ('/', ''):
        return os.path.join(content, 'index.md')
    t = urllib.parse.unquote(t)
    if t.startswith('/'):
        p = os.path.join(content, t.lstrip('/'))
    else:
        p = os.path.normpath(os.path.join(content, base_dir, t))
    if t.endswith('/'):
        return os.path.join(p, 'index.md')
    if p.endswith('.md'):
        return p
    if p.endswith('.html'):
        return p[:-5] + '.md'
    for cand in (p + '.md', os.path.join(p, 'index.md')):
        if os.path.isfile(cand):
            return cand
    return p + '.md'          # 交给调用方判存在性


def main() -> int:
    ap = argparse.ArgumentParser(description='VitePress 站内链接 / 产物校验')
    ap.add_argument('--site-content', required=True)
    ap.add_argument('--group', help='只检查某个分组目录（如 guide）')
    ap.add_argument('--site-ts', help='同时校验 site.ts 里 sidebar 的 link')
    ap.add_argument('--skip-dist', action='store_true', help='不检查构建产物')
    args = ap.parse_args()

    content = args.site_content.rstrip('/')
    pattern = os.path.join(content, args.group or '', '**', '*.md')
    files = sorted(glob(pattern, recursive=True))
    if not files:
        print('✗ %s 下没有 md 文件' % pattern, file=sys.stderr)
        return 1

    missing, checked = [], 0
    for f in files:
        rel_dir = os.path.relpath(os.path.dirname(f), content)
        text = open(f, encoding='utf-8').read()
        for m in LINK.finditer(text):
            target = m.group(1)
            if target.startswith(SKIP_PREFIX) or is_asset(target):
                continue
            resolved = resolve(content, target, rel_dir)
            checked += 1
            if not (resolved and os.path.isfile(resolved)):
                missing.append((os.path.relpath(f, content), target))

    # nav / socialLinks 里的外部地址不是站内页面，跳过；同一地址重复出现只算一次
    sidebar_missing, sidebar_checked = [], []
    if args.site_ts and os.path.isfile(args.site_ts):
        ts = open(args.site_ts, encoding='utf-8').read()
        for link in dict.fromkeys(SIDEBAR_LINK.findall(ts)):
            if link.startswith(SKIP_PREFIX) or '://' in link:
                continue
            sidebar_checked.append(link)
            resolved = resolve(content, link, '.')
            if not (resolved and os.path.isfile(resolved)):
                sidebar_missing.append(link)

    dist = os.path.join(content, '.vitepress', 'dist')
    have_dist = not args.skip_dist and os.path.isdir(dist)
    dist_missing = []
    if have_dist:
        for f in files:
            rel = os.path.relpath(f, content)[:-3]      # 去掉 .md
            html = os.path.join(dist, rel + '.html')
            if not os.path.isfile(html):
                dist_missing.append(rel)

    print('检查 md 文件      : %d' % len(files))
    print('站内链接          : %d 个，缺失 %d' % (checked, len(missing)))
    if args.site_ts:
        print('sidebar link      : %d 个，缺失 %d' % (len(sidebar_checked), len(sidebar_missing)))
    if not args.skip_dist:
        print('构建产物          : %s' % ('已比对，缺失 %d' % len(dist_missing) if have_dist else '未构建（跳过）'))

    bad = 0
    if missing:
        bad += len(missing)
        print('\n✗ 死链：')
        for f, t in missing:
            print('  %s  ->  %s' % (f, t))
    if sidebar_missing:
        bad += len(sidebar_missing)
        print('\n✗ sidebar 指向不存在的页面：')
        for t in sidebar_missing:
            print('  %s' % t)
    if dist_missing:
        bad += len(dist_missing)
        print('\n✗ 缺构建产物（页面会被 404）：')
        for r in dist_missing:
            print('  %s' % r)

    if bad:
        return 1
    print('\n✓ 全部通过')
    return 0


if __name__ == '__main__':
    sys.exit(main())
