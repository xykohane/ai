package com.aicompanion.common.exception;

import lombok.Getter;

/**
 * 自定义业务异常
 * 用于在Service层抛出业务相关的异常，由全局异常处理器统一处理
 */
@Getter
public class BusinessException extends RuntimeException {

    /**
     * 错误状态码
     */
    private final int code;

    /**
     * 构造方法（默认500）
     *
     * @param message 错误信息
     */
    public BusinessException(String message) {
        super(message);
        this.code = 500;
    }

    /**
     * 构造方法（自定义状态码）
     *
     * @param code    错误状态码
     * @param message 错误信息
     */
    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
}
