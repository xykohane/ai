package com.aicompanion.service;

import com.aicompanion.entity.LearningVideo;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.List;

/**
 * 在线学习视频服务接口
 */
public interface LearningVideoService {

    /**
     * 新增视频
     */
    boolean createVideo(LearningVideo video);

    /**
     * 删除视频（逻辑删除）
     */
    boolean deleteVideo(Long id);

    /**
     * 更新视频
     */
    boolean updateVideo(Long id, LearningVideo video);

    /**
     * 根据ID查询视频
     */
    LearningVideo getVideoById(Long id);

    /**
     * 查询全部视频
     */
    List<LearningVideo> listVideos();

    /**
     * 按模块查询视频
     */
    List<LearningVideo> listByModule(String moduleName);

    /**
     * 分页查询
     */
    Page<LearningVideo> listVideosByPage(int page, int size, String moduleName, String keyword);
}
