package com.aicompanion.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * AI 聊天请求 DTO
 */
@Data
public class ChatRequest {

    /** 会话ID（首次对话传空字符串，后续传入返回的会话ID实现多轮对话） */
    private String sessionId = "";

    /** 用户消息 */
    @NotBlank(message = "消息内容不能为空")
    private String message;

    /** AI类型：tutor=AI伴学助手，interviewer=AI面试官，默认tutor */
    private String agentType = "tutor";
}
