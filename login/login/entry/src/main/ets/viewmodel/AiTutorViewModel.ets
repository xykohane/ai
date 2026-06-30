import { ChatMessage } from '../model/ChatMessage'
import { http } from '@kit.NetworkKit'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * AI伴学助手 ViewModel
 * 用于通用技术问答，解释概念，配合代码示例
 */

interface DifyChatRequest {
  inputs: Record<string, string>
  query: string
  response_mode: string
  user: string
  conversation_id: string
  files: DifyFileItem[]
  auto_generate_name: boolean
}

interface DifyFileItem {
  type: string
  transfer_method: string
  url: string
  upload_file_id: string
}

interface DifyChatResponse {
  event: string
  task_id: string
  id: string
  message_id: string
  conversation_id: string
  mode: string
  answer: string
  created_at: number
}

interface DifyStreamEvent {
  event: string
  answer?: string
  conversation_id?: string
  message_id?: string
  task_id?: string
  id?: string
}

interface DifyStopRequest {
  user: string
}

interface ThinkFilterResult {
  answer: string
  inThinkBlock: boolean
}

const DIFY_USER: string = 'student-001'
const THINK_OPEN: string = '<think>'
const THINK_CLOSE: string = '</think>'

@Observed
export class AiTutorViewModel {
  messages: ChatMessage[] = []
  sending: boolean = false
  conversationId: string = ''
  private taskId: string = ''

  // AI伴学助手配置
  private difyApiKey: string = 'app-4LrB63xNTKO7m2JDzYqX0AI2'
  private difyBaseUrl: string = 'http://10.0.2.2/v1'

  async sendMessage(content: string): Promise<void> {
    const userMsg: ChatMessage = {
      role: 'user',
      content: content,
      timestamp: Date.now()
    }
    this.messages.push(userMsg)

    const aiMsg: ChatMessage = {
      role: 'assistant',
      content: '',
      timestamp: Date.now()
    }
    this.messages.push(aiMsg)

    this.sending = true
    try {
      await this.callDifyStreaming(content, aiMsg)
    } catch (err) {
      const error = err as BusinessError
      aiMsg.content = this.parseErrorMessage(error)
    } finally {
      this.sending = false
    }
  }

  private async callDifyStreaming(message: string, aiMsg: ChatMessage): Promise<void> {
    const httpRequest = http.createHttp()
    const textDecoder = util.TextDecoder.create('utf-8')

    try {
      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        const chunk = textDecoder.decodeWithStream(new Uint8Array(data))
        const lines = chunk.split('\n')
        for (const line of lines) {
          const trimmed = line.trim()
          if (!trimmed.startsWith('data:')) {
            continue
          }
          const jsonStr = trimmed.substring(5).trim()
          if (!jsonStr) {
            continue
          }
          try {
            const event = JSON.parse(jsonStr) as DifyStreamEvent
            this.handleStreamEvent(event, aiMsg)
          } catch (e) {
            // 忽略解析失败的行
          }
        }
      })

      // 不 await，让请求在后台执行，dataReceive 回调实时更新 UI
      httpRequest.request(
        `${this.difyBaseUrl}/chat-messages`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.difyApiKey}`
          },
          extraData: JSON.stringify(this.buildRequestBody(message, 'streaming')),
          connectTimeout: 30000,
          readTimeout: 120000
        }
      ).then(() => {
        // 请求完成后，如果还没有内容则走阻塞模式兜底
        if (!aiMsg.content) {
          this.callDifyBlocking(message).then((content: string) => {
            aiMsg.content = content
          })
        }
      }).catch((err: Error) => {
        if (!aiMsg.content) {
          aiMsg.content = this.parseErrorMessage(err as BusinessError)
        }
      })
    } finally {
      // 延迟销毁，给 dataReceive 回调留出处理时间
      setTimeout(() => {
        httpRequest.destroy()
      }, 1000)
    }
  }

  private handleStreamEvent(
    event: DifyStreamEvent,
    aiMsg: ChatMessage
  ): void {
    switch (event.event) {
      case 'message':
        // 先累积原始内容，等 message_end 再统一过滤 think 标签
        if (event.answer) {
          aiMsg.content += event.answer
        }
        break
      case 'message_end':
        if (event.conversation_id) {
          this.conversationId = event.conversation_id
        }
        if (event.task_id) {
          this.taskId = event.task_id
        }
        // 消息结束后统一过滤 <think>...</think> 思考过程
        aiMsg.content = this.filterThinkTags(aiMsg.content)
        break
      case 'message_replace':
        if (event.answer) {
          aiMsg.content = event.answer
        }
        break
      case 'error':
        aiMsg.content = 'AI 回复异常，请稍后重试'
        break
      case 'ping':
        break
      default:
        break
    }
  }

  /**
   * 过滤 think 标签内容
   */
  private filterThinkTags(content: string): string {
    if (!content) {
      return ''
    }
    let result = ''
    let i = 0
    let inThink = false

    while (i < content.length) {
      if (inThink) {
        const endIdx = content.indexOf(THINK_CLOSE, i)
        if (endIdx !== -1) {
          inThink = false
          i = endIdx + THINK_CLOSE.length
        } else {
          break
        }
      } else {
        const startIdx = content.indexOf(THINK_OPEN, i)
        if (startIdx !== -1) {
          result += content.substring(i, startIdx)
          const endIdx = content.indexOf(THINK_CLOSE, startIdx)
          if (endIdx !== -1) {
            i = endIdx + THINK_CLOSE.length
          } else {
            inThink = true
            break
          }
        } else {
          result += content.substring(i)
          break
        }
      }
    }

    return result
  }

  private async callDifyBlocking(message: string): Promise<string> {
    const httpRequest = http.createHttp()
    try {
      const response = await httpRequest.request(
        `${this.difyBaseUrl}/chat-messages`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.difyApiKey}`
          },
          extraData: JSON.stringify(this.buildRequestBody(message, 'blocking')),
          connectTimeout: 30000,
          readTimeout: 120000
        }
      )
      const result = JSON.parse(response.result as string) as DifyChatResponse
      if (result.conversation_id) {
        this.conversationId = result.conversation_id
      }
      if (result.task_id) {
        this.taskId = result.task_id
      }
      return this.filterThinkTags(result.answer || '未收到回复')
    } finally {
      httpRequest.destroy()
    }
  }

  private buildRequestBody(query: string, responseMode: string): DifyChatRequest {
    const body: DifyChatRequest = {
      inputs: {} as Record<string, string>,
      query: query,
      response_mode: responseMode,
      user: DIFY_USER,
      conversation_id: this.conversationId,
      files: [],
      auto_generate_name: true
    }
    return body
  }

  async stopResponse(): Promise<void> {
    if (!this.taskId) {
      return
    }
    const httpRequest = http.createHttp()
    try {
      await httpRequest.request(
        `${this.difyBaseUrl}/chat-messages/${this.taskId}/stop`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.difyApiKey}`
          },
          extraData: JSON.stringify({ user: DIFY_USER } as DifyStopRequest),
          connectTimeout: 10000,
          readTimeout: 10000
        }
      )
    } finally {
      httpRequest.destroy()
    }
  }

  private parseErrorMessage(error: BusinessError): string {
    const code = error.code || 0
    const message = error.message || ''
    const msgLower = message.toLowerCase()

    if (msgLower.includes('invalid_param')) {
      return '请求参数异常，请检查输入'
    }
    if (msgLower.includes('app_unavailable')) {
      return '应用配置不可用，请联系管理员'
    }
    if (msgLower.includes('provider_not_initialize')) {
      return '模型凭据未配置，请联系管理员'
    }
    if (msgLower.includes('provider_quota_exceeded')) {
      return '模型额度不足，请联系管理员'
    }
    if (msgLower.includes('model_currently_not_support')) {
      return '当前模型不可用，请稍后重试'
    }
    if (msgLower.includes('workflow_not_found')) {
      return '工作流版本未找到'
    }
    if (msgLower.includes('completion_request_error')) {
      return 'AI 生成回复失败，请稍后重试'
    }
    if (code === 404 || msgLower.includes('404')) {
      return '对话不存在，请刷新后重试'
    }
    if (code === 401 || msgLower.includes('401') || msgLower.includes('unauthorized')) {
      return '认证失败，请检查 API Key 配置'
    }
    if (code === 500 || msgLower.includes('500')) {
      return '服务内部异常，请稍后重试'
    }
    return `请求失败：${message || '请稍后重试'}`
  }

  clearMessages(): void {
    this.messages = []
    this.conversationId = ''
    this.taskId = ''
  }
}
