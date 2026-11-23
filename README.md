# vitepress-note-starter

一个可以直接拿来写个人笔记的 VitePress 站点模板：**本地只装 Docker + Git 就能开发，推送到 `main` 自动部署到 GitHub Pages**。

模板本身只保留框架和示例文档，不包含任何私人内容。你只需要改一个配置文件（`docs/.vitepress/config.mts`），然后就可以把 `docs/` 当成自己的笔记本。

## 特性

- **只改一个文件**：站点标题、描述、`base` 路径、顶部导航、侧边栏都集中在 `docs/.vitepress/config.mts`，关键位置有中文注释。
- **本机零环境依赖**：Node 22 + pnpm 全部跑在 Docker 容器里，不需要安装 Node、pnpm；镜像只预置运行环境，**不含 VitePress**，站点代码通过 volume 挂载，热更新正常。
- **一条流水线搞定上线**：`.github/workflows/deploy.yml` 已按最新 GitHub Pages Actions 写好（`configure-pages@v5` + `upload-pages-artifact@v3` + `deploy-pages@v4`），推送即发布，模板使用者不用改流水线。
- **写作体验完整**：默认开启 VitePress 本地搜索（中文文案已汉化）、内置 Mermaid 流程图/时序图、代码块行号、深色模式、Markdown 扩展语法。
- **目录分工清晰**：`docs/` 是内容区（随便改），`docker/`、`.github/` 是框架文件（正常不用动）。

## 目录结构

```text
vitepress-note-starter/
├── .github/
│   └── workflows/
│       └── deploy.yml           # 推送 main → 构建 → 发布 GitHub Pages
├── docker/                      # 所有容器相关文件收拢在这里
│   ├── Dockerfile               # node:22 + pnpm，不含站点代码
│   ├── docker-compose.yml       # 把仓库根目录挂载到 /app
│   └── .env.example             # 复制为 .env 使用（端口、镜像名、npm 源）
├── docs/                        # ★ 你的笔记全部放这里
│   ├── .vitepress/
│   │   ├── config.mts           # ★ 唯一需要修改的配置文件
│   │   └── theme/index.ts       # 自定义主题入口（默认继承默认主题）
│   ├── public/                  # 静态资源（logo、图片、CNAME 等）
│   ├── index.md                 # 首页（hero + features）
│   ├── guide/                   # 使用指南（可删）
│   │   ├── index.md
│   │   ├── markdown.md
│   │   ├── mermaid.md
│   │   └── deploy.md
│   └── notes/                   # 笔记区（示例，可删可改）
│       ├── index.md
│       └── demo.md
├── .dockerignore
├── .gitignore
├── package.json                 # 脚本 docs:dev / docs:build / docs:preview
├── pnpm-lock.yaml
├── LICENSE
└── README.md
```

## 使用步骤

### 方式一：Use this template（推荐）

1. 打开模板仓库页面，点右上角 **Use this template → Create a new repository**；
2. 起个仓库名，例如 `my-notes`（这个名字决定后面的 `base` 路径）；
3. 克隆到本地：

   ```bash
   git clone git@github.com:<你的用户名>/my-notes.git
   cd my-notes
   ```

4. 改配置：打开 `docs/.vitepress/config.mts`，按注释改这 5 处 —— `BASE`（最重要）、站点标题/描述、`nav`、`sidebar`、`socialLinks`：
   - 普通仓库 → `const BASE = '/my-notes/'`
   - 仓库名是 `<用户名>.github.io` → `const BASE = '/'`
5. 启动本地开发（只需要 Docker）：

   ```bash
   cd docker
   cp .env.example .env
   docker compose up -d
   docker compose logs -f      # 看到 Local: http://localhost:5173/vitepress-note-starter/ 就可以访问了
   ```

   > 访问 `http://localhost:5173/` 会自动 302 跳转到 `base` 路径（如 `/vitepress-note-starter/`），这是 VitePress 的正常行为，不是配置错误。

6. 写笔记 → 提交 → 推送，Pages 自动上线：

   ```bash
   git add .
   git commit -m "docs: 第一篇笔记"
   git push origin main
   ```

### 方式二：Fork

适合想保留「派生自本模板」关系的场景。Fork 之后比方式一**多两步**：

1. **手动开启 Actions**：进入 Fork 后仓库的 **Actions** 标签页，点 *"I understand my workflows, go ahead and enable them"*。Fork 仓库的 Actions 默认是关闭的，不点这一步永远不会自动部署。
2. **设置 Pages**：**Settings → Pages → Build and deployment → Source** 选择 **GitHub Actions**（不要选 "Deploy from a branch"）。

其余步骤与方式一相同（同样要改 `BASE`）。

> 只想要一个干净副本、又不想让别人看到笔记：用方式一（Use this template）建 **Private** 仓库即可；Fork 只能 Fork 公开仓库，且 Pages 需要公开仓库（免费计划）。

## 本地开发命令

### Docker 方式（推荐，本机只需 Docker）

在仓库根目录下：

| 操作 | 命令 |
| --- | --- |
| 启动（首次会 build 镜像 + 安装依赖） | `cd docker && docker compose up -d` |
| 启动并重建镜像 | `cd docker && docker compose up -d --build` |
| 看日志 | `docker compose logs -f` |
| 进容器执行命令 | `docker compose exec docs sh` |
| 停止容器 | `docker compose down` |
| 停止并清空依赖卷 | `docker compose down -v` |
| 构建产物 | `docker compose run --rm docs sh -c "pnpm install && pnpm docs:build"` |

不想 `cd` 的话，也可以在仓库根目录统一加 `-f`：

```bash
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml logs -f
docker compose -f docker/docker-compose.yml down
```

### 本机方式（可选，需要自己装 Node 20+ / pnpm）

```bash
pnpm install
pnpm docs:dev       # 开发：http://localhost:5173/
pnpm docs:build     # 构建：docs/.vitepress/dist/
pnpm docs:preview   # 预览构建产物：http://localhost:4173/
```

> `--host 0.0.0.0` 已内置在 `package.json` 的脚本里，容器外一定能访问。

## 常见坑

1. **`base` 配错 → 页面没样式**
   症状：页面能打开但白底黑字、控制台 /assets/... 404。原因：`BASE` 和仓库名不一致，或首尾斜杠漏了。普通仓库必须写 `'/仓库名/'`，`<用户名>.github.io` 仓库写 `'/'`。改完要重新推送，让流水线重新构建。

2. **Fork 后自动部署不生效**
   Fork 仓库的 Actions 默认停用，必须去 Actions 页手动 Enable；同时 Pages 的 Source 要选 **GitHub Actions**。

3. **Properties 里没设置 Pages，Actions 报 `Get Pages site failed`**
   同样是 Pages Source 没设成 GitHub Actions。

4. **Docker 里改了文件页面不刷新**
   某些文件系统（Windows / WSL / 网络盘）inotify 事件不触发。compose 里已设置 `CHOKIDAR_USEPOLLING: "true"` 兜底；仍然不刷就重启容器。

5. **容器启动了但浏览器打不开**
   先看日志是否出现 `Local: http://localhost:5173/`（首次要装依赖，1~3 分钟）；再看端口是否冲突，改 `docker/.env` 里的 `DEV_PORT`。

6. **`/app/node_modules` 是空的 / 宿主机没有 node_modules**
   这是刻意设计的：依赖装在命名卷里（`docker compose down -v` 可重置），避免宿主机与容器二进制不一致，也让仓库目录保持干净。

7. **新增依赖后 CI 报 lockfile 不一致**
   本地改完依赖要提交 `pnpm-lock.yaml`。容器里执行 `pnpm install` 后，宿主机上会出现新的 lockfile。

8. **页面全白（`#app` 里什么都没有）—— 三个真实原因都已在模板里处理**
   - `.npmrc` 被删了。`vitepress-plugin-mermaid` 把 mermaid 的间接依赖（`dayjs`、`cytoscape` 等）硬编码进了 Vite 的 `optimizeDeps.include`，pnpm 严格隔离的 `node_modules` 让这些包在根目录解析不到，于是 `dayjs.min.js`、`fastdom.js` 这类 CJS 文件被原样丢给浏览器，报 `does not provide an export named 'default'`，客户端挂载失败 → 白屏。`.npmrc` 里的 `shamefully-hoist=true`（插件作者的官方建议）不能删。
   - `config.mts` 的 `vite.optimizeDeps.include: ['mermaid']` 被删了。mermaid 是运行时动态 import 的，不加这行时它不会被预打包，内部的 CJS 子依赖会一个个漏出来报错。
   - 改了依赖/配置但没清缓存。旧的预打包元数据还在 `docs/.vitepress/cache`，会继续用错的解析结果。清掉即可：
     ```bash
     cd docker && docker compose down -v && docker compose up -d --build
     rm -rf ../docs/.vitepress/cache     # 注意路径，或在仓库根执行
     ```

9. **所有文档页请求 500、浏览器里显示 404 页面**
   报错是 `Error: spawn git ENOENT`。VitePress 的「最后更新于」会执行 `git log` 取文件时间戳，容器里没有 git 就必然报错。
   镜像已装 git（`docker/Dockerfile`）；如果你自己改过 Dockerfile 或换基础镜像，记得保留 `git`。
   补充：项目设置了 `themeConfig.lastUpdated`（中文文案）就会**隐式启用**该功能，不存在「只改文案不启用」的写法。

10. **用局域网主机名访问报 `Blocked request. This host ("manager") is not allowed`**
    Vite 5.4.12+ 的 DNS rebinding 防护只放行 `localhost` / `127.0.0.1` / IP 字面量。模板已在 `config.mts` 里设了 `vite.server.allowedHosts: true`；
    只想放行特定域名时改成数组：`allowedHosts: ['manager', '.example.com']`。

11. **Mermaid 不渲染**
    检查代码块语言标记是否写成 ` ```mermaid `；节点文字含括号等特殊符号时用双引号包起来，如 `A["含(括号)的文字"]`。

12. **不要提交 `docs/.vitepress/dist` 和 `docs/.vitepress/cache`**
    已在 `.gitignore` 中忽略，构建产物交给流水线生成，提交会污染历史。

13. **启动日志里的 `Failed to resolve dependency: debug ... present in 'optimizeDeps.include'`**
    只剩 `debug` 一条了，无害。`debug` 根本不是 mermaid 11 的依赖，是插件版本里遗留的硬编码条目，任何包管理器都解析不到；其余几条已由 `.npmrc` 的提升解决。

14. **想用自己的 IP/端口对外访问预览**
    compose 已把端口发布为 `0.0.0.0:5173`，同网段用 `http://<服务器IP>:5173/` 即可访问（会 302 跳到 `base` 路径）。
    注意这是 **Vite dev server（带 HMR）**，适合开发预览；长期对外提供访问请改成 `pnpm docs:build` 产物 + nginx 之类的静态服务器。

## 上线说明

- 触发条件：推送到 `main` 分支，或在 Actions 页手动 `Run workflow`。
- 权限：`contents: read`、`pages: write`、`id-token: write`（缺一个都会失败，已在 workflow 里写好）。
- 并发：`group: pages`，同一时刻只跑一个部署，不会互相覆盖。
- 产物：`docs/.vitepress/dist` 上传为 Pages artifact，由 `actions/deploy-pages` 发布。
- 站点地址：**Settings → Pages** 顶部显示；普通仓库形如 `https://用户名.github.io/仓库名/`。
- 自定义域名：在 `docs/public/` 放 `CNAME` 文件、把 `BASE` 改为 `'/'`，再到 Settings → Pages 填域名。
- 更多细节见文档站里的 `docs/guide/deploy.md`。

## 说明

- 本仓库仅包含框架与示例内容，示例文档（`docs/guide/`、`docs/notes/`）可以整目录删掉，换成你自己的笔记。
- 许可证：[Apache-2.0](./LICENSE)。
