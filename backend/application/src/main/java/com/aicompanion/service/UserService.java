package com.aicompanion.service;

import com.aicompanion.dto.LoginDTO;
import com.aicompanion.dto.RegisterDTO;
import com.aicompanion.dto.UserDTO;
import com.aicompanion.dto.UserQueryDTO;
import com.aicompanion.entity.User;
import com.aicompanion.vo.LoginVO;
import com.aicompanion.vo.UserVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.List;

/**
 * 用户服务接口
 */
public interface UserService {

    /**
     * 用户注册
     *
     * @param registerDTO 注册信息
     * @return 是否成功
     */
    boolean register(RegisterDTO registerDTO);

    /**
     * 用户登录
     *
     * @param loginDTO 登录信息
     * @return 登录响应（包含Token和用户信息）
     */
    LoginVO login(LoginDTO loginDTO);

    /**
     * 获取用户信息
     *
     * @param userId 用户ID
     * @return 用户信息
     */
    UserVO getUserInfo(Long userId);

    /**
     * 更新用户信息
     *
     * @param userId 用户ID
     * @param userDTO 用户信息
     * @return 是否成功
     */
    boolean updateUser(Long userId, UserDTO userDTO);

    /**
     * 注销（逻辑删除）
     *
     * @param userId 用户ID
     * @return 是否成功
     */
    boolean logout(Long userId);

    // ==================== Admin端 ====================

    /**
     * 分页查询用户列表
     *
     * @param queryDTO 查询条件
     * @return 用户列表分页结果
     */
    Page<UserVO> listUsers(UserQueryDTO queryDTO);

    /**
     * Admin修改用户信息
     *
     * @param userId  用户ID
     * @param userDTO 用户信息
     * @return 是否成功
     */
    boolean adminUpdateUser(Long userId, UserDTO userDTO);

    /**
     * 删除用户（逻辑删除）
     *
     * @param userId 用户ID
     * @return 是否成功
     */
    boolean deleteUser(Long userId);

    /**
     * 动态搜索用户（XML Mapper方式）
     * 支持按角色筛选 + 关键词模糊搜索
     *
     * @param role    角色（可选）
     * @param keyword 关键词（可选）
     * @return 用户列表
     */
    List<User> searchUsers(String role, String keyword);
}
