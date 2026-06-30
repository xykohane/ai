package com.aicompanion.dto;

import jakarta.validation.constraints.Email;
import lombok.Data;

/**
 * 用户信息更新DTO
 */
@Data
public class UserDTO {

    /**
     * 昵称
     */
    private String nickname;

    /**
     * 邮箱
     */
    @Email(message = "邮箱格式不正确")
    private String email;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 头像
     */
    private String avatar;

    /**
     * 角色：STUDENT/TEACHER/ADMIN
     */
    private String role;

    /**
     * 状态：0-禁用，1-正常
     */
    private Integer status;
}
