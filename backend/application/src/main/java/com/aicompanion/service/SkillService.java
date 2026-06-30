package com.aicompanion.service;

import com.aicompanion.dto.SkillDTO;
import com.aicompanion.dto.UserSkillDTO;
import com.aicompanion.vo.SkillLightStatusVO;
import com.aicompanion.vo.SkillVO;

import java.util.List;

/**
 * 技能服务接口
 */
public interface SkillService {

    // ==================== Web端 ====================

    /**
     * 查询技能树（关联当前用户学习情况）
     *
     * @param userId 用户ID
     * @return 技能树
     */
    List<SkillVO> getSkillTree(Long userId);

    /**
     * 点亮技能（更新用户技能关联）
     *
     * @param userId       用户ID
     * @param userSkillDTO 技能信息
     * @return 是否成功
     */
    boolean lightUpSkill(Long userId, UserSkillDTO userSkillDTO);

    /**
     * 生成技能点学习建议
     *
     * @param userId  用户ID
     * @param skillId 技能ID
     * @return 学习建议
     */
    String generateLearningAdvice(Long userId, Long skillId);

    // ==================== Admin端 ====================

    /**
     * 新增技能
     *
     * @param skillDTO 技能信息
     * @return 是否成功
     */
    boolean createSkill(SkillDTO skillDTO);

    /**
     * 修改技能
     *
     * @param id       技能ID
     * @param skillDTO 技能信息
     * @return 是否成功
     */
    boolean updateSkill(Long id, SkillDTO skillDTO);

    /**
     * 删除技能
     *
     * @param id 技能ID
     * @return 是否成功
     */
    boolean deleteSkill(Long id);

    /**
     * 查询技能详情
     *
     * @param id 技能ID
     * @return 技能信息
     */
    SkillVO getSkillById(Long id);

    /**
     * 查询所有技能列表（不分层级）
     *
     * @return 技能列表
     */
    List<SkillVO> listAllSkills();

    /**
     * 查询技能点亮情况（多少个点亮）
     *
     * @return 技能点亮情况列表
     */
    List<SkillLightStatusVO> getSkillLightStatus();
}
