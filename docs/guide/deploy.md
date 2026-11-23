# 部署上线说明

站点由 `.github/workflows/deploy.yml` 自动构建并发布到 GitHub Pages：**推送到 `main` 分支就自动上线**，不需要本地构建、也不需要提交 `dist`。

::: tip 流水线不用改
模板已按最新 GitHub Pages Actions 写好（`configure-pages@v5` / `upload-pages-artifact@v3` / `deploy-pages@v4`），
你需要做的只有下面两步仓库设置。
:::

## 第一步：确认 base 路径

打开 `docs/.vitepress/config.mts`，改 `BASE` 常量：

| 仓库类型 | 仓库名示例 | 访问地址 | `BASE` 写法 |
| --- | --- | --- | --- |
| 普通仓库 | `my-notes` | `https://用户名.github.io/my-notes/` | `'/my-notes/'` |
| 用户主页仓库 | `用户名.github.io` | `https://用户名.github.io/` | `'/'` |

::: danger base 配错的症状
页面能打开，但样式全丢（白底黑字裸 HTML）、图片 404、控制台一堆 `/assets/...` 或 `/<错误前缀>/assets/...` 找不到。
改完必须重新推送一次，流水线重新构建才会生效。
:::

## 第二步：开启 Pages 与 Actions

在仓库页面上操作（只需做一次）：

1. **Settings → Pages → Build and deployment → Source** 选择 **GitHub Actions**；
2. **Settings → Actions → General → Workflow permissions** 确认允许运行工作流（默认即可）；
3. 如果是 **Fork** 来的仓库，先去 **Actions** 标签页点一次
   *"I understand my workflows, go ahead and enable them"* —— **Fork 仓库的 Actions 默认是关闭的**，不点这一步永远不会自动部署。

做完后随便改点东西推送：

```bash
git add .
git commit -m "docs: 写第一篇笔记"
git push origin main
```

在 **Actions** 标签页能看到 `Deploy VitePress to GitHub Pages` 的运行记录，绿色勾出现后，
**Settings → Pages** 顶部会显示站点地址。

## 三种使用方式对比

| 方式 | 适合 | 特点 |
| --- | --- | --- |
| **Use this template**（推荐） | 从零开始写自己的笔记 | 得到一个干净的新仓库，历史、Star 都不带走，可以设为 Private |
| **Fork** | 想保留与原模板的派生关系 | Fork 后必须手动开启 Actions；不想公开笔记时注意仓库可见性 |
| 下载 ZIP 后手动 push | 不使用 GitHub 仓库关系 | 最自由，需要自己 `git init` 并建远程仓库 |

::: warning Use this template 与 Fork 的关键差别
- Use this template 生成的仓库：Actions 默认**可用**（但仍需把 Pages Source 设成 GitHub Actions）；
- Fork 的仓库：Actions 默认**停用**，必须手动启用。
:::

## 本地构建预览（可选）

想在上线前确认产物没问题：

```bash
cd docker
docker compose run --rm docs sh -c "pnpm install && pnpm docs:build"
# 构建产物在 docs/.vitepress/dist/（宿主机目录，可直接看）
```

或者本机有 Node 环境时：

```bash
pnpm docs:build
pnpm docs:preview
```

## 自定义域名（可选）

1. 在 `docs/public/` 下新增 `CNAME` 文件，内容写你的域名（不带 `https://`）；
2. 把 `docs/.vitepress/config.mts` 的 `BASE` 改成 `'/'`；
3. 在仓库 **Settings → Pages → Custom domain** 里填同一个域名；
4. 域名服务商处添加 CNAME 记录指向 `用户名.github.io`。

## 常见部署失败原因

| 现象 | 原因 | 解决 |
| --- | --- | --- |
| Actions 里没有运行记录 | Fork 仓库未启用工作流 | Actions 页手动 Enable |
| `Get Pages site failed` | Pages Source 没设成 GitHub Actions | Settings → Pages 改一次 |
| 构建失败 `lockfile` 相关 | 本地改了依赖但没提交 `pnpm-lock.yaml` | 提交 lockfile，或本地执行 `pnpm install` 后再提交 |
| 页面样式丢失 | `BASE` 与仓库名不一致 | 按上面表格改 `BASE` 后重新推送 |
| 部署成功但 404 | 仓库为 Private 且账号为免费计划 | Pages 需要公开仓库，或升级计划 |
