// src/api/auth.js
// 认证相关 API（已连接真实后端）
import request from './request'

// 登录
export function login(data) {
  return request.post('/api/auth/login', data)
}

// 注册
export function register(data) {
  return request.post('/api/auth/register', data)
}
