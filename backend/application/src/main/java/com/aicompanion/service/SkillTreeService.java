package com.aicompanion.service;

import com.aicompanion.entity.SkillTree;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.List;

/**
 * 技能树服务接口
 */
public interface SkillTreeService {

    /**
     * 新增技能
     *
     * @param skillTree 技能信息
     * @return 是否成功
     */
    boolean createSkill(SkillTree skillTree);

    /**
     * 删除技能（逻辑删除）
     *
     * @param id 技能ID
     * @return 是否成功
     */
    boolean deleteSkill(Long id);

    /**
     * 查询技能树列表（全部）
     *
     * @return 技能列表
     */
    List<SkillTree> listSkills();

    /**
     * 按分类查询技能
     *
     * @param category 分类
     * @return 技能列表
     */
    List<SkillTree> listByCategory(String category);

    /**
     * 分页查询技能树
     *
     * @param page     页码
     * @param size     每页大小
     * @param category 分类（可选）
     * @param keyword  名称关键字（可选，模糊匹配）
     * @return 分页结果
     */
    Page<SkillTree> listSkillsByPage(int page, int size, String category, String keyword);

    /**
     * 根据ID查询技能详情
     *
     * @param id 技能ID
     * @return 技能信息
     */
    SkillTree getSkillById(Long id);

    /**
     * 更新技能信息
     *
     * @param id        技能ID
     * @param skillTree 技能信息
     * @return 是否成功
     */
    boolean updateSkill(Long id, SkillTree skillTree);
}
