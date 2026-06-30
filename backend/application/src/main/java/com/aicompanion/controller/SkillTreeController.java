package com.aicompanion.controller;

import com.aicompanion.common.Result;
import com.aicompanion.entity.SkillTree;
import com.aicompanion.service.SkillTreeService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 技能树控制器
 * 练习1：使用 BaseMapper 实现完整的 CRUD
 */
@Tag(name = "技能树管理", description = "技能树CRUD接口（BaseMapper方式）")
@Slf4j
@RestController
@RequestMapping("/api/skill-tree")
@RequiredArgsConstructor
public class SkillTreeController {

    private final SkillTreeService skillTreeService;

    /**
     * 新增技能
     */
    @Operation(summary = "新增技能", description = "创建新技能节点")
    @PostMapping
    public Result<Void> createSkill(@Valid @RequestBody SkillTree skillTree) {
        boolean success = skillTreeService.createSkill(skillTree);
        if (success) {
            return Result.success("创建成功", null);
        } else {
            return Result.error("创建失败");
        }
    }

    /**
     * 删除技能（逻辑删除）
     */
    @Operation(summary = "删除技能", description = "逻辑删除指定技能")
    @DeleteMapping("/{id}")
    public Result<Void> deleteSkill(
            @Parameter(description = "技能ID") @PathVariable Long id) {
        boolean success = skillTreeService.deleteSkill(id);
        if (success) {
            return Result.success("删除成功", null);
        } else {
            return Result.error("删除失败");
        }
    }

    /**
     * 查询技能树列表
     */
    @Operation(summary = "查询技能树列表", description = "获取所有技能列表")
    @GetMapping("/list")
    public Result<List<SkillTree>> listSkills() {
        List<SkillTree> list = skillTreeService.listSkills();
        return Result.success(list);
    }

    /**
     * 按分类查询技能
     */
    @Operation(summary = "按分类查询", description = "根据分类筛选技能")
    @GetMapping("/category/{category}")
    public Result<List<SkillTree>> listByCategory(
            @Parameter(description = "分类名称") @PathVariable String category) {
        List<SkillTree> list = skillTreeService.listByCategory(category);
        return Result.success(list);
    }

    /**
     * 分页查询技能树
     */
    @Operation(summary = "分页查询技能树", description = "支持按分类筛选和名称模糊搜索的分页查询")
    @GetMapping("/page")
    public Result<Page<SkillTree>> listByPage(
            @Parameter(description = "页码", example = "1") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "每页大小", example = "10") @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "分类（可选）") @RequestParam(required = false) String category,
            @Parameter(description = "技能名称关键字（可选，模糊匹配）") @RequestParam(required = false) String keyword) {
        Page<SkillTree> result = skillTreeService.listSkillsByPage(page, size, category, keyword);
        return Result.success(result);
    }

    /**
     * 根据ID查询技能详情
     */
    @Operation(summary = "查询技能详情", description = "根据ID获取技能信息")
    @GetMapping("/{id}")
    public Result<SkillTree> getSkillById(
            @Parameter(description = "技能ID") @PathVariable Long id) {
        SkillTree skillTree = skillTreeService.getSkillById(id);
        if (skillTree == null) {
            return Result.error("技能不存在");
        }
        return Result.success(skillTree);
    }

    /**
     * 更新技能信息
     */
    @Operation(summary = "更新技能", description = "修改技能信息")
    @PutMapping("/{id}")
    public Result<Void> updateSkill(
            @Parameter(description = "技能ID") @PathVariable Long id,
            @Valid @RequestBody SkillTree skillTree) {
        boolean success = skillTreeService.updateSkill(id, skillTree);
        if (success) {
            return Result.success("更新成功", null);
        } else {
            return Result.error("更新失败");
        }
    }
}
