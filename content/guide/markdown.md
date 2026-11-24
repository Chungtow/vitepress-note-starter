# Markdown 写法示例

这一页把所有常用写法都摆出来，写笔记时直接复制改就行。

## 标题与段落

用 `#` 到 `######` 表示标题层级，**一页只写一个一级标题**（VitePress 会用它作为页面标题和侧边栏文字）。

正文里可以 **加粗**、*斜体*、~~删除线~~、`行内代码`，也可以插入 [站内链接](/guide/) 和 [外部链接](https://vitepress.dev)。

## 提示容器

::: tip 提示
适合写补充说明、使用建议。
:::

::: info 信息
适合写背景知识。
:::

::: warning 注意
适合写容易踩坑的地方。
:::

::: danger 危险
适合写不可逆操作（删数据、强推分支之类）。
:::

::: details 点击展开（折叠块）
适合放长日志、长代码。
:::

## 代码块

````md
```js{1,3}
function hello(name) {
  // 高亮第 1、3 行
  console.log(`Hello, ${name}`)
}
```
````

实际效果：

```js{1,3}
function hello(name) {
  // 高亮第 1、3 行
  console.log(`Hello, ${name}`)
}
```

其他常用语言：`bash`、`sql`、`yaml`、`json`、`java`、`python`、`typescript`、`diff`。

## 表格

| 编辑器 | 适合场景 | 备注 |
| --- | --- | --- |
| VS Code | 日常笔记 | 推荐，纯文本可版本化 |
| Obsidian | 知识网络 | 双链写法需自己加插件 |
| Typora | 长文写作 | 所见即所得 |

## 列表

无序列表：

- 第一项
- 第二项
  - 嵌套项
  - 嵌套项

有序列表：

1. 先写配置文件
2. 再写文档
3. 最后推送部署

## 任务列表

- [x] 初始化仓库
- [x] 配置 VitePress
- [ ] 写满一百篇笔记

## 图片

图片放在 `content/public/` 下，用绝对路径引用（会自动拼上 base，部署到子路径也不会 404）：

```md
![站点 Logo](/logo.svg)
```

![站点 Logo](/logo.svg)

相对路径也可以：`![](../public/logo.svg)`，但推荐上面的写法。

## 引用与分割线

> 好记性不如烂笔头。
>
> —— 某个前辈

---

## Frontmatter

每篇文档开头可以用 `---` 包裹一段配置：

```md
---
title: 自定义页面标题
description: 供搜索引擎使用的描述
outline: deep
---
```

- `outline: deep` 让右侧目录显示到四、五级标题；
- 不写 frontmatter 也能正常工作。

## Emoji 与特殊字符

VitePress 默认支持 GitHub 风格 emoji 短代码，例如 `:tada:` → :tada:、`:rocket:` → :rocket:。
