package com.aicompanion.controller;

import com.aicompanion.common.Result;
import com.aicompanion.common.util.SecurityUtil;
import com.aicompanion.dto.SkillDTO;
import com.aicompanion.dto.UserSkillDTO;
import com.aicompanion.service.SkillService;
import com.aicompanion.vo.SkillLightStatusVO;
import com.aicompanion.vo.SkillVO;
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
 * 技能控制器
 * Web端：登录用户可访问（isAuthenticated）
 * Admin端：仅 ADMIN 角色可访问（hasRole('ADMIN')）
 */
@Tag(name = "技能管理", description = "技能树查询、点亮、学习建议等接口")
@Slf4j
@RestController
@RequestMapping("/api/skills")
@RequiredArgsConstructor
public class SkillController {

    private final SkillService skillService;

    // ==================== Web端 ====================

    /**
     * 查询技能树（关联当前用户学习情况）
     */
    @Operation(summary = "查询技能树", description = "需要携带Token访问，返回树形结构")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/tree")
    public Result<List<SkillVO>> getSkillTree() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<SkillVO> skillTree = skillService.getSkillTree(userId);
        return Result.success(skillTree);
    }

    /**
     * 点亮技能
     */
    @Operation(summary = "点亮技能", description = "更新用户技能学习状态")
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/light")
    public Result<Void> lightUpSkill(@Valid @RequestBody UserSkillDTO userSkillDTO) {
        Long userId = SecurityUtil.getCurrentUserId();
        boolean success = skillService.lightUpSkill(userId, userSkillDTO);
        if (success) {
            return Result.success("操作成功", null);
        } else {
            return Result.error("操作失败");
        }
    }

    /**
     * 生成技能点学习建议
     */
    @Operation(summary = "生成学习建议", description = "根据用户学习情况生成建议")
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/advice/{skillId}")
    public Result<String> getLearningAdvice(
            @Parameter(description = "技能ID") @PathVariable Long skillId) {
        Long userId = SecurityUtil.getCurrentUserId();
        String advice = skillService.generateLearningAdvice(userId, skillId);
        return Result.success(advice);
    }

    // ==================== Admin端 ====================

    /**
     * 新增技能
     */
    @Operation(summary = "新增技能", description = "Admin端：创建新技能")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public Result<Void> createSkill(@Valid @RequestBody SkillDTO skillDTO) {
        boolean success = skillService.createSkill(skillDTO);
        if (success) {
            return Result.success("创建成功", null);
        } else {
            return Result.error("创建失败");
        }
    }

    /**
     * 修改技能
     */
    @Operation(summary = "修改技能", description = "Admin端：更新技能信息")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}")
    public Result<Void> updateSkill(
            @Parameter(description = "技能ID") @PathVariable Long id,
            @Valid @RequestBody SkillDTO skillDTO) {
        boolean success = skillService.updateSkill(id, skillDTO);
        if (success) {
            return Result.success("更新成功", null);
        } else {
            return Result.error("更新失败");
        }
    }

    /**
     * 删除技能
     */
    @Operation(summary = "删除技能", description = "Admin端：删除技能（有子技能时不可删除）")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public Result<Void> deleteSkill(
            @Parameter(description = "技能ID") @PathVariable Long id) {
        boolean success = skillService.deleteSkill(id);
        if (success) {
            return Result.success("删除成功", null);
        } else {
            return Result.error("删除失败");
        }
    }

    /**
     * 查询技能详情
     */
    @Operation(summary = "查询技能详情", description = "Admin端：根据ID查询技能信息")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{id}")
    public Result<SkillVO> getSkillById(
            @Parameter(description = "技能ID") @PathVariable Long id) {
        SkillVO skillVO = skillService.getSkillById(id);
        return Result.success(skillVO);
    }

    /**
     * 查询所有技能列表
     */
    @Operation(summary = "查询所有技能", description = "Admin端：获取所有技能列表（不分层级）")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/list")
    public Result<List<SkillVO>> listAllSkills() {
        List<SkillVO> skills = skillService.listAllSkills();
        return Result.success(skills);
    }

    /**
     * 查询技能点亮情况
     */
    @Operation(summary = "查询技能点亮情况", description = "Admin端：统计每个技能的点亮人数")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/light-status")
    public Result<List<SkillLightStatusVO>> getSkillLightStatus() {
        List<SkillLightStatusVO> statusList = skillService.getSkillLightStatus();
        return Result.success(statusList);
    }
}
