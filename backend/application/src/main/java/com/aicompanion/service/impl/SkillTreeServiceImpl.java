package com.aicompanion.service.impl;

import com.aicompanion.common.exception.BusinessException;

import com.aicompanion.entity.SkillTree;
import com.aicompanion.mapper.SkillTreeMapper;
import com.aicompanion.service.SkillTreeService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 技能树服务实现类
 */
@Service
@RequiredArgsConstructor
public class SkillTreeServiceImpl implements SkillTreeService {

    private final SkillTreeMapper skillTreeMapper;

    @Override
    public boolean createSkill(SkillTree skillTree) {
        if (skillTree.getParentId() == null) {
            skillTree.setParentId(0L);
        }
        if (skillTree.getSortOrder() == null) {
            skillTree.setSortOrder(0);
        }
        if (skillTree.getLevel() == null) {
            skillTree.setLevel(1);
        }
        return skillTreeMapper.insert(skillTree) > 0;
    }

    @Override
    public boolean deleteSkill(Long id) {
        // 逻辑删除（配置了@TableLogic后，deleteById会自动转为UPDATE deleted=1）
        return skillTreeMapper.deleteById(id) > 0;
    }

    @Override
    public List<SkillTree> listSkills() {
        // selectList(null) 查询全部，自动过滤 deleted=1 的记录
        return skillTreeMapper.selectList(null);
    }

    @Override
    public List<SkillTree> listByCategory(String category) {
        LambdaQueryWrapper<SkillTree> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SkillTree::getCategory, category)
                .orderByAsc(SkillTree::getSortOrder);
        return skillTreeMapper.selectList(wrapper);
    }

    @Override
    public Page<SkillTree> listSkillsByPage(int page, int size, String category, String keyword) {
        Page<SkillTree> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<SkillTree> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(category)) {
            wrapper.eq(SkillTree::getCategory, category);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.like(SkillTree::getName, keyword);
        }
        wrapper.orderByAsc(SkillTree::getSortOrder);
        return skillTreeMapper.selectPage(pageParam, wrapper);
    }

    @Override
    public SkillTree getSkillById(Long id) {
        return skillTreeMapper.selectById(id);
    }

    @Override
    public boolean updateSkill(Long id, SkillTree skillTree) {
        SkillTree existing = skillTreeMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("技能不存在");
        }
        skillTree.setId(id);
        return skillTreeMapper.updateById(skillTree) > 0;
    }
}
