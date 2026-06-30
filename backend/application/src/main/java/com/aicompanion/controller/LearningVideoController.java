package com.aicompanion.controller;

import com.aicompanion.common.Result;
import com.aicompanion.entity.LearningVideo;
import com.aicompanion.service.LearningVideoService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * 在线学习视频控制器
 * 提供视频 CRUD + 文件上传接口
 */
@Tag(name = "在线学习视频管理", description = "视频CRUD与文件上传接口")
@Slf4j
@RestController
@RequestMapping("/api/learning-video")
@RequiredArgsConstructor
public class LearningVideoController {

    private final LearningVideoService learningVideoService;

    /**
     * 视频文件上传根目录（在 application.yml 中配置）
     */
    @Value("${app.upload.video-dir:uploads/videos}")
    private String videoDir;

    /**
     * 视频访问路径前缀
     */
    @Value("${app.upload.access-prefix:/uploads/videos}")
    private String accessPrefix;

    /**
     * 新增视频记录
     */
    @Operation(summary = "新增视频", description = "创建新的视频记录")
    @PostMapping
    public Result<Void> create(@Valid @RequestBody LearningVideo video) {
        boolean success = learningVideoService.create(video);
        return success ? Result.success("创建成功", null) : Result.error("创建失败");
    }

    /**
     * 删除视频（逻辑删除）
     */
    @Operation(summary = "删除视频", description = "逻辑删除指定视频")
    @DeleteMapping("/{id}")
    public Result<Void> delete(@Parameter(description = "视频ID") @PathVariable Long id) {
        boolean success = learningVideoService.delete(id);
        return success ? Result.success("删除成功", null) : Result.error("删除失败");
    }

    /**
     * 修改视频信息
     */
    @Operation(summary = "修改视频", description = "更新视频信息")
    @PutMapping("/{id}")
    public Result<Void> update(
            @Parameter(description = "视频ID") @PathVariable Long id,
            @Valid @RequestBody LearningVideo video) {
        boolean success = learningVideoService.update(id, video);
        return success ? Result.success("更新成功", null) : Result.error("更新失败");
    }

    /**
     * 查询视频详情
     */
    @Operation(summary = "查询视频详情", description = "根据ID获取视频信息")
    @GetMapping("/{id}")
    public Result<LearningVideo> getById(@Parameter(description = "视频ID") @PathVariable Long id) {
        LearningVideo video = learningVideoService.getById(id);
        return video == null ? Result.error("视频不存在") : Result.success(video);
    }

    /**
     * 查询全部视频
     */
    @Operation(summary = "查询全部视频", description = "获取所有视频列表")
    @GetMapping("/list")
    public Result<List<LearningVideo>> list() {
        return Result.success(learningVideoService.list());
    }

    /**
     * 按模块查询视频（App 端使用）
     */
    @Operation(summary = "按模块查询", description = "根据模块名获取该模块下的视频列表")
    @GetMapping("/module/{moduleName}")
    public Result<List<LearningVideo>> listByModule(
            @Parameter(description = "模块名称") @PathVariable String moduleName) {
        return Result.success(learningVideoService.listByModule(moduleName));
    }

    /**
     * 分页查询（后台管理使用）
     */
    @Operation(summary = "分页查询", description = "支持按模块筛选和标题模糊搜索的分页查询")
    @GetMapping("/page")
    public Result<Page<LearningVideo>> page(
            @Parameter(description = "页码") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "每页大小") @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "模块（可选）") @RequestParam(required = false) String moduleName,
            @Parameter(description = "标题关键字（可选）") @RequestParam(required = false) String keyword) {
        return Result.success(learningVideoService.page(page, size, moduleName, keyword));
    }

    /**
     * 视频文件上传
     * 返回可访问的相对路径，前端拼接后端域名即可播放
     */
    @Operation(summary = "上传视频文件", description = "上传视频文件，返回可访问路径")
    @PostMapping("/upload")
    public Result<String> upload(@Parameter(description = "视频文件") @RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return Result.error("上传文件不能为空");
        }

        // 限制文件大小（由 application.yml 的 multipart 配置控制）
        String originalName = file.getOriginalFilename();
        if (originalName == null || !originalName.contains(".")) {
            return Result.error("文件名不合法");
        }

        // 生成新文件名，避免冲突
        String suffix = originalName.substring(originalName.lastIndexOf("."));
        String newFileName = UUID.randomUUID().toString().replace("-", "") + suffix;

        // 确保目录存在
        File dir = new File(videoDir);
        if (!dir.exists() && !dir.mkdirs()) {
            log.error("创建视频目录失败: {}", videoDir);
            return Result.error("服务器存储目录创建失败");
        }

        // 保存文件
        try {
            File dest = new File(dir, newFileName);
            file.transferTo(dest);
            log.info("视频上传成功: {}", dest.getAbsolutePath());

            // 返回可访问的相对路径
            String accessUrl = accessPrefix + "/" + newFileName;
            return Result.success("上传成功", accessUrl);
        } catch (IOException e) {
            log.error("视频上传失败", e);
            return Result.error("文件上传失败: " + e.getMessage());
        }
    }
}
