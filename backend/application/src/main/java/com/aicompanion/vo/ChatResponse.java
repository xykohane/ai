package com.aicompanion.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * AI 聊天响应 VO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatResponse {

    /** AI 回复内容 */
    private String answer;

    /** Dify 会话ID（首次对话后返回，后续传入实现多轮对话） */
    private String conversationId;
}
