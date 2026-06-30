package com.aicompanion.controller;

import com.aicompanion.common.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 首页控制器
 */
@RestController
public class IndexController {

    /**
     * 首页接口
     */
    @GetMapping("/")
    public Result<Map<String, Object>> index() {
        Map<String, Object> info = new HashMap<>();
        info.put("name", "AI Companion API");
        info.put("version", "1.0.0");
        info.put("status", "running");
        info.put("endpoints", new String[]{
            "POST /api/auth/register - 用户注册",
            "POST /api/auth/login - 用户登录",
            "GET /api/users/me - 获取当前用户信息",
            "PUT /api/users/{id} - 更新用户信息"
        });
        return Result.success(info);
    }

    /**
     * 健康检查接口
     */
    @GetMapping("/health")
    public Result<String> health() {
        return Result.success("OK");
    }
}
