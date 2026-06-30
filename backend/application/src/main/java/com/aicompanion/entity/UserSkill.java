package com.aicompanion.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户技能关联实体类
 */
@Data
@TableName("user_skill")
public class UserSkill implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 技能ID
     */
    private Long skillId;

    /**
     * 掌握程度 0-5
     */
    private Integer level;

    /**
     * 状态：0-未开始 1-学习中 2-已掌握
     */
    private Integer status;

    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
}
