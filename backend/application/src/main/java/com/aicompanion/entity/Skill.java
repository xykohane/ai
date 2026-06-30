package com.aicompanion.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 技能树实体类
 */
@Data
@TableName("skill")
public class Skill implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 技能名称
     */
    private String name;

    /**
     * 技能类别
     */
    private String category;

    /**
     * 技能描述
     */
    private String description;

    /**
     * 难度等级 1-5
     */
    private Integer level;

    /**
     * 父技能ID，0表示顶层
     */
    private Long parentId;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 创建时间
     */
    private LocalDateTime createTime;
}
