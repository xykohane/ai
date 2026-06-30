// src/api/user.js
// 用户管理相关 API（已连接真实后端）
import request from './request'

// 获取当前登录用户信息
export function getCurrentUser() {
  return request.get('/api/users/me')
}

// 获取用户列表（后端返回 Page 分页对象）
export function getUserList(params) {
  return request.get('/api/users/list', { params })
}

// 更新用户信息（角色修改等）
export function updateUser(id, data) {
  return request.put(`/api/users/admin/${id}`, data)
}

// 更新用户角色（兼容旧调用）
export function updateUserRole(id, role) {
  return request.put(`/api/users/admin/${id}`, { role: role.toUpperCase() })
}

// 删除用户
export function deleteUser(id) {
  return request.delete(`/api/users/${id}`)
}
