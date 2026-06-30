package com.aicompanion.controller;

import com.aicompanion.common.Result;
import com.aicompanion.common.util.SecurityUtil;
import com.aicompanion.dto.UserDTO;
import com.aicompanion.dto.UserQueryDTO;
import com.aicompanion.entity.User;
import com.aicompanion.service.UserService;
import com.aicompanion.vo.UserVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户控制器
 * Web端：登录用户可访问（isAuthenticated）
 * Admin端：仅 ADMIN 角色可访问（hasRole('ADMIN')）
 */
@Tag(name = "用户管理", description = "用户信息查询、更新等接口")
@Slf4j
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // ==================== Web端 ====================

    /**
     * 获取当前用户信息
     */
    @Operation(summary = "获取当前用户信息", description = "需要携带Token访问")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/me")
    public Result<UserVO> getCurrentUser() {
        Long userId = SecurityUtil.getCurrentUserId();
        UserVO userVO = userService.getUserInfo(userId);
        return Result.success(userVO);
    }

    /**
     * 更新当前用户信息
     */
    @Operation(summary = "更新当前用户信息", description = "需要携带Token访问")
    @PreAuthorize("isAuthenticated()")
    @PutMapping("/me")
    public Result<Void> updateCurrentUser(@Valid @RequestBody UserDTO userDTO) {
        Long userId = SecurityUtil.getCurrentUserId();
        boolean success = userService.updateUser(userId, userDTO);
        if (success) {
            return Result.success("更新成功", null);
        } else {
            return Result.error("更新失败");
        }
    }

    /**
     * 注销账号
     */
    @Operation(summary = "注销账号", description = "需要携带Token访问，注销后账号将被逻辑删除")
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/logout")
    public Result<Void> logout() {
        Long userId = SecurityUtil.getCurrentUserId();
        boolean success = userService.logout(userId);
        if (success) {
            return Result.success("注销成功", null);
        } else {
            return Result.error("注销失败");
        }
    }

    // ==================== Admin端 ====================

    /**
     * 查询用户列表（分页）
     */
    @Operation(summary = "查询用户列表", description = "Admin端：分页查询用户列表，支持条件筛选")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/list")
    public Result<Page<UserVO>> listUsers(UserQueryDTO queryDTO) {
        Page<UserVO> page = userService.listUsers(queryDTO);
        return Result.success(page);
    }

    /**
     * Admin修改用户信息
     */
    @Operation(summary = "修改用户信息", description = "Admin端：修改指定用户信息")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/admin/{id}")
    public Result<Void> adminUpdateUser(
            @Parameter(description = "用户ID", example = "1") @PathVariable Long id,
            @Valid @RequestBody UserDTO userDTO) {
        boolean success = userService.adminUpdateUser(id, userDTO);
        if (success) {
            return Result.success("更新成功", null);
        } else {
            return Result.error("更新失败");
        }
    }

    /**
     * 删除用户
     */
    @Operation(summary = "删除用户", description = "Admin端：删除指定用户（逻辑删除）")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(
            @Parameter(description = "用户ID", example = "1") @PathVariable Long id) {
        boolean success = userService.deleteUser(id);
        if (success) {
            return Result.success("删除成功", null);
        } else {
            return Result.error("删除失败");
        }
    }

    /**
     * 动态搜索用户（XML Mapper方式）
     * 支持按角色筛选 + 关键词模糊搜索
     */
    @Operation(summary = "搜索用户", description = "按角色筛选 + 关键词模糊搜索（XML Mapper动态SQL）")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/search")
    public Result<List<User>> searchUsers(
            @Parameter(description = "角色（可选）") @RequestParam(required = false) String role,
            @Parameter(description = "关键词（可选）") @RequestParam(required = false) String keyword) {
        List<User> users = userService.searchUsers(role, keyword);
        return Result.success(users);
    }
}
