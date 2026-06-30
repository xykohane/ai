package com.aicompanion.common.util;

import com.aicompanion.common.exception.BusinessException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Security 工具类
 * 在 Controller 中获取当前登录用户信息
 * 原理：JwtAuthenticationFilter 将用户信息存入 SecurityContextHolder（ThreadLocal 线程隔离）
 */
public class SecurityUtil {

    private SecurityUtil() {
    }

    /**
     * 获取当前登录用户的用户ID
     *
     * @return 用户ID
     * @throws BusinessException 未登录时抛出 401
     */
    public static Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new BusinessException(401, "用户未登录");
        }
        Object principal = authentication.getPrincipal();
        if (principal instanceof String str) {
            return Long.parseLong(str);
        }
        throw new BusinessException(401, "用户未登录");
    }

    /**
     * 获取当前登录用户的用户名
     *
     * @return 用户名
     * @throws BusinessException 未登录时抛出 401
     */
    public static String getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new BusinessException(401, "用户未登录");
        }
        return authentication.getName();
    }
}
