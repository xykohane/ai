// src/api/skill.js
// 技能树管理相关 API（已连接真实后端）
import request from './request'

// 获取技能列表（全部）
export function getSkillList() {
  return request.get('/api/skill-tree/list')
}

// 分页查询技能
export function getSkillPage(params) {
  return request.get('/api/skill-tree/page', { params })
}

// 按分类查询
export function getSkillByCategory(category) {
  return request.get(`/api/skill-tree/category/${category}`)
}

// 获取技能详情
export function getSkillById(id) {
  return request.get(`/api/skill-tree/${id}`)
}

// 新增技能
export function createSkill(data) {
  return request.post('/api/skill-tree', data)
}

// 更新技能
export function updateSkill(id, data) {
  return request.put(`/api/skill-tree/${id}`, data)
}

// 删除技能
export function deleteSkill(id) {
  return request.delete(`/api/skill-tree/${id}`)
}
