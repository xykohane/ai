package com.aicompanion.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 技能树VO（关联当前用户学习情况）
 */
@Schema(description = "技能树响应")
@Data
public class SkillVO {

    @Schema(description = "技能ID")
    private Long id;

    @Schema(description = "技能名称")
    private String name;

    @Schema(description = "技能类别")
    private String category;

    @Schema(description = "技能描述")
    private String description;

    @Schema(description = "难度等级 1-5")
    private Integer level;

    @Schema(description = "父技能ID，0表示顶层")
    private Long parentId;

    @Schema(description = "排序")
    private Integer sortOrder;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "当前用户学习状态：0-未开始 1-学习中 2-已掌握")
    private Integer userStatus;

    @Schema(description = "当前用户掌握程度 0-5")
    private Integer userLevel;

    @Schema(description = "子技能列表")
    private List<SkillVO> children;
}
