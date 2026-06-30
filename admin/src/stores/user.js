// src/stores/user.js
// 用户状态管理 Store（Pinia 组合式 API 风格）
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { getCurrentUser } from '../api/user'
import { login as loginApi } from '../api/auth'
import { setToken, removeToken, getToken } from '../utils/token'

export const useUserStore = defineStore('user', () => {
  // ---- State（状态）----
  const user = ref(null) // 当前用户信息对象
  const token = ref(getToken()) // JWT Token（从 localStorage 恢复，刷新页面不丢失）

  // ---- Getters（计算属性）----
  const isLoggedIn = computed(() => !!token.value)
  // 后端角色为大写（ADMIN/TEACHER/STUDENT），统一转小写比较
  const isAdmin = computed(() => user.value?.role?.toLowerCase() === 'admin')

  // ---- Actions（操作方法）----
  async function login(data) {
    // 1. 调用后端登录接口
    const res = await loginApi(data)
    // 2. 保存 Token（Pinia state + localStorage 双重存储）
    // 后端返回 LoginVO: { token, user: UserVO }
    token.value = res.token
    setToken(res.token)
    // 3. 如果返回中包含用户信息，直接使用；否则请求获取
    if (res.user) {
      user.value = res.user
    } else {
      await fetchUserInfo()
    }
  }

  async function fetchUserInfo() {
    const res = await getCurrentUser()
    user.value = res
  }

  function logout() {
    user.value = null
    token.value = null
    removeToken()
  }

  // 返回所有需要暴露的状态和方法
  return { user, token, isLoggedIn, isAdmin, login, fetchUserInfo, logout }
})
