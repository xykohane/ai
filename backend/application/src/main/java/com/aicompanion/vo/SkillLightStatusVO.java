package com.aicompanion.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 技能点亮情况VO（Admin端）
 */
@Schema(description = "技能点亮情况响应")
@Data
public class SkillLightStatusVO {

    @Schema(description = "技能ID")
    private Long skillId;

    @Schema(description = "技能名称")
    private String skillName;

    @Schema(description = "技能类别")
    private String category;

    @Schema(description = "已点亮用户数（已掌握）")
    private Long litCount;

    @Schema(description = "学习中用户数")
    private Long learningCount;

    @Schema(description = "未开始用户数")
    private Long notStartedCount;
}
