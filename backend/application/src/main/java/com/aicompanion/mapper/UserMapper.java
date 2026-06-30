package com.aicompanion.mapper;

import com.aicompanion.entity.User;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 用户Mapper接口
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {

    /**
     * XML方式：动态SQL查询 - 按角色筛选 + 关键词模糊搜索
     *
     * @param role    角色（可选）
     * @param keyword 关键词（模糊搜索用户名和昵称）
     * @return 用户列表
     */
    List<User> searchUsers(@Param("role") String role, @Param("keyword") String keyword);

    /**
     * XML方式：批量更新状态
     *
     * @param ids    用户ID列表
     * @param status 目标状态
     * @return 影响行数
     */
    int batchUpdateStatus(@Param("ids") List<Long> ids, @Param("status") Integer status);
}
