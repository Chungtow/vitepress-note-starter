<p align="center">
  <img src="./assets/logo.svg" width="120" height="120" alt="vitepress-note-starter logo">
</p>

<h1 align="center">vitepress-note-starter</h1>

<p align="center">
  <a href="./README.md">English</a> ·
  <b>简体中文</b> ·
  <a href="https://chungtow.github.io/vitepress-note-starter/">Website</a>
</p>

<p align="center">基于 VitePress 的个人笔记站点模板</p>
<p align="center">本机只需要 Docker 与 Git，推送到 main 分支后自动发布到 GitHub Pages</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-blue.svg" alt="License"></a>
  <a href="https://vitepress.dev"><img src="https://img.shields.io/badge/VitePress-1.6.4-42b883?logo=vite&logoColor=white" alt="VitePress"></a>
  <img src="https://img.shields.io/badge/node-%E2%89%A5_20-339933?logo=node.js&logoColor=white" alt="Node.js">
  <img src="https://img.shields.io/badge/pnpm-10.34.9-F69220?logo=pnpm&logoColor=white" alt="pnpm">
  <img src="https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white" alt="Docker">
  <a href="https://github.com/Chungtow/vitepress-note-starter/actions/workflows/deploy.yml"><img src="https://github.com/Chungtow/vitepress-note-starter/actions/workflows/deploy.yml/badge.svg" alt="Deploy status"></a>
</p>

## 简介

这个仓库是一个可以直接投入使用的 VitePress 笔记站点模板，面向需要长期维护个人笔记或团队文档、但不想在环境配置上反复花时间的场景。

模板本身只包含框架与示例内容，没有任何私人数据。克隆之后，修改 `content/.vitepress/site.ts` 里的几项配置，就可以把 `content/` 目录当作自己的笔记本长期使用；新增页面、调整导航、改主题色都不需要碰构建配置。

默认的发布路径是 GitHub Pages：推送到 `main` 分支后，GitHub Actions 自动完成构建与发布。如果代码托管在阿里云 Codeup、GitLab 或内网服务器上，仓库提供的初始化脚本可以生成一份不依赖 GitHub 的项目，并附带 Docker 与 nginx 两种部署方案。

## 主要特性

- **配置集中在一个文件**：站点标题、描述、`base` 路径、顶部导航、侧边栏和页脚都写在 `content/.vitepress/site.ts`，关键字段带有中文注释。
- **本机不需要安装 Node**：Node 22 与 pnpm 都运行在 Docker 容器里，镜像只预置运行环境，不包含 VitePress 本体；站点代码通过 volume 挂载，容器内改动等同宿主机改动，热更新正常可用。
- **推送即发布**：`.github/workflows/deploy.yml` 基于 GitHub 官方 Pages Actions 编写（`configure-pages@v5`、`upload-pages-artifact@v3`、`deploy-pages@v4`），使用模板时不需要修改流水线。
- **写作体验完整**：默认启用本地搜索，中文文案与中文分词均已适配；同时内置 Mermaid 图表、代码块行号、深色模式和常用 Markdown 扩展语法。
- **可以迁移到私有环境**：`scripts/init-private-site.sh` 会生成一个不含 GitHub 依赖的新项目，剥离 `.github/`、写好站点配置、附带 nginx 与 Docker 部署文件，适配 Codeup、GitLab 和内网服务器。
- **目录职责清晰**：`content/` 是内容区，可以随意增删；`docker/` 与 `.github/` 属于框架文件，正常使用中不需要改动。

## 目录结构

```text
vitepress-note-starter/
├── .github/
│   └── workflows/
│       └── deploy.yml           # 推送 main 后构建并发布到 GitHub Pages
├── docker/                      # 容器相关文件都收拢在这里
│   ├── Dockerfile               # node:22 + pnpm，不含站点代码
│   ├── docker-compose.yml       # 把仓库根目录挂载到 /app
│   └── .env.example             # 复制为 .env 后使用（端口、镜像名、npm 源）
├── content/                     # 笔记内容全部放在这里
│   ├── .vitepress/
│   │   ├── site.ts              # 唯一需要修改的文件（标题、base、导航、侧边栏、页脚）
│   │   ├── config.mts           # 框架配置：搜索、Mermaid、中文文案
│   │   ├── search-tokenize.ts   # 中文搜索分词器
│   │   └── theme/index.ts       # 自定义主题入口，默认继承默认主题
│   ├── public/                  # 静态资源（站点 logo、图片、CNAME 等）
│   ├── index.md                 # 首页
│   ├── guide/                   # 使用指南，可整目录删除
│   │   ├── index.md
│   │   ├── markdown.md
│   │   ├── mermaid.md
│   │   ├── deploy.md            # 部署原理、base 路径、自定义域名
│   │   └── github-setup.md      # GitHub 侧的一次性设置，Pages 地址在哪看
│   └── notes/                   # 笔记区，示例内容可删可改
│       ├── index.md
│       └── demo.md
├── scripts/
│   └── init-private-site.sh     # 生成私有项目：剥离 GitHub、生成部署文件
├── .dockerignore
├── .gitignore
├── package.json                 # dev / build / preview 三个脚本
├── pnpm-lock.yaml
├── LICENSE
├── README.md                    # 英文说明
└── README.zh-CN.md              # 中文说明（当前文件）
```

## 使用步骤

下面按使用场景给出四种方式。先说明命令里的占位符，下文出现的尖括号内容都需要替换成你自己的值，不要照抄尖括号本身。

| 占位符 | 含义 | 例子 |
| --- | --- | --- |
| `<目录>` | 本地项目目录，可以包含路径 | `notes`、`~/work/notes` |
| `<仓库名>` | 新建的代码仓库名 | `notes` |
| `<组>` | Codeup 或 GitLab 的组、命名空间 | `mygroup` |
| `<站点名>` | 站点标题，显示在浏览器标签和页面左上角 | `业务文档` |
| `<子路径>` | 站点挂载在域名下的子路径 | `notes` |
| `<一句话简介>` | 站点描述 | `内部业务文档` |
| `<你的用户名>` | GitHub 用户名 | `octocat` |
| `<服务器>` | 服务器地址或内网 IP | `10.0.0.12` |
| `<服务器用户>` | 登录服务器使用的账号 | `root` |
| `<分支名>` | git 分支名 | `main` |

各方式示例中出现的 `my-notes`、`notes.example.com` 同样只是示范，按自己的命名替换即可。

### 方式一：Use this template（推荐，公开仓库加 GitHub Pages）

模板按钮位于仓库主页文件列表上方、`<> Code` 按钮旁边，是绿色的 **Use this template**。注意它不在右上角的 Watch、Fork、Star 那一排，Fork 才在那里。也可以直接访问 `https://github.com/<你的用户名>/<仓库名>/generate` 打开「从模板创建新仓库」页面。

如果看不到这个按钮，说明该仓库还没有开启模板功能，需要仓库维护者在 **Settings → General → Template repository** 中勾选一次。

#### 第 1 步：创建仓库并克隆

1. 点击 **Use this template → Create a new repository**；
2. 填写仓库名，例如 `my-notes`。这个名字决定后面 `base` 的取值，创建后不要随手修改；
3. 克隆到本地，把 `<你的用户名>` 换成自己的 GitHub 用户名：

```bash
git clone git@github.com:<你的用户名>/my-notes.git    # my-notes 换成你的仓库名
cd my-notes
```

#### 第 2 步：修改站点配置

只需要改 `content/.vitepress/site.ts` 一个文件：

```ts
export const site = {
  base: '/my-notes/',                    // 必须等于仓库名，首尾斜杠都要写
                                         // 仓库名为 <你的用户名>.github.io 时写 '/'
  title: '我的笔记',                      // 站点名，显示在浏览器标签和页面左上角
  titleTemplate: ':title | 我的笔记',      // 跟随上面一起修改
  description: '我的个人笔记',             // 一句话简介
  nav: [ /* 顶部导航，按需增删 */ ],
  sidebar: { /* 左侧侧边栏，按目录分组 */ },
  socialLinks: [ /* 右上角图标，不需要就写 [] */ ],
  footer: { /* 页脚，不需要就整段删除 */ }
}
```

`base` 必须等于访问地址 `https://<你的用户名>.github.io/` 后面那段路径。配置错误最典型的表现是页面可以打开但样式全部丢失，只剩白底黑字的裸 HTML。

#### 第 3 步：本地预览

本机只需要 Docker：

```bash
cd docker
cp .env.example .env        # 可选：需要改端口或镜像名时才复制，不改可以跳过，默认 5173
docker compose up -d --build   # 首次会构建镜像并安装依赖，约 1~3 分钟
docker compose logs -f         # 出现 Local: http://localhost:5173/my-notes/ 即成功
```

浏览器打开 `http://localhost:5173/` 时会自动 302 跳转到 `base` 指定的路径（例如 `/my-notes/`），这是正常行为，不是配置错误。

看完用 `docker compose down` 停止。之后修改文档或组件不需要任何额外操作，热更新会直接生效；修改 `package.json` 依赖则需要执行 `docker compose restart site` 重新安装，`--build` 无法覆盖这种情况，原因见「本地开发」一节的说明。

#### 第 4 步：推送并等待自动发布

```bash
git add .
git commit -m "docs: 第一篇笔记"
git push origin main
```

#### 第 5 步：GitHub 侧的一次性设置

首次上线前需要在仓库里完成三项设置：

1. **Settings → Pages → Build and deployment → Source** 选择 **GitHub Actions**，不要选 Deploy from a branch；
2. **Settings → General → Default branch** 确认为 **main**；
3. 如果仓库是从 Fork 得到的，还需要在 **Actions** 页面点击 *"I understand my workflows, go ahead and enable them"*。

#### 第 6 步：验证

```bash
# Actions 页面里 Deploy VitePress to GitHub Pages 变成绿色对勾，通常约 1 分钟
curl -I https://<你的用户名>.github.io/<仓库名>/    # 换成实际地址，期望返回 200
```

如果样式丢失，说明 `base` 配置有误；修改后执行 `git push` 重新触发构建即可。

### 方式二：Fork（保留派生自本模板的关系）

如果只想要一份干净的副本、又不希望别人看到笔记内容，请按方式一创建 **Private** 仓库。Fork 只能作用于公开仓库，而且在免费计划下 Pages 也要求仓库公开。

#### 第 1 步：Fork 并启用 Actions

1. 在仓库主页右上角点击 **Fork**，注意是 Fork，不是 Use this template；
2. 进入 Fork 后的仓库，切换到 **Actions** 标签，点击 *"I understand my workflows, go ahead and enable them"*。跳过这一步，工作流永远不会运行，后续推送也不会有任何部署动作。

#### 第 2 步：设置 Pages

进入 **Settings → Pages → Build and deployment → Source**，选择 **GitHub Actions**。Fork 得到的仓库不会继承这项设置。

#### 第 3 步：克隆并修改 base

```bash
# <你的用户名> 换成自己的 GitHub 用户名
git clone git@github.com:<你的用户名>/vitepress-note-starter.git
cd vitepress-note-starter
```

修改 `content/.vitepress/site.ts`，规则同方式一第 2 步：

```ts
base: '/vitepress-note-starter/',   // 等于 Fork 后的仓库名；仓库名为 <你的用户名>.github.io 时写 '/'
```

#### 第 4 步：本地预览

```bash
cd docker
cp .env.example .env        # 可选：需要改端口或镜像名时才复制，不改可以跳过，默认 5173
docker compose up -d --build
docker compose logs -f         # 出现 Local: http://localhost:5173/vitepress-note-starter/ 即成功
```

#### 第 5 步：推送并验证

```bash
git add .
git commit -m "docs: 第一篇笔记"
git push origin main
curl -I https://<你的用户名>.github.io/vitepress-note-starter/    # 换成实际地址，期望返回 200
```

Fork 有一项附带代价：之后可以在 GitHub 页面点击 **Sync fork** 同步模板更新，但模板改动会一并进入你的仓库，自己修改过的 `site.ts` 和文档可能需要重新解决冲突。只需要干净副本时，用方式一更省事。

### 方式三：用于私有项目（Codeup / GitLab / 内网服务器）

适用场景是代码托管在阿里云 Codeup、GitLab 或自建 Gitea，站点部署在自己的服务器上。默认走 Docker，构建与托管都在容器内完成，服务器上执行一条命令即可启动站点；如果服务器上已有 nginx，也可以直接发布静态目录，见第 6 步的方式 B。整个过程不经过 GitHub。

初始化脚本的执行流程是：复制模板（排除 `.git`、`node_modules` 和构建产物），删除 `.github/` 以及讲解 Pages 的示例页，生成 `content/.vitepress/site.ts`，生成空白文档骨架（首页、总览、写作规范）与精简版 `README.md`，按 `--deploy` 参数生成部署文件，最后执行 `git init -b main` 并把 `origin` 指向你的私有仓库。

#### 前置条件

| 检查项 | 确认方式 |
| --- | --- |
| 私有仓库已创建，且是空仓库 | Codeup 新建仓库时不要勾选「初始化 README / .gitignore」；仓库已有内容会导致后续推送被拒 |
| 本机 SSH 公钥已添加到 Codeup | 执行 `ssh -T git@codeup.aliyun.com`，能返回登录信息即为正常 |
| 本机可以运行 Docker（或 Node 22 加 pnpm） | 执行 `docker version` 或 `node -v` |

#### 第 1 步：把模板克隆到目标目录

```bash
# <目录> 换成你的项目路径，例如 ~/work/notes；该目录必须不存在或为空
mkdir -p <目录> && cd <目录>
git clone git@github.com:Chungtow/vitepress-note-starter.git .
```

#### 第 2 步：执行改造命令

把下面命令中的各个值换成你自己的：

```bash
bash scripts/init-private-site.sh --in-place \
  --name "<站点名>" \
  --desc "<一句话简介>" \
  --base / \
  --deploy docker \
  --repo git@codeup.aliyun.com:<组>/<仓库名>.git
```

| 参数 | 填写内容 |
| --- | --- |
| `--name` | 站点名，显示在浏览器标签和页面左上角 |
| `--desc` | 一句话简介 |
| `--base` | 访问路径。部署在域名或端口根目录（`http://notes.xxx.com/`、`http://10.0.0.12:8080/`）时写 `/`；挂在现有站点的子路径（`http://xxx.com/<子路径>/`）时写 `/<子路径>/` |
| `--deploy` | `docker`（推荐，见第 6 步方式 A）、`nginx`（服务器已有 nginx，直接发布静态目录，见第 6 步方式 B）、`none`（只生成站点，自行拷贝 dist） |
| `--repo` | 私有仓库的 SSH 地址，在 Codeup 仓库首页的「克隆」里复制 |
| `--reset-git` | 可选。加上会清空模板历史、彻底断开与 GitHub 的关联；不加则保留模板历史，之后仍可通过 `git pull` 同步模板更新 |
| `--web-root` | 仅在 `--deploy nginx` 时使用，可以稍后补上：发版时同步到服务器的哪个目录（如 `/data/www/notes`），必须与 `deploy/nginx.conf` 中的 `root` 一致 |

多行命令不要在行尾追加 `#` 注释，续行符会被注释打断，命令会直接报错。需要保留 Markdown 与 Mermaid 示例页时加 `--keep-samples`；仍想使用 GitHub Pages 时加 `--keep-github`。完整参数见 `bash scripts/init-private-site.sh --help`。

#### 第 3 步：核对改造结果

依次执行以下命令，输出符合预期再继续：

```bash
git remote -v      # 只应出现 codeup 那一行；仍有 github 说明没有清理干净
ls scripts deploy  # 应有 init-private-site.sh，deploy/ 下有 Dockerfile、nginx.conf、docker-compose.yml
grep -E "base|title" content/.vitepress/site.ts        # base 与 title 应为刚才填写的值
grep -rn "github" --include="*.ts" --include="*.md" . | grep -v node_modules   # 期望无输出
```

#### 第 4 步：本地预览

```bash
# 可选：复制配置模板。不改端口或镜像名可以跳过，compose 里每项都有默认值
cd docker
cp .env.example .env

docker compose up -d --build
docker compose logs -f    # 出现 Local: http://localhost:5173... 即成功
```

`docker/.env` 是本地文件，已列入 `.gitignore`，克隆或生成的新目录里一定不存在；不复制也能启动，只是端口固定使用默认的 `5173`。需要更换端口，或在同一台机器上运行多个站点（修改 `IMAGE_NAME`、`CONTAINER_NAME`）时，再复制后修改。

#### 第 5 步：首次提交并推送

```bash
git add -A
git commit -m "chore: 初始化 <目录> 文档站"
git push -u origin main      # 第一次必须带 -u，之后 git push 即可
```

如果推送被拒绝并提示 `[rejected] non-fast-forward`，说明 Codeup 仓库里已经有内容（建仓时勾选了初始化 README）。清空该仓库后重新推送；确认里面没有有用内容时，也可以执行 `git push -u origin main --force`。

#### 第 6 步：部署方式 A，Docker（推荐）

项目里已经包含 `deploy/Dockerfile` 与 `deploy/docker-compose.yml`。前者是多阶段构建，在 Node 环境里执行 `pnpm build`，再由 nginx 托管静态文件。把项目拷贝到服务器后，用一条命令启动站点：

```bash
cd <目录>                                              # 服务器上的项目目录
docker compose -f deploy/docker-compose.yml up -d --build

docker compose -f deploy/docker-compose.yml ps        # 查看状态
docker compose -f deploy/docker-compose.yml logs -f   # 查看日志
```

默认映射到宿主机 `8080` 端口，通过 `http://<服务器>:8080` 访问。需要更换端口时，修改 `deploy/docker-compose.yml` 里的 `"8080:80"`。

后续更新文档时，在服务器上执行 `git pull`，再重跑同一条 `up -d --build` 命令即可，镜像内会重新构建，不需要在宿主机安装 Node 或 pnpm。

也可以在本机或流水线里执行 `docker build -f deploy/Dockerfile -t <镜像名>:<tag> .`，推送到私有 registry，然后在服务器上 `docker pull` 并重启。这种方式适合构建机与运行机分离的场景。

#### 第 6 步：部署方式 B，nginx（可选）

只有在服务器已经运行 nginx、不希望再运行容器时使用。第 2 步需要加上 `--deploy nginx --web-root <服务器目录>`，也可以在项目根目录用 `--in-place` 重跑一次补生成。

1. 修改 `deploy/nginx.conf` 中的两行：

```nginx
server {
    listen 80;
    server_name notes.example.com;      # 改成你的域名或内网 IP
    root /data/www/<目录>;              # 与 --web-root 保持一致
    ...
}
```

2. 拷贝到服务器并生效，`<服务器用户>` 与 `<服务器>` 换成实际值：

```bash
scp deploy/nginx.conf <服务器用户>@<服务器>:/tmp/site.conf
ssh <服务器用户>@<服务器> 'sudo mv /tmp/site.conf /etc/nginx/conf.d/site.conf && sudo nginx -t && sudo nginx -s reload'
```

3. 之后每次发版只需一条命令完成构建与同步：

```bash
bash scripts/deploy.sh      # pnpm install --frozen-lockfile && pnpm build && rsync 到 WEB_ROOT
```

需要临时更换目标目录时执行 `WEB_ROOT=/srv/www/<目录> bash scripts/deploy.sh`。服务器上需要安装 `rsync`，没有的话执行 `sudo apt install -y rsync`，或者直接采用第 6 步方式 A 的 Docker 部署。

#### 第 7 步：验证

```bash
# 方式 A（Docker，默认 8080）
curl -I http://<服务器>:8080/                            # 期望 200
curl -s http://<服务器>:8080/ | grep -c 'assets/app'     # 期望 1，说明页面引用了资源文件而非裸 HTML

# 方式 B（nginx）
curl -I http://notes.example.com/                        # 换成实际地址，期望 200
```

#### 附：不克隆到当前目录

用 `--dir` 模式在指定路径生成新项目，模板目录保持干净。以下命令在模板目录中执行：

```bash
bash scripts/init-private-site.sh --dir ../<目录> \
  --name "<站点名>" --base / --deploy docker \
  --repo git@codeup.aliyun.com:<组>/<仓库名>.git
```

#### 附：常见问题

| 现象 | 原因与处理 |
| --- | --- |
| 页面能打开但没有样式（裸 HTML） | `base` 与实际访问路径不符。修改 `site.ts` 的 `base` 后重新构建或发版 |
| 提示 `bash: scripts/init-private-site.sh: No such file` | 模板版本较旧，脚本是后来添加的。在模板目录执行 `git pull` 后再运行 |
| 推送被拒 `[rejected]` | Codeup 仓库非空。清空后重推，或确认没有有用内容后使用 `--force` |
| 提示 `rsync: command not found` | 在服务器上安装 rsync，或改用 `--deploy docker` |
| 以后想同步模板更新 | 使用 `--reset-git` 后无法同步。需要保留模板历史时改用 `git remote rename origin upstream` |
| 漏掉了 `--deploy` 参数 | 重跑一次并补上参数。注意会重新生成 `site.ts` 与文档骨架，先备份自己写的内容 |

### 方式四：只要脚手架，不关联任何仓库

适用场景是先在自己机器上把站点搭起来、开始写文档，托管到哪里以后再决定；或者项目不进入版本库，仅本地或离线使用。产物特征是：没有任何 remote、没有历史提交、没有 `.github/`，但 `site.ts`、文档骨架和部署脚本都已就位。

#### 第 1 步（做法 A，推荐）：克隆后原地改造

```bash
# <目录> 换成你的项目路径，例如 ~/work/notes；必须不存在或为空
mkdir -p <目录> && cd <目录>
git clone git@github.com:Chungtow/vitepress-note-starter.git .

bash scripts/init-private-site.sh --in-place \
  --name "<站点名>" \
  --base / \
  --reset-git            # 关键：不加这一项，origin 仍然是 GitHub 上的地址
```

只克隆一次、原地改完，步骤最少。`--reset-git` 会删除 `.git` 并重新执行 `git init -b main`，GitHub 上的 remote 与提交历史一并消失，工作区文件则完整保留，包括 `scripts/`、`site.ts` 与文档骨架。

#### 第 1 步（做法 B）：用 --dir 模式从外部生成

如果连 `.git` 短暂存在都不希望出现（例如目标目录之后要并入别的仓库），可以从外部生成：

```bash
# 1) 把模板克隆到临时目录，只为取得生成脚本，用完即删
git clone --depth 1 git@github.com:Chungtow/vitepress-note-starter.git /tmp/tpl
cd /tmp/tpl

# 2) 生成脚手架。不传 --repo 就不会配置任何远端
#    --dir    目标路径，不存在会自动创建，下例写在临时模板的同级目录
#    --name   站点名
#    --base   部署路径，根目录写 /，子路径写 /<子路径>/
#    --deploy 可选：docker 或 nginx；不加则只生成站点
bash scripts/init-private-site.sh --dir ../<目录> \
  --name "<站点名>" \
  --base /

# 3) 删除临时模板，进入生成好的项目，路径与第 2 步 --dir 的值对应
rm -rf /tmp/tpl
cd ../<目录>
```

比做法 A 多两步，换来模板与产物的彻底分离：模板只在 `/tmp/tpl` 中存在，用完即删；新项目里只有 `git init` 出来的空仓库，文件已经 `git add`，没有远端也没有提交。

#### 第 2 步：确认环境干净

```bash
git remote -v                          # 期望：没有任何输出
git log --oneline 2>/dev/null          # 期望：fatal ... does not have any commits yet
ls -d .github 2>/dev/null || echo "无 .github"    # 期望：无 .github
grep -E "base|title" content/.vitepress/site.ts      # 期望：刚才填写的值
```

#### 第 3 步：启动本地开发环境

```bash
# 可选：复制配置模板，不改端口或镜像名可以跳过，compose 里每项都有默认值
cd docker
cp .env.example .env

docker compose up -d --build
docker compose logs -f    # 出现 Local: http://localhost:5173/ 即可
```

`docker/.env` 不入库，全新目录里一定没有这个文件；不复制也能正常启动，只是端口固定为 `5173`。

#### 以后接入仓库或部署

```bash
# 接入仓库，Codeup、GitLab、自建服务都可以
# <你的仓库地址> 示例：git@codeup.aliyun.com:<组>/<仓库名>.git
git remote add origin <你的仓库地址>
git add -A
git commit -m "chore: 初始化文档站"
git push -u origin main

# 补部署文件：在项目根目录用 --in-place 重跑一次
# 注意会重新生成 site.ts 与文档骨架，自己写的内容先提交或备份
bash scripts/init-private-site.sh --in-place --name "<站点名>" \
  --base / --deploy nginx --web-root /data/www/<目录>
```

#### 附：常见问题

| 现象 | 原因与处理 |
| --- | --- |
| `git remote -v` 仍显示 GitHub 地址 | 使用 `--in-place` 时漏了 `--reset-git`。补上后重跑，或手动执行 `git remote remove origin` |
| `git log` 里有模板的提交记录 | 同上，历史没有被清理；只有 `--reset-git` 会重建 `.git` |
| 想保留几篇示例文档参考写法 | 加 `--keep-samples`，保留 Markdown 与 Mermaid 示例页 |
| 不希望脚本新建 `main` 分支 | 无需处理；需要其他分支名时执行 `git branch -m <分支名>` |

## 本地开发

### Docker 方式（推荐，本机只需 Docker）

在仓库根目录下执行：

| 操作 | 命令 |
| --- | --- |
| 首次准备配置（可选，不改端口可跳过） | `cd docker && cp .env.example .env` |
| 启动（首次会构建镜像并安装依赖，**默认带 --build**） | `cd docker && docker compose up -d --build` |
| 启动但不检查镜像（明确没动过镜像定义时可省） | `cd docker && docker compose up -d` |
| 修改 `package.json` 或 `pnpm-lock.yaml` 后重装依赖 | `cd docker && docker compose restart site` |
| 查看日志 | `docker compose logs -f` |
| 进入容器执行命令 | `docker compose exec site sh` |
| 停止容器 | `docker compose down` |
| 停止并清空依赖卷 | `docker compose down -v` |
| 构建产物 | `docker compose run --rm site sh -c "pnpm install && pnpm build"` |

`docker/.env` 不入库，已列入 `.gitignore`，所以新克隆或新生成的目录里只有 `.env.example`。不复制也能启动，因为 `docker-compose.yml` 中 `DEV_PORT`、`IMAGE_NAME`、`CONTAINER_NAME`、`PNPM_VERSION`、`NPM_REGISTRY` 都带有 `${VAR:-默认值}` 形式的默认值，缺少 `.env` 时使用默认值，端口为 5173。

#### 为什么启动命令默认都带 --build

`docker compose up -d` 只在镜像尚不存在时才会构建。如果镜像已经存在于本地，即使修改了 `docker/Dockerfile`，或修改了 `docker/.env` 里的 `PNPM_VERSION`、`NPM_REGISTRY`，`up -d` 也只会输出一句 `Container ... Running`，继续使用旧镜像运行，改动实际上没有生效。加上 `--build` 就是把「镜像定义是否发生变化」也纳入比对，可以避免这类静默失效。

代价方面，没有改动时构建约 1 秒，各层全部命中缓存，镜像 ID 不变，容器也不会重建，基本可以忽略。明显的开销只出现在基础镜像 `node:22-bookworm-slim` 被上游更新时：会触发一次完整重建，约 25 秒，包含 `apt-get` 与 `npm install`，并重建容器让开发服务器重启一次。这属于应当重建的情况，不是误伤。

可以不加 `--build` 的情况有三种：

- 只修改了 `DEV_PORT` 或 `CONTAINER_NAME`，这两项作用于容器层，`up -d` 会重建容器，与镜像无关；
- 修改了 `IMAGE_NAME`，新名字在本地还没有对应镜像，`up -d` 会自动构建；
- 确定镜像定义没有变动，希望省掉那 1 秒。

另有两类改动不归 `--build` 管，因为这个项目的依赖不在镜像里，源码通过 volume 挂载：修改文档、组件或 `content/.vitepress/site.ts` 不需要任何操作，热更新会直接生效；修改 `package.json` 或 `pnpm-lock.yaml` 则需要执行 `docker compose restart site`，让 `command` 里的 `pnpm install` 重跑一次。

### 本机方式（可选，需要自行安装 Node 20 以上与 pnpm）

```bash
pnpm install
pnpm dev       # 开发：http://localhost:5173/
pnpm build     # 构建：content/.vitepress/dist/
pnpm preview   # 预览构建产物：http://localhost:4173/
```

`--host 0.0.0.0` 已经写入 `package.json` 的脚本，容器外一定能访问。

## 部署说明

本节针对方式一和方式二（GitHub Pages）。方式三与方式四不经过 GitHub：方式三用它自带的 `deploy/` 目录（nginx 配置或 Dockerfile）与 `scripts/deploy.sh`；方式四默认不带部署文件，需要时按「方式四 → 以后接入仓库或部署」补上。

- 触发条件：推送到 `main` 分支，或在 Actions 页面手动执行 `Run workflow`。
- 权限：`contents: read`、`pages: write`、`id-token: write`，缺少任意一项都会失败，这些已经写入 workflow。
- 并发：`group: pages`，同一时刻只运行一个部署任务，不会互相覆盖。
- 产物：`content/.vitepress/dist` 上传为 Pages artifact，由 `actions/deploy-pages` 发布。
- 站点地址：**Settings → Pages** 顶部的横幅、Actions 里 deploy job 的 environment 链接，或直接访问 `https://用户名.github.io/仓库名/`。
- 自定义域名：在 `content/public/` 放置 `CNAME` 文件，把 `base` 改为 `'/'`，再到 Settings → Pages 填写域名。

GitHub 侧总共只需要做三件事，各一次：**Settings → Pages 的 Source 选 GitHub Actions**、**默认分支设为 main**、**模板所有者勾选 Template repository**。

逐条步骤、失败原因与 Pages 地址的查找方式见 `content/guide/github-setup.md`；部署原理、`base` 路径与自定义域名的细节见 `content/guide/deploy.md`。

## 其它说明

- 仓库只包含框架与示例内容。示例文档（`content/guide/`、`content/notes/`）可以整目录删除，替换成自己的笔记。
- 仓库顶部的项目图标是纯手写的 SVG 文件，位于 `assets/logo.svg`；站点自身的图标位于 `content/public/logo.svg`，两者可以互换。
- 许可证：[Apache-2.0](./LICENSE)。
