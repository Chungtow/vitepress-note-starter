# 总览与快速开始

本模板把「能长期写下去」所需的最小框架都准备好了：只保留 VitePress 配置、Docker 开发环境、GitHub Pages 流水线和几篇示例文档。

::: tip 一句话理解
`content/` 是**你的内容**（想怎么改就怎么改），`docker/` 和 `.github/` 是**框架**（正常不用动）。
:::

## 目录结构

```text
.
├── content/                     # 站点内容（你的笔记都放这里）
│   ├── .vitepress/
│   │   ├── site.ts              # ★ 唯一需要修改的文件（标题 / base / 导航 / 侧边栏）
│   │   ├── config.mts           # 框架配置：搜索、Mermaid、中文文案（不用动）
│   │   └── theme/index.ts       # 自定义主题入口（可扩展）
│   ├── public/                  # 静态资源，按 /文件名 引用
│   ├── index.md                 # 首页
│   ├── guide/                   # 使用指南
│   └── notes/                   # 你的笔记目录（示例）
├── docker/                      # 本地开发容器
│   ├── Dockerfile               # node22 + pnpm，不含 VitePress
│   ├── docker-compose.yml       # 挂载 ../ 到 /app
│   └── .env.example             # 复制为 .env 后生效
├── scripts/
│   └── init-private-site.sh     # 一键生成私有项目（剥离 GitHub、生成部署文件）
├── .github/workflows/deploy.yml # 推送 main 自动部署 Pages（私有项目里会被脚本删掉）
├── package.json                 # 脚本与依赖
└── README.md
```

## 三步跑起来

```bash
# 1. 启动容器（首次会自动 build 镜像并安装依赖，耐心等 1~3 分钟）
cd docker
cp .env.example .env
docker compose up -d

# 2. 看日志，等到出现 "Local: http://localhost:5173/vitepress-note-starter/" 就成功了
docker compose logs -f

# 3. 浏览器打开 http://localhost:5173/
```

::: tip 地址栏里的 /vitepress-note-starter/ 是正常的
本地访问根路径会 302 跳到 `site.ts` 里 `base` 指定的前缀（默认 `/vitepress-note-starter/`），
这样本地预览和线上 GitHub Pages 的路径完全一致，避免「本地正常、上线后样式丢失」这类问题。
:::

停止容器：

```bash
docker compose down
```

::: warning 第一次启动别急着刷新
首次启动要先拉 `node:22` 基础镜像并 `pnpm install`，日志里出现 `Local: http://localhost:5173/` 之前页面打不开是正常的。
:::

## 写第一篇笔记

1. 在 `content/notes/` 下新建文件，例如 `content/notes/my-first-note.md`；
2. 文件开头可以写 frontmatter（也可不写）：

   ```md
   ---
   title: 我的第一篇笔记
   date: 2026-01-01
   ---
   ```

3. 正文直接用 Markdown 写；
4. 在 `content/.vitepress/site.ts` 的 `sidebar` 里为它加一行 `{ text: '我的第一篇笔记', link: '/notes/my-first-note' }`；
5. 保存即热更新，浏览器会自动刷新。

## 不想用 Docker 的话

模板也支持本机 Node 环境（需要自己装 Node 20+ 和 pnpm）：

```bash
pnpm install
pnpm dev
```

::: tip --host 0.0.0.0 已经内置
`package.json` 里的 `dev` 脚本就是 `vitepress dev content --host 0.0.0.0`，所以容器外一定能访问到。
:::

## 搬进自己的私有项目（Codeup / GitLab / 内网）

不想用 GitHub Pages、也不想手工删改模板，直接跑：

```bash
bash scripts/init-private-site.sh --dir ../hcp-notes \
     --name "HCP 业务文档" --base / \
     --deploy nginx --repo git@codeup.aliyun.com:mygroup/hcp-notes.git
```

它会复制一份干净项目、删掉 `.github/`、生成填好的 `site.ts`、换成空白文档骨架，
并按 `--deploy` 附上 `deploy/nginx.conf` + `scripts/deploy.sh`（或 `--deploy docker`
生成多阶段 Dockerfile）。已经是模板 clone 时改用 `--in-place`。参数见 `--help`。

下一步：[Markdown 写法示例](/guide/markdown) · [Mermaid 图表示例](/guide/mermaid) · [部署上线说明](/guide/deploy) · [GitHub 仓库设置（一次性）](/guide/github-setup)
