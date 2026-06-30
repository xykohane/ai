import { ChatMessage } from '../model/ChatMessage'
import { http } from '@kit.NetworkKit'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * ===== Dify Chatflow API 类型定义 =====
 * 依据 DIFY_CHATFLOW_API.md 实现
 */

/**
 * 终端用户唯一标识（由业务侧定义，需保证在应用内唯一）
 */
const DIFY_USER: string = 'student-001'

/**
 * Dify chat-messages 请求体
 * 参考 DIFY_CHATFLOW_API.md §3.1
 */
interface DifyChatRequest {
  inputs: Record<string, string>   // App 定义变量键值对，默认 {}
  query: string                    // 用户输入或提问内容
  response_mode: string            // streaming 或 blocking
  user: string                     // 终端用户唯一标识
  conversation_id: string          // 继续已有会话时传入上一轮返回的会话 ID
  files: DifyFileItem[]            // 文件列表
  auto_generate_name: boolean      // 是否自动生成会话标题，默认 true
}

/**
 * Dify 文件项
 * 参考 DIFY_CHATFLOW_API.md §3.1 files 字段
 */
interface DifyFileItem {
  type: string                     // document、image、audio、video、custom
  transfer_method: string          // remote_url 或 local_file
  url: string                      // 远程文件地址，仅 remote_url 使用
  upload_file_id: string           // 上传文件 ID，仅 local_file 使用
}

/**
 * Dify chat-messages 阻塞模式响应
 * 参考 DIFY_CHATFLOW_API.md §3.1 Blocking Response
 */
interface DifyChatResponse {
  event: string                    // 固定为 message
  task_id: string                  // 任务 ID
  id: string                       // 唯一 ID
  message_id: string               // 消息唯一 ID
  conversation_id: string          // 会话 ID
  mode: string                     // App 模式，固定为 chat
  answer: string                   // 完整回复内容
  created_at: number               // 消息创建时间戳
}

/**
 * Dify 流式 SSE 事件数据结构
 * 参考 DIFY_CHATFLOW_API.md §3.1 Streaming Response
 */
interface DifyStreamEvent {
  event: string                    // 事件类型
  answer?: string                  // AI 回复片段（message 事件）
  conversation_id?: string         // 会话 ID（message_end 事件）
  message_id?: string              // 消息 ID（message_end 事件）
  task_id?: string                 // 任务 ID，可用于停止响应
  id?: string                      // 消息 ID（message 事件）
}

/**
 * Dify 错误响应
 * 参考 DIFY_CHATFLOW_API.md §3.1 错误码
 */
interface DifyErrorResponse {
  code: string                     // 错误码
  message: string                  // 错误描述
  status: number                   // HTTP 状态码
}

/**
 * Dify 停止响应请求体
 * 参考 DIFY_CHATFLOW_API.md §3.2
 */
interface DifyStopRequest {
  user: string                     // 终端用户唯一标识
}

/**
 * HTTP 请求头
 */
interface HttpRequestHeader {
  'Content-Type': string
  'Authorization': string
}

/**
 * HTTP 请求选项
 */
interface HttpRequestOptions {
  method: http.RequestMethod
  header: HttpRequestHeader
  extraData: string
  connectTimeout: number
  readTimeout: number
  expectDataType?: http.HttpDataType
  usingCache?: boolean
}

@Observed
export class ChatViewModel {
  messages: ChatMessage[] = []
  sending: boolean = false

  // ===== 课后作业 1：保存 conversation_id 实现多轮对话 =====
  conversationId: string = ''

  // 当前流式任务 ID，用于停止响应
  private taskId: string = ''

  // Dify 配置（AI 模拟面试官）
  // 注意：生产环境应通过后端代理，不在客户端保存 API Key
  private difyApiKey: string = 'app-0G519ZXObOaDRuJzY8OEvJYO'
  private difyBaseUrl: string = 'http://10.0.2.2/v1'

  /**
   * 发送消息
   */
  async sendMessage(content: string): Promise<void> {
    // ① 添加用户消息到列表
    const userMsg: ChatMessage = {
      role: 'user',
      content: content,
      timestamp: Date.now()
    }
    this.messages.push(userMsg)

    // ② 先插入一条空的 AI 消息，用于流式更新
    const aiMsg: ChatMessage = {
      role: 'assistant',
      content: '',
      timestamp: Date.now()
    }
    this.messages.push(aiMsg)

    // ③ 调用 Dify 流式 API
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

  /**
   * ===== 课后作业 1：流式调用 Dify，保存 conversation_id =====
   *
   * Dify 流式 API 返回 SSE 格式数据：
   *   data: {"event":"message","answer":"你","...}
   *   data: {"event":"message","answer":"好","...}
   *   data: {"event":"message_end","conversation_id":"xxx","...}
   *
   * 通过保存 message_end 事件返回的 conversation_id，
   * 下次请求时传入，实现上下文连续的多轮对话。
   *
   * 参考 DIFY_CHATFLOW_API.md §3.1 Streaming Response
   */
  private async callDifyStreaming(message: string, aiMsg: ChatMessage): Promise<void> {
    const httpRequest = http.createHttp()
    const textDecoder = util.TextDecoder.create('utf-8')
    let streamCompleted = false

    // 用于拼接流式返回的文本
    let fullAnswer = ''

    try {
      // 监听流式数据接收事件
      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        const chunk = textDecoder.decodeWithStream(new Uint8Array(data))

        // 解析 SSE 格式：每行以 "data: " 开头
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
            this.handleStreamEvent(event, aiMsg, fullAnswer => {
              fullAnswer = fullAnswer
            })
            // 收到 message_end 或 workflow_finished 表示流式完成
            if (event.event === 'message_end' || event.event === 'workflow_finished') {
              streamCompleted = true
            }
          } catch (e) {
            // 忽略解析失败的行
          }
        }
      })

      // 发起流式请求
      await httpRequest.request(
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
      )

      // 等待流式数据完全接收（最多等 30 秒）
      const maxWait = 30000
      const waitInterval = 200
      let waited = 0
      while (!streamCompleted && waited < maxWait) {
        await new Promise<void>(resolve => setTimeout(resolve, waitInterval))
        waited += waitInterval
      }

      // 如果流式未收到内容，使用阻塞模式兜底
      if (!aiMsg.content) {
        aiMsg.content = await this.callDifyBlocking(message)
      }
    } finally {
      httpRequest.destroy()
    }
  }

  /**
   * 处理流式事件
   * 参考 DIFY_CHATFLOW_API.md §3.1 Streaming Response 事件类型
   */
  private handleStreamEvent(
    event: DifyStreamEvent,
    aiMsg: ChatMessage,
    updateAnswer: (answer: string) => void
  ): void {
    switch (event.event) {
      case 'message':
        // LLM 文本分块，追加到当前回答文本
        if (event.answer) {
          aiMsg.content += event.answer
        }
        break
      case 'message_end':
        // 消息结束，保存 message_id、conversation_id
        if (event.conversation_id) {
          this.conversationId = event.conversation_id
        }
        if (event.task_id) {
          this.taskId = event.task_id
        }
        // 过滤 <think>...</think> 思考过程
        aiMsg.content = this.cleanThinkTags(aiMsg.content)
        break
      case 'message_replace':
        // 内容审查替换，用返回内容替换当前答案
        if (event.answer) {
          aiMsg.content = event.answer
        }
        break
      case 'error':
        // 流式异常，展示错误并结束本轮响应
        aiMsg.content = 'AI 回复异常，请稍后重试'
        break
      case 'ping':
        // 保活事件，忽略
        break
      default:
        // workflow_started / node_started / node_finished / workflow_finished
        // 等工作流事件在移动端无需特殊处理
        break
    }
  }

  /**
   * 阻塞模式调用 Dify（流式不可用时的兜底方案）
   * 参考 DIFY_CHATFLOW_API.md §3.1 Blocking Response
   */
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
      // 保存 conversation_id
      if (result.conversation_id) {
        this.conversationId = result.conversation_id
      }
      if (result.task_id) {
        this.taskId = result.task_id
      }
      return this.cleanThinkTags(result.answer || '未收到回复')
    } finally {
      httpRequest.destroy()
    }
  }

  /**
   * 过滤 <think>...</think> 思考过程标签
   */
  private cleanThinkTags(content: string): string {
    return content.replace(/<think>[\s\S]*?<\/think>/g, '')
  }

  /**
   * 构建请求体
   * 参考 DIFY_CHATFLOW_API.md §3.1 Request Body
   */
  private buildRequestBody(query: string, responseMode: string): DifyChatRequest {
    const body: DifyChatRequest = {
      inputs: {} as Record<string, string>,  // Chatflow 类型应用必须传 inputs 字段
      query: query,
      response_mode: responseMode,
      user: DIFY_USER,
      conversation_id: this.conversationId,  // 课后作业 1：传入保存的 conversation_id
      files: [],
      auto_generate_name: true
    }
    return body
  }

  /**
   * 停止流式响应
   * 参考 DIFY_CHATFLOW_API.md §3.2 POST /chat-messages/:task_id/stop
   */
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

  /**
   * 解析错误信息，转换为用户可理解的提示
   * 参考 DIFY_CHATFLOW_API.md §3.1 错误码
   */
  private parseErrorMessage(error: BusinessError): string {
    const code = error.code || 0
    const message = error.message || ''
    const msgLower = message.toLowerCase()

    // 根据错误信息关键词匹配 Dify 错误码
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

  /**
   * 清空消息列表，同时重置会话 ID
   */
  clearMessages(): void {
    this.messages = []
    this.conversationId = ''  // 清空会话，下次发消息开启新会话
    this.taskId = ''
  }
}
