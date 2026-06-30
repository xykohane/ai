package com.aicompanion.controller;

import com.aicompanion.common.Result;
import com.aicompanion.mapper.AiChatMessageMapper;
import com.aicompanion.mapper.LearningRecordMapper;
import com.aicompanion.mapper.SkillMapper;
import com.aicompanion.mapper.SkillTreeMapper;
import com.aicompanion.mapper.UserMapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 仪表盘控制器
 * 从数据库查询真实统计数据
 */
@Tag(name = "仪表盘", description = "仪表盘统计数据接口")
@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final UserMapper userMapper;
    private final SkillMapper skillMapper;
    private final SkillTreeMapper skillTreeMapper;
    private final LearningRecordMapper learningRecordMapper;
    private final AiChatMessageMapper aiChatMessageMapper;

    @Operation(summary = "获取仪表盘数据", description = "从数据库查询真实统计数据")
    @GetMapping
    public Result<Map<String, Object>> getDashboardData() {
        Map<String, Object> data = new HashMap<>();

        // 统计用户总数
        data.put("totalUsers", userMapper.selectCount(null));

        // 统计技能数量（skill_tree表）
        data.put("totalSkills", skillTreeMapper.selectCount(null));

        // 统计学习记录数
        data.put("totalRecords", learningRecordMapper.selectCount(null));

        // 统计AI调用次数
        data.put("aiCalls", aiChatMessageMapper.selectCount(null));

        // 技能分布（按分类统计skill_tree表）
        List<Map<String, Object>> skillDistribution = new ArrayList<>();
        List<Map<String, Object>> categoryList = skillTreeMapper.selectMaps(null);
        Map<String, Integer> categoryCount = new HashMap<>();
        for (Map<String, Object> row : categoryList) {
            String category = (String) row.get("category");
            if (category != null) {
                categoryCount.merge(category, 1, Integer::sum);
            }
        }
        Map<String, String> categoryLabels = new HashMap<>();
        categoryLabels.put("FRONTEND", "前端");
        categoryLabels.put("BACKEND", "后端");
        categoryLabels.put("DATABASE", "数据库");
        categoryLabels.put("TOOL", "工具");
        for (Map.Entry<String, Integer> entry : categoryCount.entrySet()) {
            Map<String, Object> item = new HashMap<>();
            item.put("name", categoryLabels.getOrDefault(entry.getKey(), entry.getKey()));
            item.put("value", entry.getValue());
            skillDistribution.add(item);
        }
        data.put("skillDistribution", skillDistribution);

        // 最近活动（从学习记录表取最近5条）
        List<Map<String, Object>> recentActivities = new ArrayList<>();
        List<Map<String, Object>> records = learningRecordMapper.selectMaps(null);
        // 取最多5条
        int limit = Math.min(5, records.size());
        for (int i = records.size() - 1; i >= 0 && limit > 0; i--, limit--) {
            Map<String, Object> record = records.get(i);
            Map<String, Object> activity = new HashMap<>();
            activity.put("content", "学习技能：" + record.getOrDefault("skill_name", "未知"));
            Object createTime = record.get("create_time");
            activity.put("time", createTime != null ? createTime.toString() : "");
            recentActivities.add(activity);
        }
        data.put("recentActivities", recentActivities);

        // 近7天AI调用次数（按天统计）
        List<Integer> aiCallsLast7Days = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.atTime(LocalTime.MAX);
            QueryWrapper<com.aicompanion.entity.AiChatMessage> wrapper = new QueryWrapper<>();
            wrapper.between("create_time", start, end);
            long count = aiChatMessageMapper.selectCount(wrapper);
            aiCallsLast7Days.add((int) count);
        }
        data.put("aiCallsLast7Days", aiCallsLast7Days);

        // 近30天用户增长趋势（累计用户数）
        List<Integer> userGrowthLast30Days = new ArrayList<>();
        for (int i = 29; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            LocalDateTime end = date.atTime(LocalTime.MAX);
            QueryWrapper<com.aicompanion.entity.User> wrapper = new QueryWrapper<>();
            wrapper.le("create_time", end);
            long count = userMapper.selectCount(wrapper);
            userGrowthLast30Days.add((int) count);
        }
        data.put("userGrowthLast30Days", userGrowthLast30Days);

        return Result.success(data);
    }
}
