# =============================================================================
# 本地开发用镜像：只预置 Node 22 + pnpm，不安装、不打包 VitePress 本体
# -----------------------------------------------------------------------------
# 说明：
#   1. 站点源码不 COPY 进镜像，而是由 docker-compose.yml 把仓库根目录挂载到 /app，
#      这样容器内改代码 = 宿主改代码，热更新正常，镜像也可以长期复用。
#   2. 因此本文件很少有改动，改了依赖版本才需要 `--build` 重新构建。
# =============================================================================
FROM node:22-bookworm-slim

# -----------------------------------------------------------------------------
# 构建参数：国内网络环境可换成更快的基础镜像源，或指定其他 pnpm 版本
#   docker compose build --build-arg NPM_REGISTRY=https://registry.npmjs.org
# -----------------------------------------------------------------------------
ARG PNPM_VERSION=10.34.9
ARG NPM_REGISTRY=https://registry.npmmirror.com

ENV TZ=Asia/Shanghai \
    NPM_CONFIG_REGISTRY=${NPM_REGISTRY} \
    PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH

# 系统依赖：git 必须有
#   VitePress 的「最后更新于」会执行 `git log -1` 取文件时间戳，
#   镜像里缺 git 时每个 .md 页面都会 500（浏览器里表现为 404 / 空白），
#   报错长这样：Error: spawn git ENOENT。
# apt 源换成阿里云，内网/国内网络下更稳（Debian 12 用 deb822 格式的 debian.sources）
RUN set -eux; \
    for f in /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources; do \
        if [ -f "$f" ]; then \
            sed -i 's|deb.debian.org|mirrors.aliyun.com|g; s|security.debian.org|mirrors.aliyun.com|g' "$f"; \
        fi; \
    done; \
    apt-get update; \
    apt-get install -y --no-install-recommends git ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# 安装 pnpm（用 npm 全局装比 corepack 更稳，国内 CI / 本机都不容易失败）
RUN npm install -g pnpm@${PNPM_VERSION} \
    && pnpm config set registry ${NPM_REGISTRY} --global \
    && npm cache clean --force \
    && pnpm --version

WORKDIR /app

# VitePress 默认端口
EXPOSE 5173

# 默认命令：启动 dev server（带 --host 0.0.0.0，见 package.json 的 `dev` 脚本）
# 容器外通过 http://localhost:5173 访问
CMD ["pnpm", "dev"]
