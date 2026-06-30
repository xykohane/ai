package com.aicompanion.service.impl;

import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.entity.LearningVideo;
import com.aicompanion.mapper.LearningVideoMapper;
import com.aicompanion.service.LearningVideoService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 在线学习视频服务实现类
 */
@Service
@RequiredArgsConstructor
public class LearningVideoServiceImpl implements LearningVideoService {

    private final LearningVideoMapper learningVideoMapper;

    @Override
    public boolean createVideo(LearningVideo video) {
        if (video.getSortOrder() == null) {
            video.setSortOrder(0);
        }
        if (video.getDuration() == null) {
            video.setDuration(0);
        }
        return learningVideoMapper.insert(video) > 0;
    }

    @Override
    public boolean deleteVideo(Long id) {
        return learningVideoMapper.deleteById(id) > 0;
    }

    @Override
    public List<LearningVideo> listVideos() {
        return learningVideoMapper.selectList(null);
    }

    @Override
    public List<LearningVideo> listByModule(String moduleName) {
        LambdaQueryWrapper<LearningVideo> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(moduleName)) {
            wrapper.eq(LearningVideo::getModuleName, moduleName);
        }
        wrapper.orderByAsc(LearningVideo::getSortOrder);
        return learningVideoMapper.selectList(wrapper);
    }

    @Override
    public Page<LearningVideo> listVideosByPage(int page, int size, String moduleName, String keyword) {
        Page<LearningVideo> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<LearningVideo> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(moduleName)) {
            wrapper.eq(LearningVideo::getModuleName, moduleName);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.like(LearningVideo::getTitle, keyword);
        }
        wrapper.orderByAsc(LearningVideo::getSortOrder);
        return learningVideoMapper.selectPage(pageParam, wrapper);
    }

    @Override
    public LearningVideo getVideoById(Long id) {
        return learningVideoMapper.selectById(id);
    }

    @Override
    public boolean updateVideo(Long id, LearningVideo video) {
        LearningVideo existing = learningVideoMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("视频不存在");
        }
        video.setId(id);
        return learningVideoMapper.updateById(video) > 0;
    }
}
