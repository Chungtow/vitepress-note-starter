/**
 * =============================================================================
 * 📌 站点身份配置 —— 换成你自己的站点，只改这一个文件
 * -----------------------------------------------------------------------------
 * 另一个文件 config.mts 是「框架配置」（Mermaid、本地搜索、中文文案），
 * 正常不需要动。需要改的只有下面这几段：
 *   1) base        —— 访问路径前缀（最容易配错，见注释）
 *   2) title 系列  —— 站点标题 / 描述
 *   3) nav         —— 顶部导航
 *   4) sidebar     —— 左侧侧边栏
 *   5) socialLinks —— 右上角社交图标（不需要就留空数组）
 *
 * 换私有项目/内网部署时，跑 `bash scripts/init-private-site.sh --help` 可以
 * 直接生成一份填好的本文件，不用手改。
 * =============================================================================
 */
import type { DefaultTheme } from 'vitepress'

export const site = {
  // ---------------------------------------------------------------------------
  // 【1】base —— 必须与实际访问路径一致，首尾斜杠都不能少
  // ---------------------------------------------------------------------------
  // · 部署在域名根目录（nginx 直接把站根指到 dist）     → '/'
  // · 部署在子路径（如 https://xxx.com/hcp-notes/）      → '/hcp-notes/'
  // · GitHub Pages 普通仓库（https://用户名.github.io/repo/）→ '/repo/'
  //
  // ⚠️ 配错的典型症状：页面能打开但完全没有样式（白底黑字的裸 HTML），
  //    控制台一堆 /assets/... 404。
  base: '/vitepress-note-starter/',

  // ---------------------------------------------------------------------------
  // 【2】站点基础信息
  // ---------------------------------------------------------------------------
  lang: 'zh-CN',
  title: '我的笔记', // 浏览器标签页、左上角站点名
  titleTemplate: ':title | 我的笔记', // 子页面标题显示为「页面名 | 我的笔记」
  description: '一个基于 VitePress 的个人笔记站点', // 供搜索引擎/内网检索使用

  // 左上角 logo：文件放在 docs/public/ 下，这里写 /文件名即可
  logo: '/logo.svg',

  // ---------------------------------------------------------------------------
  // 【3】顶部导航：新增页面时在这里加一项
  //   text 显示文字；link 以 / 开头的站点内路径（会自动拼上 base）
  // ---------------------------------------------------------------------------
  nav: [
    { text: '首页', link: '/' },
    { text: '使用指南', link: '/guide/' },
    { text: '我的笔记', link: '/notes/' },
    // 外部链接直接写完整 URL
    { text: 'GitHub', link: 'https://github.com/Chungtow/vitepress-note-starter' }
  ] as DefaultTheme.NavItem[],

  // ---------------------------------------------------------------------------
  // 【4】左侧侧边栏：按目录前缀分组，写笔记时只需要往下加 item
  //   '/guide/' 表示「所有以 /guide/ 开头的页面都用这一组侧边栏」
  //   注意 link 结尾有无斜杠要和文件名对应：
  //     /guide/          -> docs/guide/index.md
  //     /guide/markdown  -> docs/guide/markdown.md
  // ---------------------------------------------------------------------------
  sidebar: {
    '/guide/': [
      {
        text: '使用指南',
        items: [
          { text: '总览与快速开始', link: '/guide/' },
          { text: 'Markdown 写法示例', link: '/guide/markdown' },
          { text: 'Mermaid 图表示例', link: '/guide/mermaid' },
          { text: '部署上线说明', link: '/guide/deploy' },
          { text: 'GitHub 仓库设置（一次性）', link: '/guide/github-setup' }
        ]
      }
    ],
    '/notes/': [
      {
        text: '我的笔记',
        items: [
          { text: '笔记索引', link: '/notes/' },
          { text: '示例笔记', link: '/notes/demo' }
        ]
      }
    ]
  } as DefaultTheme.Sidebar,

  // ---------------------------------------------------------------------------
  // 【5】右上角社交链接（图标只支持内置名字，如 github / x / discord）
  //   私有项目里没有公开仓库时，改成空数组 [] 即可整块消失
  // ---------------------------------------------------------------------------
  socialLinks: [
    { icon: 'github', link: 'https://github.com/Chungtow/vitepress-note-starter' }
  ] as DefaultTheme.SocialLink[],

  // 页脚（不需要就把 message / copyright 删掉）
  footer: {
    message: '基于 VitePress 构建，托管于 GitHub Pages',
    copyright: 'Copyright © 2026'
  }
}
