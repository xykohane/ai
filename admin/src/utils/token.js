// src/utils/token.js
// Token 读写工具（基于 localStorage 持久化）
// 集中管理 key，避免散布在各文件中

const TOKEN_KEY = 'ai_companion_token'

// 获取 Token
export function getToken() {
  return localStorage.getItem(TOKEN_KEY)
}

// 设置 Token
export function setToken(token) {
  localStorage.setItem(TOKEN_KEY, token)
}

// 移除 Token
export function removeToken() {
  localStorage.removeItem(TOKEN_KEY)
}
