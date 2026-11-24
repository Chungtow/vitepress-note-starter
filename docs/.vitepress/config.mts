import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
// 中文分词器（同目录 search-tokenize.ts，本地搜索依赖它，不用改）
import { tokenize } from './search-tokenize'

// =============================================================================
// 📌 整个模板里【唯一需要你修改的文件】就是这一个
// -----------------------------------------------------------------------------
// 只改下面标注【TODO】的 5 处，站点就能跑起来并自动部署上线：
//   1) BASE        —— 仓库 base 路径（最容易配错，必看注释）
//   2) 站点标题/描述
//   3) nav         —— 顶部导航
//   4) sidebar     —— 左侧侧边栏
//   5) socialLinks —— GitHub 链接
// 其余配置（搜索、Mermaid、主题语言包）都已经调好，不用动。
//
// 修改后无需重启 dev server，VitePress 会自动重载配置。
// =============================================================================

// -----------------------------------------------------------------------------
// 【TODO 1】仓库 base 路径 —— 必须与仓库名对应，首尾斜杠都不能少
// -----------------------------------------------------------------------------
// 场景 A：普通仓库（仓库名 vitepress-note-starter）
//   访问地址：https://<你的用户名>.github.io/vitepress-note-starter/
//   正确写法：const BASE = '/vitepress-note-starter/'
//
// 场景 B：用户主页仓库（仓库名必须是 <你的用户名>.github.io）
//   访问地址：https://<你的用户名>.github.io/
//   正确写法：const BASE = '/'
//
// ⚠️ 配错的典型症状：页面能打开但完全没有样式（白底黑字的裸 HTML），
//    控制台报一堆 404，资源路径都带错了前缀。
const BASE = '/vitepress-note-starter/'

export default withMermaid(
  defineConfig({
    // -------------------------------------------------------------------------
    // 【TODO 2】站点基础信息
    // -------------------------------------------------------------------------
    lang: 'zh-CN',
    title: '我的笔记', // 站点标题：浏览器标签页、左上角站点名
    titleTemplate: ':title | 我的笔记', // 子页面标题格式，显示为「页面名 | 我的笔记」
    description: '一个基于 VitePress 的个人笔记站点', // 供搜索引擎使用的站点描述
    base: BASE,

    // 站点图标：放在 docs/public/ 下的文件可以直接用 /xxx 引用
    head: [['link', { rel: 'icon', type: 'image/svg+xml', href: `${BASE}logo.svg` }]],

    // 开启「上次更新」：需要完整 git 历史（CI 里已配置 fetch-depth: 0）。
    // 本地用 Docker 挂载 .git 时，如果报 dubious ownership，用 lastUpdated 需要额外配置，
    // 所以模板默认关闭，想要就取消注释。
    // lastUpdated: true,

    // 尾部带 .html 的链接更保险：GitHub Pages 对 cleanUrls 支持不完整，模板不开启。
    // cleanUrls: true,

    // 允许出现指向不存在页面的链接（新手写笔记时不会被死链卡住构建）
    ignoreDeadLinks: true,

    markdown: {
      lineNumbers: true, // 代码块显示行号
      image: { lazyLoading: true } // 图片懒加载
    },

    // 生成站点地图（可选，需要填自己的域名）
    // sitemap: { hostname: 'https://<你的用户名>.github.io' },

    // -------------------------------------------------------------------------
    // 本地开发服务器（只影响 dev，不影响构建产物）
    // -------------------------------------------------------------------------
    vite: {
      optimizeDeps: {
        // mermaid 是运行时才 import 的，Vite 启动扫描发现不了它，
        // 于是它内部的 CJS 子依赖（fastdom、dayjs 等）会被原样发给浏览器，
        // 浏览器报 "does not provide an export named 'default'" → 页面白屏。
        // 显式放进预打包列表即可（与插件自带的 include 合并）。
        include: ['mermaid']
      },
      server: {
        // Vite 5.4.12+ 默认只允许 localhost / 127.0.0.1 / IP 直连访问，
        // 用局域网主机名访问（如 http://manager:5173/）会报：
        //   Blocked request. This host ("manager") is not allowed.
        // 这里放开 Host 校验，方便容器内 + 局域网域名访问。
        // 只想放行特定域名时改成数组：allowedHosts: ['manager', '.example.com']
        allowedHosts: true
      }
    },

    // Mermaid 图表：全局默认配置，需要时改这里
    mermaid: {
      // 例：theme: 'dark'，更多配置 https://mermaid.js.org/config/schema-docs/config.html
    },
    mermaidPlugin: {
      class: 'mermaid' // 图表容器的 class，方便自定义样式
    },

    themeConfig: {
      // 左上角 logo（文件在 docs/public/logo.svg）
      logo: '/logo.svg',

      // -----------------------------------------------------------------------
      // 【TODO 3】顶部导航：新增页面时在这里加一项
      //   text 显示文字，link 以 / 开头的站点内路径（会自动拼上 base）
      // -----------------------------------------------------------------------
      nav: [
        { text: '首页', link: '/' },
        { text: '使用指南', link: '/guide/' },
        { text: '我的笔记', link: '/notes/' },
        // 外部链接直接写完整 URL
        { text: 'GitHub', link: 'https://github.com/Chungtow/vitepress-note-starter' }
      ],

      // -----------------------------------------------------------------------
      // 【TODO 4】左侧侧边栏：按目录前缀分组，写笔记时只需要往下加 item
      //   '/guide/' 表示「所有以 /guide/ 开头的页面都用这一组侧边栏」
      //   注意 link 结尾有无斜杠要和文件名对应：
      //     /guide/       -> docs/guide/index.md
      //     /guide/markdown -> docs/guide/markdown.md
      // -----------------------------------------------------------------------
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
      },

      // -----------------------------------------------------------------------
      // 本地搜索（默认开启，纯前端、不需要任何第三方服务）
      // -----------------------------------------------------------------------
      search: {
        provider: 'local',
        options: {
          // 中文分词：MiniSearch 默认按空格/标点切词，中文没有空格会搜不到句中词，
          // 这里用「汉字双字滑窗」切分（实现在 search-tokenize.ts，无需改动）。
          miniSearch: {
            options: { tokenize },
            searchOptions: {
              fuzzy: 0.2, // 容错度；纯英文站可改 0 减少误召回
              prefix: true, // 前缀匹配：输 dock 能中 docker
              boost: { title: 4, text: 2, titles: 1 } // 标题命中权重更高
            }
          },
          translations: {
            button: { buttonText: '搜索文档', buttonAriaLabel: '搜索文档' },
            modal: {
              noResultsText: '找不到相关结果',
              resetButtonTitle: '清除查询条件',
              footer: {
                selectText: '选择',
                navigateText: '切换',
                closeText: '关闭'
              }
            }
          }
        }
      },

      // 右侧「本页目录」层级
      outline: { level: [2, 3], label: '本页目录' },

      // 中文化：默认主题的零散文案
      docFooter: { prev: '上一篇', next: '下一篇' },
      lastUpdated: { text: '最后更新于' },
      returnToTopLabel: '回到顶部',
      sidebarMenuLabel: '目录',
      darkModeSwitchLabel: '主题',
      lightModeSwitchTitle: '切换到深色模式',
      darkModeSwitchTitle: '切换到浅色模式',
      langMenuLabel: '语言',
      externalLinkIcon: true,

      // -----------------------------------------------------------------------
      // 【TODO 5】右上角社交链接（图标只支持内置名字，如 github / x / discord）
      // -----------------------------------------------------------------------
      socialLinks: [
        { icon: 'github', link: 'https://github.com/Chungtow/vitepress-note-starter' }
      ],

      // 页脚（可选）
      footer: {
        message: '基于 VitePress 构建，托管于 GitHub Pages',
        copyright: 'Copyright © 2026'
      },

      // 页面底部「在 GitHub 上编辑此页」（可选，需要填自己的仓库地址）
      // editLink: {
      //   pattern: 'https://github.com/<你的用户名>/<仓库名>/edit/main/docs/:path',
      //   text: '在 GitHub 上编辑此页'
      // }
    }
  })
)
