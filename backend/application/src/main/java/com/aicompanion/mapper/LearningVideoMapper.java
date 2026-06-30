package com.aicompanion.mapper;

import com.aicompanion.entity.LearningVideo;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * 在线学习视频 Mapper 接口
 * 继承 BaseMapper 后自动拥有基础 CRUD 方法
 */
@Mapper
public interface LearningVideoMapper extends BaseMapper<LearningVideo> {
}
