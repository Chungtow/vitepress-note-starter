/**
 * 本地搜索的中文分词器（MiniSearch 的 tokenize）
 *
 * 为什么需要它：
 *   MiniSearch 默认按「换行 / 空白 / 标点」切词（/[\n\r\p{Z}\p{P}]+/u），中文没有空格，
 *   一整句会变成一个超长 token，导致「搜索」「侧边栏」这类句中词永远搜不到。
 *
 * 为什么用「双字滑窗」而不是先分词：
 *   Intl.Segmenter 的 ICU 词典并不全（实测「镜像」会被切成「镜」「像」、「预置」切成
 *   「预」「置」），按词切反而会把这些词弄丢，还得再补一层兜底。直接对连续汉字做
 *   双字滑窗（同 Lucene 的 CJKBigramFilter）就够了：不会漏词，代码更短，也不依赖
 *   ICU 版本，索引/查询两侧规则天然一致。
 *
 * ⚠️ 两条硬约束（改了会坏，别动）：
 *   1. 必须自包含：VitePress 会把这个函数 toString() 后注入 HTML，浏览器里用
 *      new Function 复活，函数外部的变量（含 import 进来的东西）全部拿不到；
 *   2. 必须短：源码会内联进每一个页面的 HTML（当前约 0.5 KB）。
 */

export function tokenize(text: string): string[] {
  const out = new Set<string>()
  // 去掉零宽字符（VitePress 会在标题里插入 \u200b），避免污染 token
  for (const chunk of text.replace(/[\u200b\ufeff]/g, ' ').split(/[\n\r\p{Z}\p{P}]+/u)) {
    if (!chunk) continue
    // 不含汉字（英文、数字、标识符）：整体小写收进去，保持原有检索行为
    if (!/\p{Script=Han}/u.test(chunk)) {
      out.add(chunk.toLowerCase())
      continue
    }
    // 连续汉字：双字滑窗（单字不收录——大多是「的/了/是」这类虚词，且会让索引暴涨）
    for (const run of chunk.match(/\p{Script=Han}{2,}/gu) ?? []) {
      for (let i = 0; i + 1 < run.length; i++) out.add(run.slice(i, i + 2))
    }
  }
  return [...out]
}
