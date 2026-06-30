package com.aicompanion.mapper;

import com.aicompanion.entity.UserSkill;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户技能关联Mapper接口
 */
@Mapper
public interface UserSkillMapper extends BaseMapper<UserSkill> {
}
