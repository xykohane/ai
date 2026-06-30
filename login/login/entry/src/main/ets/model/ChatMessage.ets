// 聊天消息数据模型
export class ChatMessage {
  role: string = ''       // 'user' 或 'assistant'
  content: string = ''    // 消息内容
  timestamp: number = 0   // 时间戳
}

// 发送消息请求参数
export class ChatRequest {
  message: string = ''            // 用户发送的消息
  conversationId: string = ''     // 会话 ID（空字符串 = 新会话）
}
