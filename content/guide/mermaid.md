# Mermaid 图表示例

模板已内置 [vitepress-plugin-mermaid](https://github.com/emersonbottero/vitepress-plugin-mermaid)，
直接写 ` ```mermaid ` 代码块即可渲染，不需要额外配置。

::: tip 语法
代码块语言标记写 `mermaid`，第一行声明图表类型（`flowchart`、`sequenceDiagram`、`gantt` 等）。
:::

## 流程图

````md
```mermaid
flowchart TD
    A[写笔记] --> B{本地预览}
    B -- 满意 --> C[git push]
    B -- 不满意 --> A
    C --> D[Actions 构建]
    D --> E[发布到 GitHub Pages]
```
````

效果：

```mermaid
flowchart TD
    A[写笔记] --> B{本地预览}
    B -- 满意 --> C[git push]
    B -- 不满意 --> A
    C --> D[Actions 构建]
    D --> E[发布到 GitHub Pages]
```

## 时序图

```mermaid
sequenceDiagram
    participant U as 用户
    participant C as Docker 容器
    participant V as VitePress
    U->>C: docker compose up -d --build
    C->>C: pnpm install
    C->>V: pnpm dev --host 0.0.0.0
    V-->>U: http://localhost:5173
    U->>V: 修改 content/xx.md
    V-->>U: 热更新，页面自动刷新
```

## 甘特图

```mermaid
gantt
    title 建站计划
    dateFormat  YYYY-MM-DD
    section 准备
    选模板           :done, a1, 2026-01-01, 1d
    改配置文件       :done, a2, after a1, 1d
    section 写作
    写前三篇笔记     :active, b1, after a2, 5d
    持续更新         :b2, after b1, 20d
```

## 类图

```mermaid
classDiagram
    class Note {
        +String title
        +String content
        +Date updatedAt
        +save()
    }
    class Category {
        +String name
    }
    Note "1" --> "*" Category
```

::: warning 图表里别用特殊符号
Mermaid 对 `()`、`[]`、`{}`、`;` 等字符敏感，节点文字里有特殊符号时用双引号包起来：
`A["文字（含括号）"] --> B`。
:::
