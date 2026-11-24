# vitepress-note-starter

一个可以直接拿来写个人笔记的 VitePress 站点模板：**本地只装 Docker + Git 就能开发，推送到 `main` 自动部署到 GitHub Pages**。

模板本身只保留框架和示例文档，不包含任何私人内容。你只需要改一个配置文件（`docs/.vitepress/site.ts`），然后就可以把 `docs/` 当成自己的笔记本。

## 特性

- **只改一个文件**：站点标题、描述、`base` 路径、顶部导航、侧边栏都集中在 `docs/.vitepress/site.ts`，关键位置有中文注释。
- **本机零环境依赖**：Node 22 + pnpm 全部跑在 Docker 容器里，不需要安装 Node、pnpm；镜像只预置运行环境，**不含 VitePress**，站点代码通过 volume 挂载，热更新正常。
- **一条流水线搞定上线**：`.github/workflows/deploy.yml` 已按最新 GitHub Pages Actions 写好（`configure-pages@v5` + `upload-pages-artifact@v3` + `deploy-pages@v4`），推送即发布，模板使用者不用改流水线。
- **写作体验完整**：默认开启 VitePress 本地搜索（中文文案已汉化、支持中文句中词）、内置 Mermaid 流程图/时序图、代码块行号、深色模式、Markdown 扩展语法。
- **一条命令搬进私有项目**：`scripts/init-private-site.sh` 生成一个不含 GitHub 依赖的新项目（剥离 `.github/`、填好配置、附 nginx/Docker 部署文件），适配 Codeup / GitLab / 内网服务器。
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
│   │   ├── site.ts              # ★ 唯一需要修改的文件（标题/base/导航/侧边栏/页脚）
│   │   ├── config.mts           # 框架配置：搜索、Mermaid、中文文案（不用动）
│   │   ├── search-tokenize.ts   # 中文搜索分词器（不用动）
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

### 方式一：Use this template（推荐：公开仓库 + GitHub Pages）

> **按钮在哪**：打开仓库主页 → 文件列表**上方那一行**、`<> Code` 按钮旁边的绿色 **Use this template** 按钮
> （**不在**右上角 Watch / Fork / Star 那一排；Fork 才在那里）。
> 也可以直接访问 `https://github.com/<owner>/<repo>/generate` 打开「从模板创建新仓库」页面。
>
> 看不到这个按钮，说明该仓库还没开启模板功能 —— 仓库**维护者**需要在 **Settings → General → Template repository** 勾选一次。

#### 第 1 步：建仓库并克隆

1. 点 **Use this template → Create a new repository**；
2. 起个仓库名，例如 `my-notes`（**这个名字决定后面的 `base` 路径**，别随手改）；
3. 克隆到本地（`<你的用户名>` 换成自己的 GitHub 用户名）：

```bash
git clone git@github.com:<你的用户名>/my-notes.git
cd my-notes
```

#### 第 2 步：改站点身份（只改 `docs/.vitepress/site.ts` 一个文件）

```ts
export const site = {
  base: '/my-notes/',                    // ← 必须等于仓库名，首尾斜杠都要
                                         //    仓库名叫 <用户名>.github.io 时写 '/'
  title: '我的笔记',                      // ← 站点名（浏览器标签、左上角）
  titleTemplate: ':title | 我的笔记',      // ← 跟着上面一起改
  description: '我的个人笔记',             // ← 一句话简介
  nav: [ /* ← 顶部导航，按需增删 */ ],
  sidebar: { /* ← 左侧侧边栏，按目录分组 */ },
  socialLinks: [ /* ← 右上角图标，不需要就写 [] */ ],
  footer: { /* ← 页脚，不需要就整段删掉 */ }
}
```

> `base` 要等于 `https://<用户名>.github.io/` **后面那段路径**。配错的典型症状是页面能打开但样式全丢（白底黑字裸 HTML）。

#### 第 3 步：本地预览（只需要 Docker）

```bash
cd docker
cp .env.example .env        # 首次执行；要换端口就改里面的 DEV_PORT（默认 5173）
docker compose up -d        # 首次会 build 镜像 + 装依赖，约 1~3 分钟
docker compose logs -f      # 出现 Local: http://localhost:5173/my-notes/ 即成功
```

浏览器打开 `http://localhost:5173/` 会自动 302 跳到 `base` 路径（如 `/my-notes/`），这是正常行为，不是配置错误。
看完用 `docker compose down` 停止；第一次改依赖后需要 `docker compose up -d --build`。

#### 第 4 步：推送，Pages 自动上线

```bash
git add .
git commit -m "docs: 第一篇笔记"
git push origin main
```

#### 第 5 步：首次上线前，GitHub 侧做三件事（各一次）

1. **Settings → Pages → Build and deployment → Source** 选 **GitHub Actions**（不要选 Deploy from a branch）；
2. **Settings → General → Default branch** 确认为 **main**；
3. 若仓库是从 Fork 来的，去 **Actions** 页点 *"I understand my workflows, go ahead and enable them"*。

#### 第 6 步：验证

```bash
# Actions 页里 Deploy VitePress to GitHub Pages 显示绿色对勾（约 1 分钟）
curl -I https://<你的用户名>.github.io/<仓库名>/    # ← 换成实际地址，期望 200
```

样式丢失说明 `base` 配错；改完 `git push` 重新触发重建即可。

### 方式二：Fork（想保留「派生自本模板」的关系）

只想要干净副本、又不想让别人看到笔记，请走方式一建 **Private** 仓库：Fork 只能 Fork 公开仓库，且免费计划下 Pages 需要公开仓库。

#### 第 1 步：Fork 并开启 Actions

1. 仓库主页右上角点 **Fork**（注意是 Fork，不是 Use this template）；
2. 进入 Fork 后的仓库 → **Actions** 标签 → 点 *"I understand my workflows, go ahead and enable them"*。
   不点这一步，工作流永远不会运行，后面推送也不会有任何部署。

#### 第 2 步：设置 Pages

**Settings → Pages → Build and deployment → Source** 选 **GitHub Actions**（Fork 仓库不会继承这项设置）。

#### 第 3 步：克隆并改 `base`

```bash
# <你的用户名> 换成自己的 GitHub 用户名
git clone git@github.com:<你的用户名>/vitepress-note-starter.git
cd vitepress-note-starter
```

改 `docs/.vitepress/site.ts`（规则同方式一第 2 步）：

```ts
base: '/vitepress-note-starter/',   // ← 等于 Fork 后的仓库名；仓库名叫 <用户名>.github.io 时写 '/'
```

#### 第 4 步：本地预览

```bash
cd docker
cp .env.example .env        # 首次执行；端口在 DEV_PORT（默认 5173）
docker compose up -d
docker compose logs -f      # 出现 Local: http://localhost:5173/vitepress-note-starter/ 即成功
```

#### 第 5 步：推送并验证

```bash
git add .
git commit -m "docs: 第一篇笔记"
git push origin main
curl -I https://<你的用户名>.github.io/vitepress-note-starter/    # ← 换成实际地址，期望 200
```

> Fork 的副作用：以后可以在 GitHub 页面点 **Sync fork** 同步模板更新，但模板改动会一并进来，
> 你自己改过的 `site.ts`、文档可能要重新解决冲突。只想拿一份干净副本就用方式一。

### 方式三：用在自己的私有项目里（Codeup / GitLab / 内网服务器）

适用场景：代码托管在云效 Codeup / GitLab / 自建 Gitea，站点部署在自己服务器（nginx 或 Docker），
全程不经过 GitHub。一条命令完成「复制模板 + 剥离 `.github/` + 填好配置 + 生成部署文件 + 换远程仓库」。

脚本具体做的事：复制模板（排除 `.git` / `node_modules` / 构建产物）→ 删除 `.github/` 与讲 Pages 的示例页 →
生成 `docs/.vitepress/site.ts` → 生成空白文档骨架（首页 + 总览 + 写作规范）与精简版 `README.md` →
按 `--deploy` 生成部署文件 → `git init -b main` 并把 `origin` 指向你的私有仓库。

#### 前置条件（先确认三件事）

| 检查项 | 怎么确认 |
| --- | --- |
| 私有仓库已建好，且**是空仓库** | Codeup 新建仓库时**不要**勾「初始化 README / .gitignore」；已有内容的仓库后面推送会被拒 |
| 本机 SSH 公钥已加到 Codeup | `ssh -T git@codeup.aliyun.com`，能返回登录信息即为通 |
| 本机能跑 Docker（或 Node 22 + pnpm） | `docker version` 或 `node -v` |

#### 第 1 步：克隆模板到目标目录

```bash
mkdir -p ~/work/hcp-notes && cd ~/work/hcp-notes   # ← 换成你的路径，该目录必须是空的
git clone git@github.com:Chungtow/vitepress-note-starter.git .
```

#### 第 2 步：一条命令改造（把下面 7 个值换成你自己的）

```bash
bash scripts/init-private-site.sh --in-place \
  --name "HCP 业务文档" \
  --desc "HCP 项目内部文档" \
  --base / \
  --deploy nginx \
  --web-root /data/www/hcp-notes \
  --repo git@codeup.aliyun.com:mygroup/hcp-notes.git
```

| 参数 | 你要填什么 |
| --- | --- |
| `--name` | 站点名，显示在浏览器标签和左上角 |
| `--desc` | 一句话简介 |
| `--base` | 访问路径。部署在**域名/端口根目录**（`http://notes.xxx.com/`）写 `/`；挂在**现有站点子路径**（`http://xxx.com/hcp-notes/`）写 `/hcp-notes/` |
| `--deploy` | `nginx`（服务器跑 nginx）｜`docker`（容器发布）｜`none`（只生成站点，自己拷 dist） |
| `--web-root` | 仅 `nginx` 用：发版时同步到服务器的哪个目录，必须与 `deploy/nginx.conf` 的 `root` 一致 |
| `--repo` | 你的私有仓库 SSH 地址（Codeup 仓库首页「克隆」里复制） |
| `--reset-git` | **可选**。加上 = 清空模板历史、彻底断掉 GitHub；不加 = 保留模板历史，以后还能 `git pull` 同步模板更新 |

> ⚠️ 这段命令**不要在行尾加 `#` 注释**：续行符会被注释打断，命令直接报错。
> 想保留 Markdown/Mermaid 示例页加 `--keep-samples`；想继续用 GitHub Pages 加 `--keep-github`。
> 全量参数：`bash scripts/init-private-site.sh --help`。

#### 第 3 步：检查改造结果（4 条命令，输出都对再往下走）

```bash
git remote -v      # 只应出现 codeup 那一行；还看到 github 说明没清干净
ls scripts deploy  # 应有 init-private-site.sh 与 nginx.conf
grep -E "base|title" docs/.vitepress/site.ts        # base 与 title 应是你刚填的值
grep -rn "github" --include="*.ts" --include="*.md" . | grep -v node_modules   # 期望无输出
```

#### 第 4 步：本地预览

```bash
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml logs -f    # 出现 Local: http://localhost:5173<你的 base> 即成功
```

#### 第 5 步：首次提交并推送

```bash
git add -A
git commit -m "chore: 初始化 hcp-notes 文档站"
git push -u origin main      # 第一次必须带 -u，之后 git push 即可
```

> 推送被拒（`[rejected] non-fast-forward`）说明 Codeup 仓库里已经有内容（建仓时勾了初始化 README）。
> 清空那个仓库后重推；确认里面没有有用内容时也可以 `git push -u origin main --force`。

#### 第 6 步：部署到服务器（方式 A：nginx）

1. 改 `deploy/nginx.conf` 里两行：

```nginx
server {
    listen 80;
    server_name notes.example.com;      # ← 改成你的域名或内网 IP
    root /data/www/hcp-notes;           # ← 与 --web-root 一致
    ...
}
```

2. 拷到服务器并生效（`<用户>` / `<服务器>` 换实际值）：

```bash
scp deploy/nginx.conf <用户>@<服务器>:/tmp/hcp-notes.conf
ssh <用户>@<服务器> 'sudo mv /tmp/hcp-notes.conf /etc/nginx/conf.d/hcp-notes.conf && sudo nginx -t && sudo nginx -s reload'
```

3. 以后每次发版（构建 + 同步一步到位）：

```bash
bash scripts/deploy.sh      # pnpm install --frozen-lockfile && pnpm docs:build && rsync 到 WEB_ROOT
```

> 想临时换目标目录：`WEB_ROOT=/srv/www/hcp-notes bash scripts/deploy.sh`。
> 服务器上需要有 `rsync`；没有就装（`sudo apt install -y rsync`）或改用下面的 Docker 方式。

#### 第 6 步：部署到服务器（方式 B：Docker）

第 2 步用的是 `--deploy nginx` 就跳过本节（A、B 二选一；想换 Docker 就重跑脚本并改成 `--deploy docker`）。

```bash
# 用 --deploy docker 生成的项目才有这些文件；在项目根目录执行
docker compose -f deploy/docker-compose.yml up -d --build
```

默认映射宿主机 `8080` 端口；要换端口改 `deploy/docker-compose.yml` 里的 `"8080:80"`，
然后访问 `http://<服务器IP>:8080`。

#### 第 7 步：验证

```bash
curl -I http://notes.example.com/                          # ← 换实际地址，期望 200
curl -s http://notes.example.com/ | grep -c 'assets/app'   # 期望 1（有资源引用，不是裸 HTML）
```

#### 附：不想 clone 进当前目录？

用 `--dir` 模式在指定路径生成一份新项目，模板目录保持干净（下面在模板目录里执行）：

```bash
bash scripts/init-private-site.sh --dir ../hcp-notes \
  --name "HCP 业务文档" --base / --deploy nginx \
  --repo git@codeup.aliyun.com:mygroup/hcp-notes.git
```

#### 附：常见问题

| 现象 | 原因与解决 |
| --- | --- |
| 页面能打开但没样式（裸 HTML） | `base` 与实际访问路径不符。改 `site.ts` 的 `base` 后重新构建/发版 |
| `bash: scripts/init-private-site.sh: No such file` | 模板版本旧（脚本是后加的）。在模板目录 `git pull` 后再执行 |
| 推送被拒 `[rejected]` | Codeup 仓库非空。清空后重推，或确认无有用内容后 `--force` |
| `rsync: command not found` | 服务器装 rsync，或改用 `--deploy docker` |
| 以后想同步模板更新 | 加 `--reset-git` 就同步不了了。改用 `git remote rename origin upstream` 保留模板历史 |
| 忘了加 `--deploy` | 重新跑一次并补上参数；注意会覆盖 `site.ts` 与文档骨架，先备份自己写的内容 |

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

> 本节针对方式一/方式二（GitHub Pages）。方式三生成的私有项目不用 GitHub，部署看它自带的
> `deploy/`（nginx 配置或 Dockerfile）与 `scripts/deploy.sh`。

- 触发条件：推送到 `main` 分支，或在 Actions 页手动 `Run workflow`。
- 权限：`contents: read`、`pages: write`、`id-token: write`（缺一个都会失败，已在 workflow 里写好）。
- 并发：`group: pages`，同一时刻只跑一个部署，不会互相覆盖。
- 产物：`docs/.vitepress/dist` 上传为 Pages artifact，由 `actions/deploy-pages` 发布。
- 站点地址：**Settings → Pages** 顶部横幅 / Actions 里 deploy job 的 environment 链接 / 按 `https://用户名.github.io/仓库名/` 直接访问。
- 自定义域名：在 `docs/public/` 放 `CNAME` 文件、把 `base` 改为 `'/'`，再到 Settings → Pages 填域名。

GitHub 侧只需要做三件事（各一次）：**Settings → Pages 的 Source 选 GitHub Actions**、**默认分支为 main**、**模板所有者勾选 Template repository**。

- 逐条步骤 + 失败原因 + Pages 地址怎么找：`docs/guide/github-setup.md`
- 部署原理、`base` 路径、自定义域名：`docs/guide/deploy.md`

## 说明

- 本仓库仅包含框架与示例内容，示例文档（`docs/guide/`、`docs/notes/`）可以整目录删掉，换成你自己的笔记。
- 许可证：[Apache-2.0](./LICENSE)。
