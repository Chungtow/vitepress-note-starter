import DefaultTheme from 'vitepress/theme'
import type { Theme } from 'vitepress'

/**
 * 自定义主题入口。
 *
 * 模板默认不需要改这里：VitePress 默认主题 + vitepress-plugin-mermaid 已由
 * config.mts 配置好（Mermaid 组件由插件自动注入，无需在此注册）。
 *
 * 以后想扩展时可以这样加：
 *
 *   import MyComponent from './components/MyComponent.vue'
 *   import './custom.css'
 *
 *   export default {
 *     extends: DefaultTheme,
 *     enhanceApp({ app }) {
 *       app.component('MyComponent', MyComponent)
 *     }
 *   } satisfies Theme
 */
export default {
  extends: DefaultTheme
} satisfies Theme
