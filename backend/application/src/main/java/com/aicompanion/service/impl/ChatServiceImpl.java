package com.aicompanion.service.impl;

import com.aicompanion.config.DifyProperties;
import com.aicompanion.entity.AiChatMessage;
import com.aicompanion.mapper.AiChatMessageMapper;
import com.aicompanion.service.ChatService;
import com.aicompanion.vo.ChatResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.function.Consumer;

/**
 * AI 聊天服务实现 —— 对接 Dify API
 *
 * Dify 对话接口：POST {base-url}/chat-messages
 * - 阻塞模式：response_mode=blocking，返回完整 JSON
 * - 流式模式：response_mode=streaming，返回 SSE 逐行推送
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final DifyProperties difyProperties;
    private final AiChatMessageMapper chatMessageMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    /** 复用 HttpClient */
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    /**
     * 同步聊天（阻塞模式）
     */
    @Override
    public ChatResponse chat(Long userId, String sessionId, String message, String agentType) {
        // 1. 保存用户消息
        saveMessage(userId, sessionId, "user", message);

        // 2. 构建请求体
        Map<String, Object> body = buildRequestBody(sessionId, message, userId, "blocking");

        try {
            // 3. 发送请求
            HttpRequest request = buildHttpRequest(body, agentType);
            HttpResponse<String> response = httpClient.send(request,
                    HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                log.error("Dify API 调用失败: status={}, body={}", response.statusCode(), response.body());
                throw new RuntimeException("AI 服务暂时无法响应");
            }

            // 4. 解析响应
            JsonNode json = objectMapper.readTree(response.body());
            String answer = json.path("answer").asText("");
            String conversationId = json.path("conversation_id").asText("");

            // 过滤掉 <think>...</think> 标签内容（DeepSeek模型的思考过程）
            answer = filterThinkTags(answer);

            // 5. 保存 AI 回复
            saveMessage(userId, conversationId, "assistant", answer);

            return new ChatResponse(answer, conversationId);

        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            log.error("同步聊天异常", e);
            throw new RuntimeException("AI 服务调用异常: " + e.getMessage());
        }
    }

    /**
     * 流式聊天（SSE 打字机效果）
     */
    @Override
    public void chatStream(Long userId, String sessionId, String message, String agentType,
                           Consumer<String> onChunk,
                           Consumer<String> onComplete,
                           Consumer<String> onError) {
        // 1. 保存用户消息
        saveMessage(userId, sessionId, "user", message);

        // 2. 构建请求体
        Map<String, Object> body = buildRequestBody(sessionId, message, userId, "streaming");

        // 3. 异步发送请求，逐行读取 SSE
        CompletableFuture.runAsync(() -> {
            try {
                HttpRequest request = buildHttpRequest(body, agentType);
                HttpResponse<java.util.stream.Stream<String>> response =
                        httpClient.send(request, HttpResponse.BodyHandlers.ofLines());

                if (response.statusCode() != 200) {
                    onError.accept("AI 服务状态码: " + response.statusCode());
                    return;
                }

                StringBuilder fullAnswer = new StringBuilder();
                String[] conversationIdHolder = {""};
                boolean[] inThinkBlock = {false};

                // 逐行处理 SSE 数据
                response.body().forEach(line -> {
                    try {
                        if (!line.startsWith("data:")) {
                            return;
                        }
                        String jsonStr = line.substring(5).trim();
                        if (jsonStr.isEmpty()) {
                            return;
                        }

                        JsonNode node = objectMapper.readTree(jsonStr);
                        String event = node.path("event").asText("");

                        switch (event) {
                            case "message" -> {
                                String chunk = node.path("answer").asText("");
                                conversationIdHolder[0] = node.path("conversation_id").asText("");
                                if (!chunk.isEmpty()) {
                                    fullAnswer.append(chunk);
                                    // 流式过滤 <think> 标签：追踪状态，跳过思考过程中的内容
                                    String filtered = filterThinkTagsStreaming(chunk, inThinkBlock);
                                    if (!filtered.isEmpty()) {
                                        onChunk.accept(filtered);
                                    }
                                }
                            }
                            case "message_end" -> {
                                conversationIdHolder[0] = node.path("conversation_id").asText("");
                            }
                            case "error" -> {
                                String errMsg = node.path("message").asText("AI 服务出错");
                                onError.accept(errMsg);
                            }
                        }
                    } catch (Exception e) {
                        log.warn("解析 SSE 行失败: {}", line, e);
                    }
                });

                // 4. 保存完整 AI 回复
                String convId = conversationIdHolder[0];
                if (fullAnswer.length() > 0) {
                    saveMessage(userId, convId, "assistant", fullAnswer.toString());
                }

                // 5. 完成回调
                onComplete.accept(convId);

            } catch (Exception e) {
                log.error("流式聊天异常", e);
                onError.accept("AI 服务调用异常: " + e.getMessage());
            }
        });
    }

    // ==================== 私有方法 ====================

    /**
     * 构建 Dify 请求体
     */
    private Map<String, Object> buildRequestBody(String sessionId, String message,
                                                  Long userId, String responseMode) {
        Map<String, Object> body = new HashMap<>();
        body.put("inputs", new HashMap<>());
        body.put("query", message);
        body.put("response_mode", responseMode);
        body.put("conversation_id", sessionId == null ? "" : sessionId);
        body.put("user", String.valueOf(userId));
        return body;
    }

    /**
     * 构建 HTTP 请求
     */
    private HttpRequest buildHttpRequest(Map<String, Object> body, String agentType) throws Exception {
        String json = objectMapper.writeValueAsString(body);
        return HttpRequest.newBuilder()
                .uri(URI.create(difyProperties.getBaseUrl() + "/chat-messages"))
                .header("Authorization", "Bearer " + difyProperties.getApiKey(agentType))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(difyProperties.getTimeout()))
                .POST(HttpRequest.BodyPublishers.ofString(json))
                .build();
    }

    /**
     * 保存对话记录
     */
    private void saveMessage(Long userId, String sessionId, String role, String content) {
        try {
            AiChatMessage record = new AiChatMessage();
            record.setUserId(userId);
            record.setSessionId(sessionId == null ? "" : sessionId);
            record.setRole(role);
            record.setContent(content);
            record.setCreateTime(LocalDateTime.now());
            chatMessageMapper.insert(record);
        } catch (Exception e) {
            log.warn("保存对话记录失败: {}", e.getMessage());
        }
    }

    /**
     * 过滤掉 <think>...</think> 标签内容（DeepSeek模型的思考过程）
     */
    private String filterThinkTags(String content) {
        if (content == null || content.isEmpty()) {
            return content;
        }
        // 使用正则表达式移除 <think>...</think> 标签及其内容
        return content.replaceAll("(?s)<think>.*?</think>", "").trim();
    }

    /**
     * 流式过滤 <think> 标签内容
     * 通过状态追踪处理跨chunk的标签
     */
    private String filterThinkTagsStreaming(String chunk, boolean[] inThinkBlock) {
        if (chunk == null || chunk.isEmpty()) {
            return chunk;
        }

        StringBuilder result = new StringBuilder();
        int i = 0;

        while (i < chunk.length()) {
            if (inThinkBlock[0]) {
                // 当前在思考块内，查找 </think>
                int endIdx = chunk.indexOf("</think>", i);
                if (endIdx != -1) {
                    inThinkBlock[0] = false;
                    i = endIdx + "</think>".length();
                } else {
                    // 整个chunk都在思考块内，跳过
                    return "";
                }
            } else {
                // 不在思考块内，查找 <think>
                int startIdx = chunk.indexOf("<think>", i);
                if (startIdx != -1) {
                    // 添加 <think> 之前的内容
                    result.append(chunk, i, startIdx);
                    // 查找 </think>
                    int endIdx = chunk.indexOf("</think>", startIdx);
                    if (endIdx != -1) {
                        // 思考块在同一chunk内结束，跳过中间内容
                        i = endIdx + "</think>".length();
                    } else {
                        // 思考块跨chunk，标记状态
                        inThinkBlock[0] = true;
                        return result.toString();
                    }
                } else {
                    // 没有 <think>，全部添加
                    result.append(chunk, i, chunk.length());
                    break;
                }
            }
        }

        return result.toString();
    }
}
