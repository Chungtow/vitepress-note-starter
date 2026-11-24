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
│   │   ├── deploy.md            # 部署原理、base 路径、自定义域名
│   │   └── github-setup.md      # GitHub 侧一次性设置、Pages 地址在哪看
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

> **按钮在哪**：打开仓库主页 → 文件列表**上方那一行**、`<> Code` 按钮旁边的绿色 **Use this template** 按钮
> （**不在**右上角 Watch / Fork / Star 那一排；Fork 才在那里）。
> 也可以直接访问 `https://github.com/<owner>/<repo>/generate` 打开「从模板创建新仓库」页面。
>
> 看不到这个按钮，说明该仓库还没开启模板功能 —— 仓库**维护者**需要在 **Settings → General → Template repository** 勾选一次。

1. 点 **Use this template → Create a new repository**；
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

## 上线说明

- 触发条件：推送到 `main` 分支，或在 Actions 页手动 `Run workflow`。
- 权限：`contents: read`、`pages: write`、`id-token: write`（缺一个都会失败，已在 workflow 里写好）。
- 并发：`group: pages`，同一时刻只跑一个部署，不会互相覆盖。
- 产物：`docs/.vitepress/dist` 上传为 Pages artifact，由 `actions/deploy-pages` 发布。
- 站点地址：**Settings → Pages** 顶部横幅 / Actions 里 deploy job 的 environment 链接 / 按 `https://用户名.github.io/仓库名/` 直接访问。
- 自定义域名：在 `docs/public/` 放 `CNAME` 文件、把 `BASE` 改为 `'/'`，再到 Settings → Pages 填域名。

GitHub 侧只需要做三件事（各一次）：**Settings → Pages 的 Source 选 GitHub Actions**、**默认分支为 main**、**模板所有者勾选 Template repository**。

- 逐条步骤 + 失败原因 + Pages 地址怎么找：`docs/guide/github-setup.md`
- 部署原理、`base` 路径、自定义域名：`docs/guide/deploy.md`

## 说明

- 本仓库仅包含框架与示例内容，示例文档（`docs/guide/`、`docs/notes/`）可以整目录删掉，换成你自己的笔记。
- 许可证：[Apache-2.0](./LICENSE)。
