# 部署上线说明

站点由 `.github/workflows/deploy.yml` 自动构建并发布到 GitHub Pages：**推送到 `main` 分支就自动上线**，不需要本地构建、也不需要提交 `dist`。

:::: tip 不用 GitHub Pages？用私有项目模式
搬进云效 Codeup / GitLab / 内网服务器时，在模板根目录执行：

```bash
bash scripts/init-private-site.sh --dir ../hcp-notes --name "HCP 业务文档" \
     --base / --deploy nginx --repo git@codeup.aliyun.com:mygroup/hcp-notes.git
```

它会剥离 `.github/`、生成填好的 `site.ts`，并附上 `deploy/nginx.conf` + `scripts/deploy.sh`
（或 `--deploy docker` 生成多阶段 Dockerfile）。详见仓库根目录 `README.md`。
::::


::: tip 流水线不用改
模板已按最新 GitHub Pages Actions 写好（`configure-pages@v5` / `upload-pages-artifact@v3` / `deploy-pages@v4`），
权限（`contents: read`、`pages: write`、`id-token: write`）和并发（`group: pages`）都配好了。
:::

## 一、确认 base 路径

打开 `content/.vitepress/site.ts`，改 `base` 常量：

| 仓库类型 | 仓库名示例 | 访问地址 | `base` 写法 |
| --- | --- | --- | --- |
| 普通仓库 | `my-notes` | `https://用户名.github.io/my-notes/` | `'/my-notes/'` |
| 用户主页仓库 | `用户名.github.io` | `https://用户名.github.io/` | `'/'` |

::: danger base 配错的症状
页面能打开，但样式全丢（白底黑字裸 HTML）、图片 404、控制台一堆 `/assets/...` 或 `/<错误前缀>/assets/...` 找不到。
改完必须重新推送一次，流水线重新构建才会生效。
:::

## 二、GitHub 侧设置（一次性）

只有三项，且都在仓库 **Settings** 里，具体位置与「不做的后果」见 [GitHub 仓库设置](/guide/github-setup)：

1. **Settings → Pages → Build and deployment → Source** 选 **GitHub Actions**；
2. **Settings → General → Default branch** 确认为 **main**；
3. **Settings → General → Template repository** 勾选（仅模板仓库所有者需要）。

> **从 Fork 来的仓库**还要去 **Actions** 标签页点一次
> *"I understand my workflows, go ahead and enable them"*，否则工作流不会运行。

做完后随便改点东西推送即可触发：

```bash
git add .
git commit -m "docs: 写第一篇笔记"
git push origin main
```

::: warning 开启 Pages 不会补跑失败的运行
如果 Pages 是在运行失败之后才开启的，历史运行仍然是红的，需要手动再触发一次：
Actions → `Deploy VitePress to GitHub Pages` → **Run workflow**，或对旧运行点 **Re-run all jobs**。
:::

## 三、上线后在哪看地址

- **Settings → Pages** 顶部横幅：`Your site is live at https://用户名.github.io/仓库名/`；
- **Actions → 选中运行 → deploy job**：顶部 `github-pages` environment 链接 / **View deployment**；
- 直接按「一、确认 base 路径」里的地址规则访问（部署成功后才不是 404）。

三条路径指向同一个地址，细节见 [GitHub 仓库设置](/guide/github-setup)。

## 四、本地构建预览（可选）

想在上线前确认产物没问题：

```bash
cd docker
docker compose run --rm site sh -c "pnpm install && pnpm build"
# 构建产物在 content/.vitepress/dist/（宿主机目录，可直接看）
```

或者本机有 Node 环境时：

```bash
pnpm build
pnpm preview
```

## 五、自定义域名（可选）

1. 在 `content/public/` 下新增 `CNAME` 文件，内容写你的域名（不带 `https://`）；
2. 把 `content/.vitepress/site.ts` 的 `base` 改成 `'/'`；
3. 在仓库 **Settings → Pages → Custom domain** 里填同一个域名；
4. 域名服务商处添加 CNAME 记录指向 `用户名.github.io`。

## 六、常见部署失败原因

| 现象 | 原因 | 解决 |
| --- | --- | --- |
| Actions 里没有运行记录 | Fork 仓库未启用工作流 | Actions 页手动 Enable |
| `配置 Pages` 步骤失败（`Get Pages site failed`） | Pages 没启用，或 Source 选成了分支模式 | Settings → Pages 选 GitHub Actions 后重跑 |
| 构建失败 `lockfile` 相关 | 本地改了依赖但没提交 `pnpm-lock.yaml` | 提交 lockfile，或本地执行 `pnpm install` 后再提交 |
| 页面样式丢失 | `base` 与仓库名不一致 | 按上面表格改 `base` 后重新推送 |
| 部署成功但 404 | 访问地址写错 / 仓库为 Private 且免费计划 | 核对地址；Pages 需公开仓库或升级计划 |
| 推了但没触发 | 推到了 `master` 而不是 `main` | 切换分支或改默认分支，见 [GitHub 仓库设置](/guide/github-setup) |
