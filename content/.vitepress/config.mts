import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
// 中文分词器（同目录 search-tokenize.ts，本地搜索依赖它，不用改）
import { tokenize } from './search-tokenize'
// 站点身份（标题 / base / 导航 / 侧边栏 / 页脚）都从这里来
import { site } from './site'

// =============================================================================
// 📌 框架配置 —— 正常【不需要修改】这个文件
// -----------------------------------------------------------------------------
// 站点标题、base 路径、导航、侧边栏、页脚等「属于你自己」的东西，全在
// 同目录的 site.mts 里（那是唯一需要改的文件）。
//
// 本文件只放框架级配置：Mermaid 插件、本地搜索（含中文分词）、
// 中文文案、dev server 行为、Markdown 渲染选项。
//
// 修改后无需重启 dev server，VitePress 会自动重载配置。
// =============================================================================

export default withMermaid(
  defineConfig({
    // 站点身份：统一来自 site.mts，改那里就行
    lang: site.lang,
    title: site.title,
    titleTemplate: site.titleTemplate,
    description: site.description,
    base: site.base,

    // 站点图标：放在 content/public/ 下的文件可以直接用 /xxx 引用
    head: [['link', { rel: 'icon', type: 'image/svg+xml', href: `${site.base}logo.svg` }]],

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
    // sitemap: { hostname: 'https://notes.example.com' },

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
      // 例：theme: 'dark'，更多配置 https://mermaid.js.org/config/schema-content/config.html
    },
    mermaidPlugin: {
      class: 'mermaid' // 图表容器的 class，方便自定义样式
    },

    themeConfig: {
      // 以下四项都来自 site.mts
      logo: site.logo,
      nav: site.nav,
      sidebar: site.sidebar,

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

      // 右上角社交链接与页脚（来自 site.ts；不需要就把 site.ts 里对应字段删掉）
      socialLinks: site.socialLinks,
      footer: site.footer,

      // 页面底部「在仓库上编辑此页」（可选，需要填自己的仓库地址，GitHub / Codeup 都行）
      // editLink: {
      //   pattern: 'https://codeup.aliyun.com/<组>/<仓库>/blob/main/content/:path',
      //   text: '在 Codeup 上编辑此页'
      // }
    }
  })
)
