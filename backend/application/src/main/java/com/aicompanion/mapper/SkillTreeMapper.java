package com.aicompanion.mapper;

import com.aicompanion.entity.SkillTree;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * 技能树 Mapper 接口
 * 继承 BaseMapper<SkillTree> 后自动拥有基础 CRUD 方法
 */
@Mapper
public interface SkillTreeMapper extends BaseMapper<SkillTree> {
}
