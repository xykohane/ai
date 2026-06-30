package com.aicompanion.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC 配置
 * 将本地上传目录映射为可访问的静态资源路径
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    /**
     * 视频文件访问路径前缀，如 /uploads/videos
     */
    @Value("${app.upload.access-prefix:/uploads/videos}")
    private String accessPrefix;

    /**
     * 视频文件本地存储目录，如 uploads/videos
     */
    @Value("${app.upload.video-dir:uploads/videos}")
    private String videoDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 把 /uploads/videos/** 映射到本地 uploads/videos 目录
        // 这样前端访问 http://host:8080/uploads/videos/xxx.mp4 就能拿到视频
        String locationPrefix = videoDir.endsWith("/") ? videoDir : videoDir + "/";
        // 转为绝对路径 file: 协议
        String absolutePath = new java.io.File(locationPrefix).getAbsolutePath();
        registry.addResourceHandler(accessPrefix + "/**")
                .addResourceLocations("file:" + absolutePath + "/");
    }
}
