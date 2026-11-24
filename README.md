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
├── scripts/
│   └── init-private-site.sh     # 一键生成私有项目（剥离 GitHub、生成部署文件）
├── .dockerignore
├── .gitignore
├── package.json                 # 脚本 docs:dev / docs:build / docs:preview
├── pnpm-lock.yaml
├── LICENSE
└── README.md
```

## 使用步骤

> **占位符约定**：下文命令里尖括号包住的部分都要换成你自己的值，不要照抄尖括号本身。
>
> | 占位符 | 含义 | 例子 |
> | --- | --- | --- |
> | `<目录>` | 本地项目目录（可含路径） | `notes`、`~/work/notes` |
> | `<仓库名>` | 新建的代码仓库名 | `notes` |
> | `<组>` | Codeup / GitLab 的组或命名空间 | `mygroup` |
> | `<站点名>` | 站点标题，显示在浏览器标签和左上角 | `业务文档` |
> | `<子路径>` | 站点挂在域名下的子路径 | `notes` |
> | `<一句话简介>` | 站点描述 | `内部业务文档` |
> | `<你的用户名>` | GitHub 用户名 | `octocat` |
> | `<服务器>` | 服务器地址或内网 IP | `10.0.0.12` |
> | `<服务器用户>` | 登录服务器的账号 | `root` |
> | `<分支名>` | git 分支名 | `main` |
>
> 各方式示例里出现的 `my-notes`、`notes.example.com` 同样只是示范，按自己的名字替换即可。

### 方式一：Use this template（推荐：公开仓库 + GitHub Pages）

> **按钮在哪**：打开仓库主页 → 文件列表**上方那一行**、`<> Code` 按钮旁边的绿色 **Use this template** 按钮
> （**不在**右上角 Watch / Fork / Star 那一排；Fork 才在那里）。
> 也可以直接访问 `https://github.com/<你的用户名>/<仓库名>/generate` 打开「从模板创建新仓库」页面。
>
> 看不到这个按钮，说明该仓库还没开启模板功能 —— 仓库**维护者**需要在 **Settings → General → Template repository** 勾选一次。

#### 第 1 步：建仓库并克隆

1. 点 **Use this template → Create a new repository**；
2. 起个仓库名，例如 `my-notes`（**这个名字决定后面的 `base` 路径**，别随手改）；
3. 克隆到本地（`<你的用户名>` 换成自己的 GitHub 用户名）：

```bash
git clone git@github.com:<你的用户名>/my-notes.git    # ← my-notes 换成你的仓库名
cd my-notes                                          # ← 同一名字
```

#### 第 2 步：改站点身份（只改 `docs/.vitepress/site.ts` 一个文件）

```ts
export const site = {
  base: '/my-notes/',                    // ← 必须等于仓库名，首尾斜杠都要
                                         //    仓库名叫 <你的用户名>.github.io 时写 '/'
  title: '我的笔记',                      // ← 站点名（浏览器标签、左上角）
  titleTemplate: ':title | 我的笔记',      // ← 跟着上面一起改
  description: '我的个人笔记',             // ← 一句话简介
  nav: [ /* ← 顶部导航，按需增删 */ ],
  sidebar: { /* ← 左侧侧边栏，按目录分组 */ },
  socialLinks: [ /* ← 右上角图标，不需要就写 [] */ ],
  footer: { /* ← 页脚，不需要就整段删掉 */ }
}
```

> `base` 要等于 `https://<你的用户名>.github.io/` **后面那段路径**。配错的典型症状是页面能打开但样式全丢（白底黑字裸 HTML）。

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
base: '/vitepress-note-starter/',   // ← 等于 Fork 后的仓库名；仓库名叫 <你的用户名>.github.io 时写 '/'
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

适用场景：代码托管在云效 Codeup / GitLab / 自建 Gitea，站点部署在自己的服务器上。
**默认走 Docker**：构建与托管全在容器里，服务器上只要一条命令就能起站；已有 nginx 想直接发静态目录也行（见第 6 步 B）。
全程不经过 GitHub。

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
# <目录> 换成你的项目路径，例如 ~/work/notes；该目录必须不存在或为空
mkdir -p <目录> && cd <目录>
git clone git@github.com:Chungtow/vitepress-note-starter.git .
```

#### 第 2 步：一条命令改造（把下面 6 个值换成你自己的）

```bash
bash scripts/init-private-site.sh --in-place \
  --name "<站点名>" \
  --desc "<一句话简介>" \
  --base / \
  --deploy docker \
  --repo git@codeup.aliyun.com:<组>/<仓库名>.git
```

| 参数 | 你要填什么 |
| --- | --- |
| `--name` | 站点名，显示在浏览器标签和左上角 |
| `--desc` | 一句话简介 |
| `--base` | 访问路径。部署在**域名/端口根目录**（`http://notes.xxx.com/`、`http://10.0.0.12:8080/`）写 `/`；挂在**现有站点子路径**（`http://xxx.com/<子路径>/`）写 `/<子路径>/` |
| `--deploy` | **`docker`（推荐，第 6 步 A）**｜`nginx`（已有 nginx 直接发静态目录，第 6 步 B）｜`none`（只生成站点，自己拷 dist） |
| `--repo` | 你的私有仓库 SSH 地址（Codeup 仓库首页「克隆」里复制） |
| `--reset-git` | **可选**。加上 = 清空模板历史、彻底断掉 GitHub；不加 = 保留模板历史，以后还能 `git pull` 同步模板更新 |
| `--web-root` | 仅 `--deploy nginx` 用，可稍后再补：发版同步到服务器哪个目录（如 `/data/www/notes`），必须与 `deploy/nginx.conf` 的 `root` 一致 |

> ⚠️ 这段命令**不要在行尾加 `#` 注释**：续行符会被注释打断，命令直接报错。
> 想保留 Markdown/Mermaid 示例页加 `--keep-samples`；想继续用 GitHub Pages 加 `--keep-github`。
> 全量参数：`bash scripts/init-private-site.sh --help`。

#### 第 3 步：检查改造结果（4 条命令，输出都对再往下走）

```bash
git remote -v      # 只应出现 codeup 那一行；还看到 github 说明没清干净
ls scripts deploy  # 应有 init-private-site.sh，deploy/ 下有 Dockerfile、nginx.conf、docker-compose.yml
grep -E "base|title" docs/.vitepress/site.ts        # base 与 title 应是你刚填的值
grep -rn "github" --include="*.ts" --include="*.md" . | grep -v node_modules   # 期望无输出
```

#### 第 4 步：本地预览

```bash
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml logs -f    # 出现 Local: http://localhost:5173... 即成功
```

#### 第 5 步：首次提交并推送

```bash
git add -A
git commit -m "chore: 初始化 <目录> 文档站"
git push -u origin main      # 第一次必须带 -u，之后 git push 即可
```

> 推送被拒（`[rejected] non-fast-forward`）说明 Codeup 仓库里已经有内容（建仓时勾了初始化 README）。
> 清空那个仓库后重推；确认里面没有有用内容时也可以 `git push -u origin main --force`。

#### 第 6 步：部署（方式 A：Docker，推荐）

项目里已经有了 `deploy/Dockerfile`（多阶段构建：Node 里 `pnpm docs:build` → nginx 托管静态文件）
和 `deploy/docker-compose.yml`，把项目拷到服务器后一条命令起站：

```bash
cd <目录>                                      # ← 服务器上的项目目录
docker compose -f deploy/docker-compose.yml up -d --build

docker compose -f deploy/docker-compose.yml ps        # 状态
docker compose -f deploy/docker-compose.yml logs -f   # 日志
```

默认映射宿主机 `8080` 端口，访问 `http://<服务器>:8080`。要换端口就改 `deploy/docker-compose.yml` 里的 `"8080:80"`。

以后更新文档：在服务器上 `git pull` 后重跑同一条 `up -d --build` 即可（镜像里重新构建，无需手工装 Node / pnpm）。

> 也可以在本机或流水线里 `docker build -f deploy/Dockerfile -t <镜像名>:<tag> .`，推到私有 registry，
> 服务器上 `docker pull` 后重启；适合「构建机与运行机分开」的场景。

#### 第 6 步：部署（方式 B：nginx，可选）

仅当服务器上已经有 nginx、不想再跑容器时用（第 2 步要加 `--deploy nginx --web-root <服务器目录>`，
或事后在项目根目录用 `--in-place` 重跑一次补生成）。

1. 改 `deploy/nginx.conf` 里两行：

```nginx
server {
    listen 80;
    server_name notes.example.com;      # ← 改成你的域名或内网 IP
    root /data/www/<目录>;              # ← 与 --web-root 一致
    ...
}
```

2. 拷到服务器并生效（`<服务器用户>` / `<服务器>` 换实际值）：

```bash
scp deploy/nginx.conf <服务器用户>@<服务器>:/tmp/docs.conf
ssh <服务器用户>@<服务器> 'sudo mv /tmp/docs.conf /etc/nginx/conf.d/docs.conf && sudo nginx -t && sudo nginx -s reload'
```

3. 以后每次发版（构建 + 同步一步到位）：

```bash
bash scripts/deploy.sh      # pnpm install --frozen-lockfile && pnpm docs:build && rsync 到 WEB_ROOT
```

> 想临时换目标目录：`WEB_ROOT=/srv/www/<目录> bash scripts/deploy.sh`。
> 服务器上需要有 `rsync`；没有就装（`sudo apt install -y rsync`），或者干脆用第 6 步 A 的 Docker 方式。

#### 第 7 步：验证

```bash
# 方式 A（Docker，默认 8080）
curl -I http://<服务器>:8080/                            # 期望 200
curl -s http://<服务器>:8080/ | grep -c 'assets/app'     # 期望 1（有资源引用，不是裸 HTML）

# 方式 B（nginx）
curl -I http://notes.example.com/                        # ← 换实际地址，期望 200
```

#### 附：不想 clone 进当前目录？

用 `--dir` 模式在指定路径生成一份新项目，模板目录保持干净（下面在模板目录里执行）：

```bash
bash scripts/init-private-site.sh --dir ../<目录> \
  --name "<站点名>" --base / --deploy docker \
  --repo git@codeup.aliyun.com:<组>/<仓库名>.git
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

### 方式四：只要脚手架，不关联任何仓库（清掉 git 痕迹）

适用场景：先把站点搭起来、在自己机器上写文档，托放到哪里以后再说；或者项目干脆不进版本库（本地/离线）。
产物特征：**没有任何 remote、没有历史提交、没有 `.github/`**，但 `site.ts`、文档骨架、部署脚本都已就位。

#### 第 1 步（做法 A，推荐）：clone 后就地改造，一把清干净

```bash
# <目录> 换成你的项目路径，例如 ~/work/notes；必须不存在或为空
mkdir -p <目录> && cd <目录>
git clone git@github.com:Chungtow/vitepress-note-starter.git .

bash scripts/init-private-site.sh --in-place \
  --name "<站点名>" \
  --base / \
  --reset-git            # ← 关键：不加这一项，origin 仍然是 GitHub 那个地址
```

只克隆一次、原地改完，步骤最少。`--reset-git` 会把 `.git` 整个删掉并重新 `git init -b main`，
GitHub 的 remote 和提交历史一起消失，而工作区文件一个不少（含 `scripts/`、`site.ts`、文档骨架）。

#### 第 1 步（做法 B）：`--dir` 模式，从外部生成一份

不想让 `.git` 哪怕短暂存在（比如目标目录以后要并进别的仓库），就从外部生成：

```bash
# 1) 把模板克隆到临时目录（只为拿到生成脚本，用完即删）
git clone --depth 1 git@github.com:Chungtow/vitepress-note-starter.git /tmp/tpl
cd /tmp/tpl

# 2) 生成脚手架：不传 --repo，就完全不会配远端
#    --dir    ← 目标路径（不存在会自动创建），下例写在临时模板同级
#    --name   ← 站点名
#    --base   ← 部署路径，根目录写 /；子路径写 /<子路径>/
#    --deploy ← 可选：docker / nginx；不加则只生成站点
bash scripts/init-private-site.sh --dir ../<目录> \
  --name "<站点名>" \
  --base /

# 3) 删掉临时模板，进入生成好的项目（路径与第 2 步 --dir 的值对应）
rm -rf /tmp/tpl
cd ../<目录>
```

比做法 A 多两步，换来「模板与产物彻底分离」：模板只在 `/tmp/tpl` 存在、用完即删；
新项目里只有 `git init` 出来的空仓库，文件已 `git add`，**没有远端、没有提交**。

#### 第 2 步：验证确实干净了

```bash
git remote -v                          # 期望：没有任何输出
git log --oneline 2>/dev/null          # 期望：fatal ... does not have any commits yet
ls -d .github 2>/dev/null || echo "无 .github"    # 期望：无 .github
grep -E "base|title" docs/.vitepress/site.ts      # 期望：你刚填的值
```

#### 第 3 步：本地先写起来

```bash
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml logs -f    # 出现 Local: http://localhost:5173/ 即可
```

#### 以后想接仓库 / 想部署了

```bash
# 接仓库（Codeup / GitLab / 自建都行）
# <你的仓库地址> 例：git@codeup.aliyun.com:<组>/<仓库名>.git
git remote add origin <你的仓库地址>
git add -A
git commit -m "chore: 初始化文档站"
git push -u origin main

# 补部署文件：在项目根目录用 --in-place 重跑一次
# ⚠️ 会重新生成 site.ts 与文档骨架，自己写的内容先提交或备份
bash scripts/init-private-site.sh --in-place --name "<站点名>" \
  --base / --deploy nginx --web-root /data/www/<目录>
```

#### 附：常见问题

| 现象 | 原因与解决 |
| --- | --- |
| `git remote -v` 还显示 GitHub 地址 | 用了 `--in-place` 却漏了 `--reset-git`；加了重跑，或手动 `git remote remove origin` |
| `git log` 里有模板的提交记录 | 同上，历史没清；`--reset-git` 才会重建 `.git` |
| 想留几篇示例文档参考写法 | 加 `--keep-samples`（保留 Markdown / Mermaid 示例页） |
| 不想让脚本新建 `main` 分支 | 无需处理；想要别的分支名 `git branch -m <分支名>` 即可 |

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

> 本节针对方式一/方式二（GitHub Pages）。方式三、方式四都不用 GitHub：方式三看它自带的
> `deploy/`（nginx 配置或 Dockerfile）与 `scripts/deploy.sh`；方式四默认不带部署文件，
> 需要时按「方式四 → 以后想接仓库 / 想部署了」补上。

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
