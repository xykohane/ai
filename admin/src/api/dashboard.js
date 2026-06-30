// src/api/dashboard.js
// Dashboard 仪表盘接口封装（连接真实后端）

import request from './request'

// 获取仪表盘数据
export function getDashboardData() {
  return request.get('/api/dashboard')
}
