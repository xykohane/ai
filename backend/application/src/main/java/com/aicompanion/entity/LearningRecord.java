package com.aicompanion.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 学习记录实体类
 */
@Data
@TableName("learning_record")
public class LearningRecord implements Serializable {

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
     * 资源名称（冗余，减少JOIN；历史数据快照）
     */
    private String skillName;

    /**
     * 进度百分比 0-100
     */
    private Integer progress;

    /**
     * 累计学习秒数
     */
    private Integer studySeconds;

    /**
     * 状态：0-未开始 1-学习中 2-已完成
     */
    private Integer status;

    /**
     * 首次学习时间
     */
    private LocalDateTime firstStudyTime;

    /**
     * 最近学习时间
     */
    private LocalDateTime lastStudyTime;

    /**
     * 完成时间
     */
    private LocalDateTime completeTime;

    /**
     * 创建时间
     */
    private LocalDateTime createTime;
}
