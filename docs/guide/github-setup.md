# GitHub 仓库设置（一次性）

新仓库上线前，GitHub 网页上只有几个开关要设，设完之后**写笔记就等于 `git push`**，不用再碰设置。

::: tip 只想赶紧上线
做完下面「三步设置」→ 去 Actions 手动 Run 一次 → 绿色勾出现后，站点地址就是
`https://<用户名>.github.io/<仓库名>/`（仓库名是 `<用户名>.github.io` 时没有后半段）。
:::

## 一、三步设置

| # | 位置 | 操作 | 不做的后果 |
| --- | --- | --- | --- |
| 1 | **Settings → Pages → Build and deployment → Source** | 选 **GitHub Actions**（不要选 "Deploy from a branch"） | 部署 job 报 `Get Pages site failed`，站点永远不上线 |
| 2 | **Settings → General → Default branch** | 确认为 **main** | 流水线只监听 `main`；推 `master` 不触发，仓库首页还会停留在旧提交 |
| 3 | **Settings → General → Template repository** | 勾选（**只有模板仓库的所有者需要做**） | 仓库页上没有 `Use this template` 按钮 |

> **从 Fork 来的仓库**还要多做一步：去 **Actions** 标签页点一次
> *"I understand my workflows, go ahead and enable them"*，否则工作流永远不跑。

::: warning 开启 Pages 不会补跑已经失败的运行
Pages 是在失败之后才开启的话，历史运行仍然是红的；需要**手动再触发一次**（见下面「四、手动触发」）。
:::

## 二、两种创建方式

| 方式 | 适合 | 特点 |
| --- | --- | --- |
| **Use this template**（推荐） | 从零开始写自己的笔记 | 干净的新仓库，不带走历史/Star，可以设为 Private，Actions 默认可用 |
| **Fork** | 想保留与原模板的派生关系 | Actions **默认停用**必须手动开；Pages 需要公开仓库（免费计划），不适合写私密笔记 |
| 下载 ZIP 后手动 push | 不使用 GitHub 仓库关系 | 最自由，需要自己 `git init` 并建远程仓库 |

### 「Use this template」按钮在哪

- 仓库主页 → 文件列表**上方那一行**、`<> Code` 按钮旁边的绿色 **Use this template**（**不在**右上角 Watch / Fork / Star 那一排，Fork 才在那里）；
- 直达链接：`https://github.com/<owner>/<repo>/generate`；
- 看不到按钮 = 该仓库没开模板功能，所有者去 **Settings → General → Template repository** 勾一次；
- 点开后选 **Create a new repository**（`Include all branches` 不用勾）。

## 三、Pages 地址在哪看

以下三处指向的是**同一个地址**，任选一处：

1. **Settings → Pages** 顶部横幅：`Your site is live at https://<用户名>.github.io/<仓库名>/`；
2. **Actions → 选中某次运行 → 点 deploy job**：顶部有 `github-pages` environment 链接与 **View deployment** 按钮；
3. 直接按规则拼地址访问（部署成功后才不是 404）：

| 仓库类型 | 地址 | `config.mts` 里的 `BASE` |
| --- | --- | --- |
| 普通仓库 `my-notes` | `https://用户名.github.io/my-notes/` | `'/my-notes/'` |
| 用户主页仓库 `<用户名>.github.io` | `https://用户名.github.io/` | `'/'` |
| 绑定自定义域名 | `https://你的域名/` | `'/'` |

> 域名里的用户名是小写；`BASE` 必须和仓库名一致，否则页面能打开但样式全丢，详见[部署上线说明](/guide/deploy)。

## 四、手动触发 / 重跑

- **手动触发**：Actions → 左侧选 `Deploy VitePress to GitHub Pages` → 右侧 **Run workflow** → 分支选 `main` → 绿色 **Run workflow**；
- **重跑旧运行**：进失败的运行 → 右上 **Re-run all jobs**（开启 Pages 后重跑同一个 commit 一样会成功）；
- **最省事**：改任意一篇文档 `git push` 到 `main`，自动触发。

没有 **Run workflow** 按钮时：刷新页面；或把 `.github/workflows/deploy.yml` 里的 `workflow_dispatch:` 保留在 `main` 分支上再试。

## 五、为什么卡在「配置 Pages」

| 现象 | 原因 | 解决 |
| --- | --- | --- |
| `配置 Pages` 失败，报 `Get Pages site failed` / `Not Found` | Pages 还没启用，或 Source 选成了分支模式 | 按「三步设置」第 1 条设置后重跑 |
| 整个运行根本没出现 | Fork 仓库 Actions 未启用 | Actions 页手动 Enable |
| `部署` 失败且提示仓库不可访问 | Private 仓库 + 免费账号 | 改公开仓库，或升级计划 |
| 部署成功但打开是 404 | 访问了错误的地址（如漏了仓库名） | 按「三、Pages 地址在哪看」的表核对 |

## 六、验证上线是否正常

1. Actions 里 `build` 与 `deploy` 两个 job 都变绿；
2. 打开 Pages 地址，能正常看到首页与导航（不是白底黑字的裸 HTML）；
3. 点几下侧边栏页面，刷新后不 404；
4. 之后每次 `git push` 到 `main`，约 1~2 分钟自动更新。

更细的部署原理、`base` 路径与自定义域名，见[部署上线说明](/guide/deploy)。
