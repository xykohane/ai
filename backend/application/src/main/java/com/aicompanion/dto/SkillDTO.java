package com.aicompanion.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 技能树DTO（Admin端新增/修改）
 */
@Schema(description = "技能树请求")
@Data
public class SkillDTO {

    @Schema(description = "技能名称")
    @NotBlank(message = "技能名称不能为空")
    private String name;

    @Schema(description = "技能类别")
    @NotBlank(message = "技能类别不能为空")
    private String category;

    @Schema(description = "技能描述")
    private String description;

    @Schema(description = "难度等级 1-5")
    private Integer level;

    @Schema(description = "父技能ID，0表示顶层")
    private Long parentId;

    @Schema(description = "排序")
    private Integer sortOrder;
}
