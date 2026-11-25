# VitePress 导入踩坑与原理（已实测）

> 本文件记录在真实导入中踩过的坑与验证过的结论。构建报错、搜不到、样式丢失时先读对应小节，再动手改内容。

## 1. Vue 编译正文：两类硬错误

VitePress 把每个 `.md` 编译成 Vue 模板，所以正文里**看起来像 Vue 语法**的东西会被真的执行。

| 报错 | 触发 | 安全边界 |
|---|---|---|
| `Error parsing JavaScript expression: Unexpected token` | 行内代码里的 `{{ var('pt') }}`、`{{.Image}}` | 围栏代码块 ` ``` ` **安全**（VitePress 给 `<pre>` 加了 `v-pre`）；行内代码 `` `{{ }}` `` **不安全**；纯文本不安全 |
| `Element is missing end tag` | 正文裸写 `ARRAY<STRING>`、`profiles.yml.bak.<ts>`、`cancel <JobID>` | 转义 `\<k`、自动链接 `<https://…>`、白名单标签 `<a>`/`<br>` 安全 |

### 修法

- `{{ … }}` → `<code v-pre>{{ … }}</code>`（渲染仍是等宽代码，`v-pre` 不进产物）
- 裸泛型 / 裸标签 → 用反引号包起来：`` `ARRAY<STRING>` ``、`` `<ts>` ``
- 围栏代码块里的内容**一律不动**

### 定位难点（重要）

报错给的 `(行:列)` 是**生成代码**的位置，和 md 行号对不上。不要按行号找，用"编译感知"的扫描：

```python
FENCE = re.compile(r'^\s*(?:>\s*)*(```|~~~)')     # 注意 blockquote 里的 ```bash
CODE  = re.compile(r'(`+)(?!`)(.+?)(?<!`)\1(?!`)')
```

1. 逐行跟踪是否在围栏内（**必须允许 `> ``` ` 前缀**，否则引用块里的代码会被当成正文）；
2. 行内代码外，匹配 `</?[A-Za-z][A-Za-z0-9]*(\s[^<>]*)?/?>`，白名单之外的标签即问题；
3. 行内代码内，出现 `{{` 即问题。

`scripts/import_docs.py` 的 `scan_issues()` 就是这个扫描器，导入时会自动报。

### 反例（我实际犯过）

先跑"泛型包反引号"，再跑"裸标签包反引号"，同一行被处理两次 → `` `ARRAY`<STRING>`` ``。**泛型与标签必须在同一次 `re.sub` 里用 alternation 决定**。

## 2. 搜索索引：什么时候才会包含新文档

`vitepress@1.6.4`：`dist/node/chunk-*.js` 里的 `localSearchPlugin`。

| 位置 | 行为 |
|---|---|
| `configureServer()` | 启动/重启时 `await scanForBuild()`：遍历 `siteConfig.pages` **全量**建 MiniSearch 索引 |
| `handleHotUpdate({file})` | 只有 `file.endsWith('.md')` 时 `indexFile(file)` → **增量** `index.add(...)` |
| `indexFile()` | 只有 `add`，**没有 remove**：删页 / 改名 / 改标题会留下陈旧条目，重启才能清 |
| `onIndexUpdated()` | 失效并推 ws 的是 `/@localSearchIndex`（wrapper），实数据在 `/@localSearchIndexroot` |

实测现象：

- `curl -s http://127.0.0.1:5173/@localSearchIndex` → `export default {"root": () => import("/@localSearchIndexroot")}`
- `curl -s http://127.0.0.1:5173/@localSearchIndexroot` → `export default "{\"documentCount\":<N>,...}"`（可直接用来验证索引规模）
- 新建 `.md` 后**不重启**：索引模块内容不变（Vite 按 URL 缓存 transform，而插件失效的是 wrapper，不是这个 locale 模块）
- 重启后：`documentCount` 重建，新文档可见

**操作结论**

```bash
touch <内容根>/.vitepress/site.ts     # config 依赖变更 -> VitePress 自重启 -> 全量重建索引
docker logs --tail 10 <容器> | grep 'restarting server'
```

- 不需要 `docker compose restart site`（那只是"重启容器→重启 VitePress"的笨办法）；`touch site.ts` 更轻。
- 用户浏览器要 **F5**：搜索索引是首次打开搜索时才动态 `import` 的，客户端已缓存。
- **生产静态站是构建时快照**（`load()` 里 `NODE_ENV === 'production'` 才 `scanForBuild()`）：每次发布都必须重新 `pnpm build`，重启容器毫无作用。

## 3. 热更新与"要不要重建容器"

| 改动 | 结果 |
|---|---|
| 增删改 `content/**/*.md` | HMR（页面级热更新） |
| 改 `.vitepress/site.ts` / `config.mts` | 容器内 VitePress **进程**自动重启：`content/.vitepress/site.ts changed, restarting server...` |
| 改 `package.json` 依赖 / Dockerfile / 挂载 | 需要 `docker compose -f docker/docker-compose.yml up -d --build` |

前提三条缺一不可：容器有 `bind mount`（`../:/app`）、`working_dir=/app`、`Cmd` 是 `sh -c "pnpm install && pnpm dev"`。先 `docker inspect` 确认再动手，否则宿主机改文件在容器里看不到。

`pnpm build` 会把产物写进 `content/.vitepress/dist/`，dev 的 watcher 会对这些文件狂刷 `page reload .vitepress/dist/...`（噪音，无害）。构建校验完就 `rm -rf` 掉。

## 4. 路由与文件命名

- 中文 / 空格文件名会变成 `%E4%B8%AD`、`%20`，链接难看且容易写错 → **统一 ascii kebab-case**（`快速上手-操作指南.md` → `getting-started/quickstart.md`）。
- `x/index.md` 对应 `/x/`；`x/y.md` 对应 `/x/y`（未开 `cleanUrls` 时产物是 `/x/y.html`）。
- `site.ts` 的 `base` 必须等于实际访问路径：根目录访问写 `/`，子路径写 `/xxx/`。配错的特征是"页面能打开但完全没有样式、控制台一堆 `/assets/...` 404"。

## 5. 死链

- `config.mts` 默认有 `ignoreDeadLinks: true`：死链**不中断构建**，但用户点不动，属于静默故障 → 必须用 `scripts/check_site.py` 显式检查。
- 原文里的 `../other/xxx.md`（跨目录）搬进站内后基本都会死：批次内的改写成新相对路径，批次外的降级为纯文本。
- 站内绝对写法从内容根算起：`/<分组名>/<子目录>/<slug>`。

## 6. 从 `docs/` 搬进站点的额外注意

- **图片**：`![](./img/x.png)` 不会被自动搬运，需复制到 `<内容根>/public/` 并改成 `/img/x.png`。脚本不做图片处理，导入前先统计图片数量，再决定是集中放 `public/images/` 还是按分组分目录。
- **口令/内网地址随文搬运**：导入前确认站点只在内网可访问；导入后在分组总览里写明"仅限内网"。
- **标题**：菜单文案取原文 H1，不要取文件名（两者常不一致）。
- **无 H1 的文件**：`##` 开头的长文档（如函数速查）要补 frontmatter，否则页面标题退化成站点名：

  ```markdown
  ---
  title: 常用函数速查
  ---
  ```

- **已下线组件**：页面顶部加 `::: warning 已下线（历史参考）`，菜单文案加「（已下线）」后缀。

## 7. 验收与清理

```bash
docker exec <容器> sh -c "cd /app && pnpm build" | tail -3     # build complete
python3 scripts/check_site.py --site-content <内容根> --group <group> --site-ts <内容根>/.vitepress/site.ts
rm -rf <内容根>/.vitepress/dist
for u in / /<group>/ /<group>/<抽检页>; do curl -s -o /dev/null -w "$u %{http_code}\n" http://127.0.0.1:5173$u; done
git status --porcelain <源目录>        # 必须为空
docker ps --format '{{.Names}}\t{{.Status}}'   # 其他容器 Up 时长不应变化
```

参考量级：几十篇 md → 页面数 ≈ 篇数 + 各分组 `index.md` + `404.html`。搜索索引的 `documentCount` 按小节（标题）累加，一篇 20 个小节的文档就贡献 20 条左右，所以总量通常是千级，和篇数不成正比。`pnpm build` 大约 30~60 秒，取决于内容量与机器。
