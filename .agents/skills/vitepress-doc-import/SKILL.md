---
name: vitepress-doc-import
description: 把任意 Markdown 目录批量导入已有的 VitePress 文档站并编排菜单与侧边栏。当用户说「请把某目录下的文档放进文档站 / 加进文档库 / 搬进站点，要求 …」，或要求把已有 docs 目录导入 VitePress（站点内容根，通常是 `<站点根>/content`）并整理左侧目录树、顶栏导航、分组总览页时使用。也用于导入后搜不到、或构建报 Vue 编译错误（Error parsing JavaScript expression、Element is missing end tag）的修复。
---

# VitePress 文档站批量导入

把一批 Markdown 搬进 VitePress 站点，并按主题重新编排导航与侧边栏。
**机械转换交给脚本，判断交给你**：脚本负责复制 / 链接改写 / Vue 语法兼容 / 自检；目录分组、slug 命名、菜单文案由你按内容语义决定。

## 核心约束（先读，别踩）

1. **只写站点目录，绝不改源目录**：源文档是唯一真相，导入是单向复制。收尾用 `git status --porcelain <源目录>` 证明源未变。
2. **不要动容器**：宿主机 bind mount（`../:/app`）下改文件即热更新。改 `.vitepress/site.ts` 只会让容器内 VitePress 进程**自动重启**（日志 `site.ts changed, restarting server...`），**不是**容器重启。只有依赖变更/挂载变更才需要 `docker compose up -d --build`。
3. **不要 `git commit`**：除非用户明确要求。
4. **不留垃圾**：构建产物 `content/.vitepress/dist/`、临时脚本、探针页 `*probe*.md` 收尾必须清掉。
5. **不删模板示例目录之外的东西**：`content/guide/` 这类模板自带示例可按需删除并在报告里说明；用户既有页面不要动。
6. **搜索索引不是热更新**：见下文 §6，改完必须让 dev server 重启一次（`touch site.ts` 即可）。

## 步骤

### 0. 定位站点与运行时

```bash
# 找到 VitePress 根（含 .vitepress/config.mts 的目录），内容根通常是它同级的 content/
find . -maxdepth 3 -name config.mts -path '*.vitepress*'
ls -a <站点根>/content

# 确认容器、挂载、启动命令（三条都要看，缺一条就热更新不了）
docker ps --format '{{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -i -E 'vitepress|doc|<站点关键词>'
docker inspect <容器名> --format '{{json .Mounts}}'
docker inspect <容器名> --format '{{json .Config.Cmd}}'      # 期望 sh -c "pnpm install && pnpm dev"

# 确认站点身份配置现状（每批次都要按内容扩写它的 nav / sidebar）
cat <内容根>/.vitepress/site.ts
```

常见两种布局，脚本都用 `--site-content` 指向内容根即可：

| 布局 | 站点根 | 内容根 |
|---|---|---|
| 模板仓库独立运行 | 仓库根 | `content/` |
| 嵌在父项目里 | `<父项目>/<子目录>/` | `<父项目>/<子目录>/content/` |

### 1. 清点源目录

```bash
find <src目录> -type f -name '*.md' | sort
for f in <src目录>/*.md; do printf '%-46s | ' "$(basename "$f")"; grep -m1 '^# ' "$f" || echo '!! 无 H1'; done
grep -rnE '!\[[^]]*\]\(' <src目录>/*.md | head        # 图片（要复制到 public/）
grep -rnE '\]\((\.\./|\./)' <src目录>/*.md | head     # 相对链接（要改写）
```

清点时记下三件事：**篇数**、**有没有 H1**（无 H1 的补 frontmatter `title`）、**有没有图片/相对链接**。

### 2. 设计信息架构（这一步是判断，不是脚本）

- **分组按「读者的动线」而非目录名**：先回答「新人从哪进、做完一件事要依次看哪几篇」，再据此排序。例：概念与建模 → 操作流程 → 参数与调优 → 故障排查 → 附录速查。
- **菜单分组数控制在 5~8 组**，每组 2~7 篇。单篇成组只允许 1~2 组。
- **菜单分组不必等于目录层级**：sidebar 是显式列项，一个子目录下的 9 篇可以在菜单里拆成两组，从而避免深层嵌套。
- **文件名一律 ascii kebab-case**（`快速上手-操作指南.md` → `getting-started/quickstart.md`）。中文/空格会造成 URL 里出现 `%20`、`%E4%B8%AD`。
- **标题取原文 H1**，不要把文件名当标题：slug 是导入时生成的，H1 才是作者写的正式标题，两者经常不一致。
- 已下线/被替代的组件，在菜单文案里加后缀（如「（已下线）」）并在页面顶部加 `::: warning` 说明。

### 3. 写映射清单，先 `--dry-run`

映射是 JSON：源文件名 → 站点内相对路径（相对 `--group`）。

```bash
cat > /tmp/doc-import-map.json <<'JSON'
{
  "快速上手-操作指南.md": "getting-started/quickstart.md",
  "常见问题排查.md":      "troubleshooting/faq.md"
}
JSON

python3 .agents/skills/vitepress-doc-import/scripts/import_docs.py \
  --src <源目录> --site-content <内容根> --group <分组名> \
  --map /tmp/doc-import-map.json --dry-run
```

未给 `--map` 时脚本只把建议稿打印到标准输出（按文件名里的 ASCII 片段猜 slug，纯中文名会退化成 `doc.md`/`doc-2.md`）并退出，不写任何文件；想存盘就加 `--suggest-out /tmp/map.suggested.json`。

确认清单无误后去掉 `--dry-run` 正式执行。脚本会自动：

- 复制并建立分组目录；
- **同批次内部互链自动改写**为新的相对路径（`.md` → 新 slug）；
- 指向批次外的 `../xxx.md` 降级为纯文本（避免死链）；
- 行内代码里的 `{{ … }}` 与正文里裸写的 `{{ … }}` → `<code v-pre>…</code>`；
- 裸泛型 `ARRAY<STRING>`、裸标签 `<ts>` → 反引号包裹；
- 白名单标签（`<div>`、`<table>` 等）开闭不配平时给警告（漏闭合同样会炸构建）；
- 逐文件自检，发现阻断级问题以非 0 退出码报出。

### 4. 补分组总览页与站点配置

1. **写 `<内容根>/<group>/index.md`**：三段就够——「我要做什么 → 看哪篇」速查表、分组篇数表、必要的阅读须知（下线组件、未收录的外链、敏感信息提示）。
2. **改 `.vitepress/site.ts`**：`nav` 加一项（`{ text: '<分组显示名>', link: '/<分组名>/' }`），`sidebar['/<分组名>/']` 写全各组。**base 必须等于实际访问路径**：根目录访问写 `/`，子路径写 `/<子路径>/`。
3. **改 `<内容根>/index.md` 首页**：hero 主按钮指向新分组，`features` 放 4 个入口卡片。
4. 无 H1 的文件补：

   ```markdown
   ---
   title: 页面标题
   ---
   ```

5. 模板示例目录（`content/guide/` 等）如已无引用，删除并在报告里说明。

### 5. 构建校验（不看构建成功，看产物齐全）

```bash
docker exec <容器> sh -c "cd /app && pnpm build" 2>&1 | tail -20      # 期望 build complete

# 逐页比对：每个 md 都必须有对应 html
cd <内容根> && for p in $(find <group> -name '*.md' | sed 's|\.md$||' | sort); do
  [ -f ".vitepress/dist/$p.html" ] && echo "OK   $p" || echo "MISS $p"; done

python3 .agents/skills/vitepress-doc-import/scripts/check_site.py \
  --site-content <内容根> --group <group> --site-ts <内容根>/.vitepress/site.ts

rm -rf <内容根>/.vitepress/dist        # 产物只在构建期需要，留着会污染 dev 监视
```

构建报 Vue 编译错误时**不要猜行号**——错误里的行号是生成代码的行号，和 md 行号对不上。用 `references/vitepress-pitfalls.md` §1 的方法定位（fence/行内代码感知扫描）。

### 6. 让搜索与页面真正生效

```bash
touch <内容根>/.vitepress/site.ts        # 触发 dev server 自我重启 → 全量重建搜索索引
sleep 6
docker logs --tail 10 <容器> | grep 'restarting server'
curl -s 'http://127.0.0.1:<端口>/@localSearchIndexroot' | head -c 60   # 看 documentCount
for u in / /<group>/ /<group>/<某个页面>; do
  printf '%-30s %s\n' "$u" "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:<端口>$u)"; done
```

然后提醒用户**刷新浏览器**再打开搜索（索引模块是首次搜索时才动态 import 的，客户端有缓存）。

### 7. 收尾

```bash
rm -f /tmp/doc-import-map.json          # 临时映射/脚本
git status --porcelain <源目录>          # 空 → 证明源目录未被动
docker ps --format '{{.Names}}\t{{.Status}}'   # 其他容器状态未变
```

## 验收清单

| 检查项 | 通过标准 |
|---|---|
| 篇数 | 源 md 数（减去索引类 README）== 站点内新增 md 数 |
| 构建 | `pnpm build` 输出 `build complete`，无 Vue 编译错误 |
| 产物 | 每个 md 都有同名 `.html`；`MISS` 数量为 0 |
| 链接 | `check_site.py` 报 0 缺失（含 sidebar 里所有 `link`） |
| 搜索 | `/@localSearchIndexroot` 的 `documentCount` 随内容变化；新页面能被搜到 |
| 访问 | 首页、分组总览、每个分组抽 1 篇，全部 200 |
| 影响面 | 源目录 `git status` 为空；其他容器 `Up` 时长未变；无 `*probe*`/`dist/` 残留 |

## 详细踩坑与原理

`references/vitepress-pitfalls.md` —— Vue 编译两巨头错误、搜索索引何时重建、热更新边界、死链与 base、构建产物与缓存。
遇到构建错误或"页面能打开但搜不到"时**先读它再动手**，能省掉三轮返工。
