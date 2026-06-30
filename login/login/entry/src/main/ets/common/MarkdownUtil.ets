/**
 * Markdown 转 HTML 工具
 * 用于将 AI 回复的 Markdown 文本转换为 RichText 可渲染的 HTML
 */
export class MarkdownUtil {
  /**
   * 将 Markdown 转换为 HTML
   * 支持：加粗、代码块、行内代码、列表、标题、换行
   */
  static toHtml(markdown: string): string {
    if (!markdown) {
      return ''
    }

    let html = markdown

    // 过滤 <think>...</think> 标签内容
    html = html.replace(/<think>[\s\S]*?<\/think>/g, '')

    // 1. 转义 HTML 特殊字符（先处理，避免后续标签被转义）
    html = html.replace(/&/g, '&amp;')
    html = html.replace(/</g, '&lt;')
    html = html.replace(/>/g, '&gt;')

    // 2. 代码块 ```...```  →  <pre><code>...</code></pre>
    html = html.replace(/```[\s\S]*?```/g, (match) => {
      const code = match.substring(3, match.length - 3).replace(/^\w*\n/, '')
      return `<pre style="background-color:#f5f5f5;padding:8px;border-radius:4px;overflow-x:auto;"><code>${code}</code></pre>`
    })

    // 3. 标题 ### / ## / #
    html = html.replace(/^###\s+(.+)$/gm, '<h3>$1</h3>')
    html = html.replace(/^##\s+(.+)$/gm, '<h2>$1</h2>')
    html = html.replace(/^#\s+(.+)$/gm, '<h1>$1</h1>')

    // 4. 加粗 **text**  →  <b>text</b>
    html = html.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>')

    // 5. 行内代码 `code`  →  <code>code</code>
    html = html.replace(/`(.+?)`/g, '<code style="background-color:#f0f0f0;padding:2px 4px;border-radius:3px;">$1</code>')

    // 6. 无序列表 - item  →  <ul><li>item</li></ul>
    const lines = html.split('\n')
    let result = ''
    let inList = false
    for (const line of lines) {
      const trimmed = line.trim()
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        if (!inList) {
          result += '<ul style="margin:4px 0;padding-left:20px;">'
          inList = true
        }
        result += `<li>${trimmed.substring(2)}</li>`
      } else {
        if (inList) {
          result += '</ul>'
          inList = false
        }
        // 空行转为换行
        if (trimmed === '') {
          result += '<br/>'
        } else {
          result += trimmed + '<br/>'
        }
      }
    }
    if (inList) {
      result += '</ul>'
    }

    // 用外层 div 包裹，统一字体大小和颜色
    return `<div style="font-size:14px;color:#333;line-height:1.5;">${result}</div>`
  }
}
