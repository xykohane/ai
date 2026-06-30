package com.aicompanion.controller;

import com.aicompanion.common.Result;
import com.aicompanion.common.util.SecurityUtil;
import com.aicompanion.dto.ChatRequest;
import com.aicompanion.service.ChatService;
import com.aicompanion.vo.ChatResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.concurrent.CompletableFuture;

/**
 * AI 聊天控制器
 * - 同步聊天：POST /api/ai/chat/message
 * - 流式聊天：POST /api/ai/chat/stream（SSE 打字机效果）
 */
@Slf4j
@RestController
@RequestMapping("/api/ai/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    /**
     * 同步聊天
     */
    @PostMapping("/message")
    public Result<ChatResponse> chat(@Valid @RequestBody ChatRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        ChatResponse response = chatService.chat(userId, request.getSessionId(), request.getMessage(), request.getAgentType());
        return Result.success(response);
    }

    /**
     * 流式聊天（SSE 打字机效果）
     */
    @PostMapping("/stream")
    public SseEmitter streamChat(@Valid @RequestBody ChatRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        // 超时 2 分钟
        SseEmitter emitter = new SseEmitter(120000L);

        CompletableFuture.runAsync(() -> {
            try {
                chatService.chatStream(
                        userId,
                        request.getSessionId(),
                        request.getMessage(),
                        request.getAgentType(),
                        // 每收到一段文字 → SSE 推送
                        chunk -> {
                            try {
                                emitter.send(SseEmitter.event().data(chunk));
                            } catch (IOException e) {
                                emitter.completeWithError(e);
                            }
                        },
                        // 完成 → 推送会话ID并关闭
                        conversationId -> {
                            try {
                                emitter.send(SseEmitter.event().data("[DONE]"));
                                emitter.complete();
                            } catch (IOException e) {
                                emitter.completeWithError(e);
                            }
                        },
                        // 出错
                        error -> {
                            try {
                                emitter.send(SseEmitter.event().data("错误: " + error));
                            } catch (IOException ignored) {
                            }
                            emitter.completeWithError(new RuntimeException(error));
                        }
                );
            } catch (Exception e) {
                log.error("流式聊天异常", e);
                emitter.completeWithError(e);
            }
        });

        return emitter;
    }
}
