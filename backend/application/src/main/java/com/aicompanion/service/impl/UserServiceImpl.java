package com.aicompanion.service.impl;

import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.dto.LoginDTO;
import com.aicompanion.dto.RegisterDTO;
import com.aicompanion.dto.UserDTO;
import com.aicompanion.dto.UserQueryDTO;
import com.aicompanion.entity.User;
import com.aicompanion.mapper.UserMapper;
import com.aicompanion.service.UserService;
import com.aicompanion.utils.JwtUtil;
import com.aicompanion.vo.LoginVO;
import com.aicompanion.vo.UserVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 用户服务实现类
 * 密码加密：BCrypt（Spring Security 推荐）
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    @Override
    public boolean register(RegisterDTO registerDTO) {
        // 参数校验
        if (registerDTO.getUsername() == null || registerDTO.getUsername().trim().isEmpty()) {
            throw new BusinessException("用户名不能为空");
        }
        if (registerDTO.getPassword() == null || registerDTO.getPassword().trim().isEmpty()) {
            throw new BusinessException("密码不能为空");
        }
        if (registerDTO.getEmail() == null || registerDTO.getEmail().trim().isEmpty()) {
            throw new BusinessException("邮箱不能为空");
        }

        // 检查密码长度（小于6位抛400）
        if (registerDTO.getPassword().length() < 6) {
            throw new BusinessException(400, "密码长度不能小于6位");
        }

        // ① 检查用户名是否已存在
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, registerDTO.getUsername());
        Long count = userMapper.selectCount(queryWrapper);
        if (count > 0) {
            throw new BusinessException("用户名已存在");
        }

        // ② 密码加密（BCrypt）
        User user = new User();
        BeanUtils.copyProperties(registerDTO, user);
        user.setPassword(passwordEncoder.encode(registerDTO.getPassword()));

        // ③ 设置默认角色和状态
        user.setRole("STUDENT");
        user.setStatus(1);
        user.setDeleted(0);

        // ④ 保存到数据库
        return userMapper.insert(user) > 0;
    }

    @Override
    public LoginVO login(LoginDTO loginDTO) {
        // ① 查询用户
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, loginDTO.getUsername());
        User user = userMapper.selectOne(queryWrapper);

        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }

        // ② 验证密码（BCrypt）
        if (!passwordEncoder.matches(loginDTO.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }

        // 检查用户状态
        if (user.getStatus() == 0) {
            throw new BusinessException("账号已被禁用");
        }

        // ③ 生成 JWT Token（包含角色，用于 RBAC 权限控制）
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());

        // ④ 返回 Token + 用户信息
        LoginVO vo = new LoginVO();
        vo.setToken(token);
        vo.setUserId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setRole(user.getRole());
        vo.setUser(convertToUserVO(user));
        return vo;
    }

    @Override
    public UserVO getUserInfo(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        return convertToUserVO(user);
    }

    @Override
    public boolean updateUser(Long userId, UserDTO userDTO) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 更新用户信息
        BeanUtils.copyProperties(userDTO, user);
        return userMapper.updateById(user) > 0;
    }

    @Override
    public boolean logout(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        // 逻辑删除：@TableLogic 会自动将 deleteById 转为 UPDATE ... SET deleted=1
        return userMapper.deleteById(userId) > 0;
    }

    // ==================== Admin端 ====================

    @Override
    public Page<UserVO> listUsers(UserQueryDTO queryDTO) {
        Page<User> page = new Page<>(queryDTO.getPage(), queryDTO.getSize());
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(queryDTO.getUsername())) {
            queryWrapper.like(User::getUsername, queryDTO.getUsername());
        }
        if (StringUtils.hasText(queryDTO.getRole())) {
            queryWrapper.eq(User::getRole, queryDTO.getRole());
        }
        if (queryDTO.getStatus() != null) {
            queryWrapper.eq(User::getStatus, queryDTO.getStatus());
        }

        Page<User> userPage = userMapper.selectPage(page, queryWrapper);

        // 转换为VO
        Page<UserVO> voPage = new Page<>(userPage.getCurrent(), userPage.getSize(), userPage.getTotal());
        voPage.setRecords(userPage.getRecords().stream()
                .map(this::convertToUserVO)
                .collect(Collectors.toList()));
        return voPage;
    }

    @Override
    public boolean adminUpdateUser(Long userId, UserDTO userDTO) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        BeanUtils.copyProperties(userDTO, user);
        user.setId(userId);
        return userMapper.updateById(user) > 0;
    }

    @Override
    public boolean deleteUser(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        // 逻辑删除：@TableLogic 会自动将 deleteById 转为 UPDATE ... SET deleted=1
        return userMapper.deleteById(userId) > 0;
    }

    @Override
    public List<User> searchUsers(String role, String keyword) {
        return userMapper.searchUsers(role, keyword);
    }

    /**
     * 将User实体转换为UserVO
     */
    private UserVO convertToUserVO(User user) {
        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(user, userVO);
        return userVO;
    }
}
