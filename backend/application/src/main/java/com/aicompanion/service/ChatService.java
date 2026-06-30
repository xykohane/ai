package com.aicompanion.service;

import com.aicompanion.vo.ChatResponse;

import java.util.function.Consumer;

/**
 * AI 聊天服务接口
 */
public interface ChatService {

    /**
     * 同步聊天（阻塞模式，等待AI完整回复后返回）
     *
     * @param userId      用户ID
     * @param sessionId   会话ID（首次传空字符串）
     * @param message     用户消息
     * @param agentType   AI类型：tutor=AI伴学助手，interviewer=AI面试官
     * @return AI回复内容（包含answer和conversationId）
     */
    ChatResponse chat(Long userId, String sessionId, String message, String agentType);

    /**
     * 流式聊天（SSE 打字机效果）
     *
     * @param userId      用户ID
     * @param sessionId   会话ID（首次传空字符串）
     * @param message     用户消息
     * @param agentType   AI类型：tutor=AI伴学助手，interviewer=AI面试官
     * @param onChunk     每收到一段文字的回调
     * @param onComplete  全部接收完成的回调（参数为会话ID）
     * @param onError     出错回调
     */
    void chatStream(Long userId, String sessionId, String message, String agentType,
                    Consumer<String> onChunk,
                    Consumer<String> onComplete,
                    Consumer<String> onError);
}
