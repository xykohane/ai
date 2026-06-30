package com.aicompanion.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 用户列表查询DTO（Admin端）
 */
@Schema(description = "用户列表查询请求")
@Data
public class UserQueryDTO {

    @Schema(description = "用户名（模糊查询）")
    private String username;

    @Schema(description = "角色：student/admin")
    private String role;

    @Schema(description = "状态：0-禁用 1-正常")
    private Integer status;

    @Schema(description = "页码")
    private Integer page = 1;

    @Schema(description = "每页条数")
    private Integer size = 10;
}
