package com.aicompanion.entity;

import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 在线学习视频实体类
 * 对应数据库表：learning_video
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("learning_video")
public class LearningVideo extends BaseEntity {

    /**
     * 所属模块：政治理论/言语理解/数量关系/判断推理/资料分析
     */
    private String moduleName;

    /**
     * 视频标题
     */
    private String title;

    /**
     * 视频描述
     */
    private String description;

    /**
     * 视频访问路径，如 /uploads/videos/xxx.mp4
     */
    private String videoUrl;

    /**
     * 视频时长（秒）
     */
    private Integer duration;

    /**
     * 排序权重，越小越靠前
     */
    private Integer sortOrder;

    /**
     * 逻辑删除：0-未删除，1-已删除
     */
    @TableLogic
    private Integer deleted;
}
