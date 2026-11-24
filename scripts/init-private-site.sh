#!/usr/bin/env bash
# =============================================================================
# init-private-site.sh —— 把本模板生成一个「不含 GitHub 依赖」的私有文档站项目
# -----------------------------------------------------------------------------
# 为什么需要它：
#   模板默认面向 GitHub Pages（.github/workflows、base 按仓库名、社交图标指向
#   公开仓库、示例文档讲 Pages 设置）。把模板搬进私有项目（Codeup/GitLab/内网）
#   时，这些都要手工删改，而且 base 配错会白屏。
#   本脚本把这些动作固化下来：一条命令得到「配置已填好、没有 GitHub 痕迹、
#   文档目录是空的、附带你选的部署方式」的新项目。
#
# 用法（在模板仓库根目录执行）：
#   bash scripts/init-private-site.sh --dir ../hcp-notes --name "HCP 业务文档" \
#        --deploy nginx --repo git@codeup.aliyun.com:group/hcp-notes.git
#
# 就地改造当前仓库（已经是模板 clone，不想再复制一份）：
#   bash scripts/init-private-site.sh --in-place --name "HCP 业务文档" --base /
#
# 参数说明见 --help。脚本无第三方依赖（rsync 缺失时自动退回 cp），可重复执行。
# =============================================================================
set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TARGET_DIR=""
IN_PLACE=0
SITE_NAME="我的文档"
SITE_DESC="内部业务文档"
BASE_PATH="/"
REPO_URL=""
DEPLOY_MODE="none"   # none | nginx | docker
WEB_ROOT=""
KEEP_SAMPLES=0
KEEP_GITHUB=0
RESET_GIT=0
FORCE=0

die()  { printf '错误：%s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m▸\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }

usage() {
  cat <<'EOF'
把 vitepress-note-starter 生成为一个私有文档站项目（默认剥离全部 GitHub 相关文件）

用法：
  bash scripts/init-private-site.sh --dir <目标目录> [选项]
  bash scripts/init-private-site.sh --in-place [选项]

必填（二选一）：
  --dir <路径>        新建一个项目目录（不存在会自动创建）
  --in-place          不复制，直接改造当前这个模板仓库

站点身份：
  --name <站点名>     默认「我的文档」
  --desc <描述>       默认「内部业务文档」
  --base <前缀>       base 路径，默认 '/'（部署在域名根目录）；子路径写 /hcp-notes/

仓库：
  --repo <地址>       可选。关联的私有仓库地址（Codeup/GitLab 均可），会写成 origin。
                      不传就不关联任何仓库：--dir 模式下天然没有远端；
                      --in-place 模式下会沿用克隆来的 origin（GitHub），需要清掉请加 --reset-git
  --reset-git         可选。就地改造时清空 git 历史并重新 init（默认保留历史与原 remote）
  --keep-github       保留 .github/workflows（默认删除，私有项目用不到）

内容：
  --keep-samples      保留模板示例文档（Markdown 写法、Mermaid 示例等）
                      默认清空示例，只生成一份空文档骨架

部署（脚本会额外生成对应文件）：
  --deploy none       默认：只生成站点，构建产物自己拷
  --deploy nginx      生成 deploy/nginx.conf + scripts/deploy.sh（构建并 rsync 到服务器目录）
  --web-root <路径>   nginx 模式的服务器目录，默认 /data/www/<项目名>
  --deploy docker     生成 deploy/Dockerfile（多阶段构建）+ nginx.conf + docker-compose.yml

其他：
  --force             目标目录非空时先清空再生成
  -h, --help          显示本帮助

示例：
  # 私有业务文档站，内网 nginx 部署
  bash scripts/init-private-site.sh --dir ../hcp-notes --name "HCP 业务文档" \
       --deploy nginx --web-root /data/www/hcp-notes

  # 容器化部署
  bash scripts/init-private-site.sh --dir ../hcp-notes --deploy docker

  # 就地改造 + 换远程仓库
  bash scripts/init-private-site.sh --in-place --name "HCP 业务文档" --base / \
       --repo git@codeup.aliyun.com:mygroup/hcp-notes.git --reset-git
EOF
}

# ---------------------------------------------------------------------------
# 参数解析
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)           TARGET_DIR="${2:-}"; shift 2 ;;
    --in-place)      IN_PLACE=1; shift ;;
    --name)          SITE_NAME="${2:-}"; shift 2 ;;
    --desc)          SITE_DESC="${2:-}"; shift 2 ;;
    --base)          BASE_PATH="${2:-}"; shift 2 ;;
    --repo)          REPO_URL="${2:-}"; shift 2 ;;
    --deploy)        DEPLOY_MODE="${2:-}"; shift 2 ;;
    --web-root)      WEB_ROOT="${2:-}"; shift 2 ;;
    --keep-samples)  KEEP_SAMPLES=1; shift ;;
    --keep-github)   KEEP_GITHUB=1; shift ;;
    --reset-git)     RESET_GIT=1; shift ;;
    --force)         FORCE=1; shift ;;
    -h|--help)       usage; exit 0 ;;
    *)               die "未知参数：$1（用 --help 查看用法）" ;;
  esac
done

# ---------------------------------------------------------------------------
# 参数校验与归一化
# ---------------------------------------------------------------------------
[[ -n "$SITE_NAME" ]] || die "--name 不能为空"
case "$DEPLOY_MODE" in
  none|nginx|docker) ;;
  *) die "--deploy 只支持 none / nginx / docker，收到：$DEPLOY_MODE" ;;
esac

# base 归一化：补上首尾斜杠，避免白屏这类低级事故
[[ "$BASE_PATH" == /* ]] || BASE_PATH="/$BASE_PATH"
[[ "$BASE_PATH" == */ ]] || BASE_PATH="$BASE_PATH/"

if [[ $IN_PLACE -eq 1 && -n "$TARGET_DIR" ]]; then
  die "--dir 和 --in-place 只能二选一"
fi
[[ $IN_PLACE -eq 1 || -n "$TARGET_DIR" ]] || die "必须指定 --dir <目标目录> 或 --in-place（--help 看用法）"

if [[ $IN_PLACE -eq 1 ]]; then
  WORK_DIR="$TEMPLATE_DIR"
  PROJECT_NAME="$(basename "$WORK_DIR")"
else
  # 目标目录转成绝对路径（先按当前目录解析，再补建）
  case "$TARGET_DIR" in
    /*) ;;
    *) TARGET_DIR="$PWD/$TARGET_DIR" ;;
  esac
  WORK_DIR="$TARGET_DIR"
  PROJECT_NAME="$(basename "$WORK_DIR")"

  if [[ "$WORK_DIR" == "$TEMPLATE_DIR" ]]; then
    die "目标目录就是模板目录本身；想就地改造请用 --in-place"
  fi
  if [[ -d "$WORK_DIR" && -n "$(ls -A "$WORK_DIR" 2>/dev/null || true)" ]]; then
    [[ $FORCE -eq 1 ]] || die "目标目录非空：$WORK_DIR（确认要覆盖请加 --force）"
    warn "清空已存在的目录：$WORK_DIR"
    rm -rf "${WORK_DIR:?}/"* "${WORK_DIR:?}/".[!.]* 2>/dev/null || true
  fi
fi

[[ -n "$WEB_ROOT" ]] || WEB_ROOT="/data/www/$PROJECT_NAME"

# ---------------------------------------------------------------------------
# 1. 复制模板（就地模式跳过）
# ---------------------------------------------------------------------------
if [[ $IN_PLACE -eq 0 ]]; then
  info "复制模板到 $WORK_DIR"
  mkdir -p "$WORK_DIR"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a \
      --exclude '.git' --exclude 'node_modules' --exclude '.pnpm-store' \
      --exclude 'content/.vitepress/dist' --exclude 'content/.vitepress/cache' \
      --exclude 'private' --exclude 'docker/.env' \
      "$TEMPLATE_DIR/" "$WORK_DIR/"
  else
    warn "没装 rsync，退回 tar 管道复制（已排除依赖与产物）"
    tar -C "$TEMPLATE_DIR" \
        --exclude='./.git' --exclude='./node_modules' --exclude='./.pnpm-store' \
        --exclude='./content/.vitepress/dist' --exclude='./content/.vitepress/cache' \
        --exclude='./private' --exclude='./docker/.env' \
        -cf - . | tar -C "$WORK_DIR" -xf -
  fi
  ok "模板已复制"
else
  info "就地改造：$WORK_DIR"
fi

cd "$WORK_DIR"

# ---------------------------------------------------------------------------
# 2. 剥离 GitHub 依赖
# ---------------------------------------------------------------------------
if [[ $KEEP_GITHUB -eq 0 ]]; then
  rm -rf .github
  ok "已删除 .github/（GitHub Pages 流水线）"
else
  warn "保留 .github/：仅当你要继续用 GitHub Pages 时才需要"
fi

# 模板自带的 GitHub 专属文档页（与站点主题无关，直接删）
rm -f content/guide/github-setup.md content/guide/deploy.md

# ---------------------------------------------------------------------------
# 3. 生成 site.ts（站点身份，脚本负责填好）
# ---------------------------------------------------------------------------
EXTRA_SIDEBAR=""
if [[ $KEEP_SAMPLES -eq 1 ]]; then
  EXTRA_SIDEBAR=$',\n          { text: \'Markdown 写法示例\', link: \'/guide/markdown\' },\n          { text: \'Mermaid 图表示例\', link: \'/guide/mermaid\' }'
  # 模板自带的这两页讲的是 GitHub Pages，删掉后把 index 里的残留链接一起去掉
  sed -i 's# · \[部署上线说明\](/guide/deploy)##g; s# · \[GitHub 仓库设置（一次性）\](/guide/github-setup)##g' content/guide/index.md || true
  sed -i '/\/guide\/deploy\|\/guide\/github-setup/d' content/notes/index.md 2>/dev/null || true
else
  # 不保留示例时，把这些示例页删掉（guide/index.md 稍后重写）
  rm -f content/guide/markdown.md content/guide/mermaid.md
  rm -rf content/notes
  EXTRA_SIDEBAR=$',\n          { text: \'写作规范\', link: \'/guide/writing\' }'
fi

info "生成 content/.vitepress/site.ts"
cat > content/.vitepress/site.ts <<EOF
/**
 * =============================================================================
 * 站点身份配置 —— 换成你自己的站点，只改这一个文件
 * -----------------------------------------------------------------------------
 * 由 scripts/init-private-site.sh 于 $(date '+%Y-%m-%d %H:%M') 生成。
 * 另一个文件 config.mts 是框架配置（Mermaid、本地搜索、中文文案），不用动。
 * =============================================================================
 */
import type { DefaultTheme } from 'vitepress'

export const site = {
  // 访问路径前缀：部署在域名根目录写 '/'；挂在子路径（如 /notes/）写 '/notes/'
  base: '$BASE_PATH',

  lang: 'zh-CN',
  title: '$SITE_NAME',
  titleTemplate: ':title | $SITE_NAME',
  description: '$SITE_DESC',
  logo: '/logo.svg',

  // 顶部导航
  nav: [
    { text: '首页', link: '/' },
    { text: '文档', link: '/guide/' }
  ] as DefaultTheme.NavItem[],

  // 左侧侧边栏：按目录前缀分组，新增页面时往下加 item
  sidebar: {
    '/guide/': [
      {
        text: '文档',
        items: [
          { text: '总览', link: '/guide/' }$EXTRA_SIDEBAR
        ]
      }
    ]
  } as DefaultTheme.Sidebar,

  // 私有项目通常没有公开仓库，留空即可让右上角图标整块消失
  socialLinks: [] as DefaultTheme.SocialLink[],

  footer: {
    message: '$SITE_DESC',
    copyright: 'Copyright © $(date +%Y)'
  }
}
EOF
ok "site.ts 已生成（base=$BASE_PATH，标题=$SITE_NAME）"

# ---------------------------------------------------------------------------
# 4. 文档骨架（不保留示例时重写成空白站点）
# ---------------------------------------------------------------------------
if [[ $KEEP_SAMPLES -eq 0 ]]; then
  info "生成文档骨架"
  mkdir -p content/guide
  cat > content/index.md <<EOF
---
layout: home
# 浏览器标签页标题：site.ts 配了 titleTemplate，不写这行会显示成「站点名 | 站点名」
title: 首页

hero:
  name: $SITE_NAME
  text: $SITE_DESC
  tagline: 用 Markdown 写作，保存即提交，推送即发布
  actions:
    - theme: brand
      text: 开始阅读
      link: /guide/
    - theme: alt
      text: 写作规范
      link: /guide/writing
---
EOF

  cat > content/guide/index.md <<EOF
# $SITE_NAME

$SITE_DESC。左侧侧边栏按目录分组，右侧是当前页的目录。

## 目录约定

\`\`\`text
content/
├── index.md          # 首页
├── guide/
│   ├── index.md      # 本页
│   └── writing.md    # 写作规范
└── public/           # 图片等静态资源，用 /图片名 引用
\`\`\`

## 新增一页文档

1. 在 \`content/guide/\` 下新建 \`xxx.md\`；
2. 在 \`content/.vitepress/site.ts\` 的 \`sidebar\` 里加一行
   \`{ text: '页面标题', link: '/guide/xxx' }\`；
3. 保存后开发服务器自动热更新，无需重启。

## 支持的写法

- 代码块带行号、复制按钮；支持 \`\`\`bash / \`\`\`json 等语法高亮。
- Mermaid 流程图、时序图直接写在 \`\`\`mermaid 代码块里。
- 提示块：\`::: tip\` / \`::: warning\` / \`::: danger\`。
- 中文全文搜索：按 \`Ctrl K\`，支持句中词（如搜「侧边栏」）。
EOF

  cat > content/guide/writing.md <<'EOF'
# 写作规范

> 这一页是给你自己改的：把团队的标题层级、术语、截图要求写进来，
> 让所有人提交的文档看起来像同一个人写的。

## 约定

| 项 | 约定 |
| --- | --- |
| 一级标题 | 每页只用一次，等于页面标题 |
| 标题层级 | 从 `##` 开始，最多到 `###`（右侧目录只显示这两级） |
| 代码块 | 必须标语言，命令给完整可复制的形式 |
| 截图 | 放 `content/public/images/`，引用写 `/images/xxx.png` |
| 链接 | 站内页面用 `/guide/xxx` 形式，不要写完整 URL |

## 提交习惯

```bash
git add content
git commit -m "docs: 补充 XX 流程说明"
git push
```
EOF
  ok "文档骨架已生成（content/index.md、content/guide/index.md、content/guide/writing.md）"
fi

# ---------------------------------------------------------------------------
# 4.5 重写 README（模板 README 讲的是 GitHub 模板用法，私有项目里没意义）
# ---------------------------------------------------------------------------
info "重写 README.md"
cat > README.md <<EOF
# $PROJECT_NAME

$SITE_DESC。基于 [VitePress](https://vitepress.dev/) 的静态文档站，
Markdown 写作 → 保存即热更新 → 构建成纯静态 HTML。

## 目录结构

\`\`\`text
$PROJECT_NAME/
├── content/                   # ★ 文档内容全部在这里
│   ├── .vitepress/
│   │   ├── site.ts           # ★ 唯一需要改的配置（标题 / base / 导航 / 侧边栏）
│   │   ├── config.mts         # 框架配置（搜索、Mermaid、中文文案），不用动
│   │   └── theme/index.ts     # 主题入口（已继承默认主题）
│   ├── public/                # 图片等静态资源，用 /文件名 引用
│   ├── index.md               # 首页
│   └── guide/                 # 文档正文
├── docker/                    # 本地开发容器（Node 22 + pnpm）
├── scripts/init-private-site.sh   # 生成脚本，留作参考/重生成
└── package.json
\`\`\`

## 本地开发（只需要 Docker）

\`\`\`bash
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml logs -f    # 出现 Local: http://localhost:5173$BASE_PATH 即可访问
\`\`\`

本机装了 Node 22 + pnpm 也可以直接：

\`\`\`bash
pnpm install
pnpm dev      # http://localhost:5173$BASE_PATH
pnpm build    # 产物在 content/.vitepress/dist/
pnpm preview
\`\`\`

## 新增一页文档

1. 新建 \`content/guide/xxx.md\`，第一行写 \`# 标题\`；
2. 到 \`content/.vitepress/site.ts\` 的 \`sidebar\` 里加 \`{ text: '标题', link: '/guide/xxx' }\`；
3. 保存即可，dev 服务器自动热更新。

## 部署

$(case "$DEPLOY_MODE" in
  nginx) printf '构建并同步到 nginx 目录（目录见 scripts/deploy.sh 里的 WEB_ROOT）：\n\n```bash\nbash scripts/deploy.sh\n```\n\nnginx 配置见 `deploy/nginx.conf`。';;
  docker) printf '容器化部署（构建 + 启动 nginx）：\n\n```bash\ndocker compose -f deploy/docker-compose.yml up -d --build\n```\n\n访问 `http://<服务器IP>:8080`。';;
  *) printf '构建产物在 `content/.vitepress/dist/`，整个目录拷到任意静态服务器即可。';;
esac)

## 注意

- \`site.ts\` 里的 \`base\` 必须与实际访问路径一致（域名根目录写 \`/\`，
  挂在子路径写 \`/子路径/\`），配错会白屏。
- \`content/.vitepress/dist/\`、\`node_modules/\` 不要提交（已在 \`.gitignore\` 里）。
- 中文全文搜索已内置（\`Ctrl K\` 可搜句中词），无需额外服务。
EOF
ok "README.md 已重写"

# ---------------------------------------------------------------------------
# 5. 部署文件
# ---------------------------------------------------------------------------
gen_nginx_conf() {  # $1 = 目标文件, $2 = root 路径
  cat > "$1" <<EOF
# nginx 站点配置：放到 /etc/nginx/conf.d/<项目名>.conf 后
#   sudo nginx -t && sudo nginx -s reload
server {
    listen 80;
    server_name notes.example.com;   # ← 改成实际域名或内网 IP

    root $2;
    index index.html;

    # VitePress 生成的是 xxx.html 静态页，cleanUrls 关闭
    location / {
        try_files \$uri \$uri/ \$uri.html /404.html;
    }

    # 静态资源长缓存（文件名带 hash，可放心缓存）
    location /assets/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    error_page 404 /404.html;
}
EOF
}

case "$DEPLOY_MODE" in
  nginx)
    info "生成 nginx 部署文件"
    mkdir -p deploy scripts
    gen_nginx_conf deploy/nginx.conf "$WEB_ROOT"
    cat > scripts/deploy.sh <<'EOF'
#!/usr/bin/env bash
# 构建站点并同步到 nginx 目录（在项目根目录执行：bash scripts/deploy.sh）
set -euo pipefail
cd "$(dirname "$0")/.."

WEB_ROOT="${WEB_ROOT:-@@WEB_ROOT@@}"
SRC="content/.vitepress/dist"

echo "▸ 安装依赖"
pnpm install --frozen-lockfile

echo "▸ 构建"
pnpm build

echo "▸ 同步到 $WEB_ROOT"
mkdir -p "$WEB_ROOT"
rsync -a --delete "$SRC/" "$WEB_ROOT/"

echo "✓ 完成：$(date '+%F %T')，产物已更新到 $WEB_ROOT"
EOF
    sed -i "s|@@WEB_ROOT@@|$WEB_ROOT|g" scripts/deploy.sh
    chmod +x scripts/deploy.sh
    ok "deploy/nginx.conf + scripts/deploy.sh（目标目录 $WEB_ROOT）"
    ;;
  docker)
    info "生成 Docker 部署文件"
    mkdir -p deploy
    cat > deploy/Dockerfile <<'EOF'
# 多阶段构建：node 里构建 → nginx 里托管（运行时镜像只有静态文件）
# 构建：docker build -f deploy/Dockerfile -t site:latest .
FROM node:22-bookworm-slim AS build
ARG NPM_REGISTRY=https://registry.npmmirror.com
WORKDIR /app
ENV NPM_CONFIG_REGISTRY=$NPM_REGISTRY
# 系统依赖：git（VitePress 计算最后更新时间时会调用）；apt 源切阿里云
RUN set -eux; \
    for f in /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources; do \
        [ -f "$f" ] && sed -i 's|deb.debian.org|mirrors.aliyun.com|g; s|security.debian.org|mirrors.aliyun.com|g' "$f"; \
    done; \
    apt-get update; apt-get install -y --no-install-recommends git ca-certificates; \
    rm -rf /var/lib/apt/lists/*
RUN npm install -g pnpm@10.34.9
COPY package.json pnpm-lock.yaml .npmrc ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM nginx:1.27-alpine
COPY --from=build /app/content/.vitepress/dist /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
EOF
    gen_nginx_conf deploy/nginx.conf "/usr/share/nginx/html"
    cat > deploy/docker-compose.yml <<'EOF'
# 用法（项目根目录）：docker compose -f deploy/docker-compose.yml up -d --build
services:
  site:
    build:
      context: ..
      dockerfile: deploy/Dockerfile
    image: site:latest
    container_name: site
    ports:
      - "8080:80"
    restart: unless-stopped
EOF
    ok "deploy/Dockerfile + deploy/nginx.conf + deploy/docker-compose.yml"
    ;;
  none)
    warn "未生成部署文件（--deploy none）。构建产物在 content/.vitepress/dist/，自行拷贝即可"
    ;;
esac

# 部署产物不进版本库（构建目录已被 .gitignore 忽略，这里补上镜像/临时文件）
grep -q '^# 部署临时文件' .gitignore 2>/dev/null || cat >> .gitignore <<'EOF'

# 部署临时文件
*.tar.gz
deploy/.env
EOF

# ---------------------------------------------------------------------------
# 6. git 初始化 / 换远端
# ---------------------------------------------------------------------------
if [[ $IN_PLACE -eq 1 && $RESET_GIT -eq 1 ]]; then
  rm -rf .git
  ok "已清空旧 git 历史"
fi

if [[ ! -d .git ]]; then
  git init -q -b main
  ok "已 git init（默认分支 main）"
fi

if [[ -n "$REPO_URL" ]]; then
  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$REPO_URL"
  else
    git remote add origin "$REPO_URL"
  fi
  ok "origin → $REPO_URL"
else
  CURRENT_ORIGIN="$(git remote get-url origin 2>/dev/null || true)"
  if [[ -n "$CURRENT_ORIGIN" ]]; then
    warn "未指定 --repo：origin 仍指向 $CURRENT_ORIGIN"
    warn "（想脱离原仓库就加 --repo <新地址>；只想彻底清掉远端与历史，加 --reset-git）"
  else
    warn "未指定 --repo：无任何远端（稍后自己 git remote add origin <地址> 即可）"
  fi
fi

git add -A >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------
# 7. 收尾提示
# ---------------------------------------------------------------------------
cat <<EOF

$(printf '\033[32m全部完成\033[0m')  项目目录：$WORK_DIR

下一步（三条命令）：
  cd $WORK_DIR
  docker compose -f docker/docker-compose.yml up -d    # 本地开发，浏览器开 http://localhost:5173$BASE_PATH
  git commit -m "chore: init $PROJECT_NAME" && git push -u origin main

部署：
EOF

case "$DEPLOY_MODE" in
  nginx)
    cat <<EOF
  1) 把 deploy/nginx.conf 放到服务器 /etc/nginx/conf.d/，改 server_name 与 root
  2) sudo nginx -t && sudo nginx -s reload
  3) 每次发版：bash scripts/deploy.sh
EOF
    ;;
  docker)
    cat <<EOF
  1) docker compose -f deploy/docker-compose.yml up -d --build
  2) 访问 http://<服务器IP>:8080
EOF
    ;;
  *)
    cat <<EOF
  构建产物在 content/.vitepress/dist/，用 rsync/nginx 自行托管
  （想要现成部署文件就重跑脚本并加 --deploy nginx 或 --deploy docker）
EOF
    ;;
esac

cat <<EOF

要改站点标题/导航/侧边栏：编辑 content/.vitepress/site.ts（唯一需要改的文件）
EOF
