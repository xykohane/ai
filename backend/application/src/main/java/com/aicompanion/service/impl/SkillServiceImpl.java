package com.aicompanion.service.impl;

import com.aicompanion.common.exception.BusinessException;

import com.aicompanion.dto.SkillDTO;
import com.aicompanion.dto.UserSkillDTO;
import com.aicompanion.entity.LearningRecord;
import com.aicompanion.entity.Skill;
import com.aicompanion.entity.UserSkill;
import com.aicompanion.mapper.LearningRecordMapper;
import com.aicompanion.mapper.SkillMapper;
import com.aicompanion.mapper.UserSkillMapper;
import com.aicompanion.service.SkillService;
import com.aicompanion.vo.SkillLightStatusVO;
import com.aicompanion.vo.SkillVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 技能服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SkillServiceImpl implements SkillService {

    private final SkillMapper skillMapper;
    private final UserSkillMapper userSkillMapper;
    private final LearningRecordMapper learningRecordMapper;

    // ==================== Web端 ====================

    @Override
    public List<SkillVO> getSkillTree(Long userId) {
        // 查询所有技能
        List<Skill> allSkills = skillMapper.selectList(null);

        // 查询当前用户的技能学习情况
        LambdaQueryWrapper<UserSkill> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(UserSkill::getUserId, userId);
        List<UserSkill> userSkills = userSkillMapper.selectList(queryWrapper);

        // 构建用户技能映射
        Map<Long, UserSkill> userSkillMap = userSkills.stream()
                .collect(Collectors.toMap(UserSkill::getSkillId, us -> us));

        // 转换为VO
        List<SkillVO> allSkillVOs = allSkills.stream()
                .map(skill -> {
                    SkillVO vo = convertToSkillVO(skill);
                    UserSkill us = userSkillMap.get(skill.getId());
                    if (us != null) {
                        vo.setUserStatus(us.getStatus());
                        vo.setUserLevel(us.getLevel());
                    } else {
                        vo.setUserStatus(0);
                        vo.setUserLevel(0);
                    }
                    return vo;
                })
                .collect(Collectors.toList());

        // 构建树形结构
        return buildSkillTree(allSkillVOs);
    }

    @Override
    @Transactional
    public boolean lightUpSkill(Long userId, UserSkillDTO userSkillDTO) {
        // 检查技能是否存在
        Skill skill = skillMapper.selectById(userSkillDTO.getSkillId());
        if (skill == null) {
            throw new BusinessException("技能不存在");
        }

        // 查询是否已有关联记录
        LambdaQueryWrapper<UserSkill> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(UserSkill::getUserId, userId)
                .eq(UserSkill::getSkillId, userSkillDTO.getSkillId());
        UserSkill existing = userSkillMapper.selectOne(queryWrapper);

        if (existing != null) {
            // 更新已有记录
            if (userSkillDTO.getLevel() != null) {
                existing.setLevel(userSkillDTO.getLevel());
            }
            if (userSkillDTO.getStatus() != null) {
                existing.setStatus(userSkillDTO.getStatus());
            }
            return userSkillMapper.updateById(existing) > 0;
        } else {
            // 创建新记录
            UserSkill userSkill = new UserSkill();
            userSkill.setUserId(userId);
            userSkill.setSkillId(userSkillDTO.getSkillId());
            userSkill.setLevel(userSkillDTO.getLevel() != null ? userSkillDTO.getLevel() : 1);
            userSkill.setStatus(userSkillDTO.getStatus() != null ? userSkillDTO.getStatus() : 1);
            return userSkillMapper.insert(userSkill) > 0;
        }
    }

    @Override
    public String generateLearningAdvice(Long userId, Long skillId) {
        // 检查技能是否存在
        Skill skill = skillMapper.selectById(skillId);
        if (skill == null) {
            throw new BusinessException("技能不存在");
        }

        // 查询用户当前学习情况
        LambdaQueryWrapper<UserSkill> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(UserSkill::getUserId, userId)
                .eq(UserSkill::getSkillId, skillId);
        UserSkill userSkill = userSkillMapper.selectOne(queryWrapper);

        StringBuilder advice = new StringBuilder();
        advice.append("【").append(skill.getName()).append("】学习建议：\n");

        if (userSkill == null) {
            advice.append("您尚未开始学习该技能。建议从基础概念开始学习。\n");
        } else {
            switch (userSkill.getStatus()) {
                case 0:
                    advice.append("您尚未开始学习，建议制定学习计划，每天投入30分钟。\n");
                    break;
                case 1:
                    advice.append("您正在学习中，当前掌握程度为").append(userSkill.getLevel()).append("/5。\n");
                    if (userSkill.getLevel() <= 2) {
                        advice.append("建议先巩固基础知识，完成相关练习。\n");
                    } else {
                        advice.append("建议进行项目实战，加深理解。\n");
                    }
                    break;
                case 2:
                    advice.append("恭喜您已掌握该技能！建议学习进阶内容或相关技能。\n");
                    break;
                default:
                    advice.append("学习状态异常，请联系管理员。\n");
            }
        }

        // 推荐父技能或子技能
        if (skill.getParentId() != null && skill.getParentId() > 0) {
            Skill parentSkill = skillMapper.selectById(skill.getParentId());
            if (parentSkill != null) {
                advice.append("相关前置技能：").append(parentSkill.getName()).append("\n");
            }
        }

        return advice.toString();
    }

    // ==================== Admin端 ====================

    @Override
    @Transactional
    public boolean createSkill(SkillDTO skillDTO) {
        Skill skill = new Skill();
        BeanUtils.copyProperties(skillDTO, skill);
        if (skill.getParentId() == null) {
            skill.setParentId(0L);
        }
        if (skill.getSortOrder() == null) {
            skill.setSortOrder(0);
        }
        if (skill.getLevel() == null) {
            skill.setLevel(1);
        }
        return skillMapper.insert(skill) > 0;
    }

    @Override
    @Transactional
    public boolean updateSkill(Long id, SkillDTO skillDTO) {
        Skill skill = skillMapper.selectById(id);
        if (skill == null) {
            throw new BusinessException("技能不存在");
        }
        BeanUtils.copyProperties(skillDTO, skill);
        skill.setId(id);
        return skillMapper.updateById(skill) > 0;
    }

    @Override
    @Transactional
    public boolean deleteSkill(Long id) {
        Skill skill = skillMapper.selectById(id);
        if (skill == null) {
            throw new BusinessException("技能不存在");
        }
        // 检查是否有子技能
        LambdaQueryWrapper<Skill> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Skill::getParentId, id);
        Long childCount = skillMapper.selectCount(queryWrapper);
        if (childCount > 0) {
            throw new BusinessException("该技能下还有子技能，无法删除");
        }
        return skillMapper.deleteById(id) > 0;
    }

    @Override
    public SkillVO getSkillById(Long id) {
        Skill skill = skillMapper.selectById(id);
        if (skill == null) {
            throw new BusinessException("技能不存在");
        }
        return convertToSkillVO(skill);
    }

    @Override
    public List<SkillVO> listAllSkills() {
        List<Skill> skills = skillMapper.selectList(null);
        return skills.stream()
                .map(this::convertToSkillVO)
                .collect(Collectors.toList());
    }

    @Override
    public List<SkillLightStatusVO> getSkillLightStatus() {
        // 查询所有技能
        List<Skill> allSkills = skillMapper.selectList(null);

        // 查询所有用户技能关联
        List<UserSkill> allUserSkills = userSkillMapper.selectList(null);

        // 按技能ID统计
        Map<Long, List<UserSkill>> skillUserMap = allUserSkills.stream()
                .collect(Collectors.groupingBy(UserSkill::getSkillId));

        return allSkills.stream()
                .map(skill -> {
                    SkillLightStatusVO vo = new SkillLightStatusVO();
                    vo.setSkillId(skill.getId());
                    vo.setSkillName(skill.getName());
                    vo.setCategory(skill.getCategory());

                    List<UserSkill> userSkills = skillUserMap.getOrDefault(skill.getId(), new ArrayList<>());
                    long litCount = userSkills.stream().filter(us -> us.getStatus() == 2).count();
                    long learningCount = userSkills.stream().filter(us -> us.getStatus() == 1).count();
                    long notStartedCount = userSkills.stream().filter(us -> us.getStatus() == 0).count();

                    vo.setLitCount(litCount);
                    vo.setLearningCount(learningCount);
                    vo.setNotStartedCount(notStartedCount);

                    return vo;
                })
                .collect(Collectors.toList());
    }

    /**
     * 将Skill实体转换为SkillVO
     */
    private SkillVO convertToSkillVO(Skill skill) {
        SkillVO vo = new SkillVO();
        BeanUtils.copyProperties(skill, vo);
        return vo;
    }

    /**
     * 构建技能树（树形结构）
     */
    private List<SkillVO> buildSkillTree(List<SkillVO> allSkillVOs) {
        // 按parentId分组
        Map<Long, List<SkillVO>> parentMap = allSkillVOs.stream()
                .collect(Collectors.groupingBy(SkillVO::getParentId));

        // 为每个节点设置子节点
        allSkillVOs.forEach(skillVO -> {
            List<SkillVO> children = parentMap.get(skillVO.getId());
            if (children != null) {
                skillVO.setChildren(children);
            }
        });

        // 返回顶层节点
        return parentMap.getOrDefault(0L, new ArrayList<>());
    }
}
