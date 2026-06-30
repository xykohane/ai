package com.aicompanion.entity;

import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 技能树实体类（继承BaseEntity）
 * 对应数据库表：skill_tree
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("skill_tree")
public class SkillTree extends BaseEntity {

    /**
     * 技能名称
     */
    private String name;

    /**
     * 技能描述
     */
    private String description;

    /**
     * 分类（如：编程语言、框架、数据库等）
     */
    private String category;

    /**
     * 父技能ID（0表示顶级技能）
     */
    private Long parentId;

    /**
     * 技能等级（1-5）
     */
    private Integer level;

    /**
     * 排序权重
     */
    private Integer sortOrder;

    /**
     * 逻辑删除：0-未删除，1-已删除
     */
    @TableLogic
    private Integer deleted;
}
