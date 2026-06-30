package com.aicompanion.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 点亮技能DTO（Web端）
 */
@Schema(description = "点亮技能请求")
@Data
public class UserSkillDTO {

    @Schema(description = "技能ID")
    @NotNull(message = "技能ID不能为空")
    private Long skillId;

    @Schema(description = "掌握程度 0-5")
    private Integer level;

    @Schema(description = "状态：0-未开始 1-学习中 2-已掌握")
    private Integer status;
}
