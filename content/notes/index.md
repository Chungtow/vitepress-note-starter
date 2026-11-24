# 笔记索引

这里放你自己的笔记。`content/notes/` 只是模板给的一个示例目录，可以按自己的习惯自由拆分，例如：

```text
content/notes/
├── index.md            # 你正在看的这个索引页
├── 2026/
│   ├── 01.md
│   └── 02.md
├── backend/
│   ├── mysql.md
│   └── redis.md
└── tools/
    └── git.md
```

::: tip 目录约定
- 每新增一个目录，可以在 `content/.vitepress/site.ts` 的 `sidebar` 里加一组；
- 不想维护侧边栏，也可以直接不用 sidebar（改成 `sidebar: false` 或删掉该配置），只用导航 + 搜索；
- `index.md` 是目录首页，访问 `/notes/` 时展示。
:::

## 示例笔记

- [示例笔记：如何组织个人知识库](/notes/demo) —— 展示了 frontmatter、代码块、表格、提示块等写法

## 自己的清单

- [ ] 删掉这页里的示例内容
- [ ] 按自己的分类建目录
- [ ] 把 `site.ts` 里的站点标题、导航改成自己的
