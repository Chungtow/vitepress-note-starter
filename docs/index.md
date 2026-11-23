---
# 首页布局：hero（头图区）+ features（特性卡片）
# 想改成普通文档页，把 layout: home 删掉即可
layout: home
# 浏览器标签页标题：config 里配了 titleTemplate，不写这行会显示成「我的笔记 | 我的笔记」
title: 首页

hero:
  name: 我的笔记
  text: 基于 VitePress 的个人知识库
  tagline: Docker 本地开发 · 推送即部署 · 本地搜索 · Mermaid 图表
  image:
    src: /logo.svg
    alt: 站点 Logo
  actions:
    - theme: brand
      text: 快速开始
      link: /guide/
    - theme: alt
      text: 看示例笔记
      link: /notes/demo

features:
  - title: 只改一个配置文件
    details: 站点标题、导航、侧边栏全在 docs/.vitepress/config.mts，关键位置都写了中文注释。
  - title: 本机只需要 Docker + Git
    details: Node 22 + pnpm 跑在容器里，不用在本机装任何前端环境，环境不会互相污染。
  - title: 推送 main 自动上线
    details: 内置 GitHub Actions 工作流，构建并发布到 GitHub Pages，模板用户无需改流水线。
  - title: 写作体验优先
    details: 本地搜索、代码高亮、深色模式、Mermaid 流程图、Markdown 扩展语法开箱可用。
---
