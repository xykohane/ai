package com.aicompanion.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Dify API 配置属性
 */
@Data
@Component
@ConfigurationProperties(prefix = "dify")
public class DifyProperties {

    /** Dify API 地址 */
    private String baseUrl;

    /** 请求超时（秒） */
    private Integer timeout = 120;

    /** AI伴学助手配置 */
    private TutorConfig tutor = new TutorConfig();

    /** AI面试官配置 */
    private InterviewerConfig interviewer = new InterviewerConfig();

    @Data
    public static class TutorConfig {
        /** AI伴学助手 API Key */
        private String apiKey;
    }

    @Data
    public static class InterviewerConfig {
        /** AI面试官 API Key */
        private String apiKey;
    }

    /**
     * 根据 agentType 获取对应的 API Key
     * @param agentType "tutor" 或 "interviewer"
     * @return API Key
     */
    public String getApiKey(String agentType) {
        if ("interviewer".equalsIgnoreCase(agentType)) {
            return interviewer.getApiKey();
        }
        // 默认返回 tutor
        return tutor.getApiKey();
    }
}
