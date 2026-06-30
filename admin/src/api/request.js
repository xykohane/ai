// src/api/request.js
// Axios 实例封装：请求拦截器（Token 注入）+ 响应拦截器（解包 + 错误处理）
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { getToken, removeToken } from '../utils/token'

const service = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL, // 从环境变量读取
  timeout: 15000, // 请求超时 15 秒
  headers: { 'Content-Type': 'application/json' }
})

// ---- 请求拦截器：自动注入 Bearer Token ----
service.interceptors.request.use(
  (config) => {
    const token = getToken()
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// 改进点：401 防重复跳转标志，避免多个并发请求同时 401 时重复跳转登录页
let isRedirecting = false

// ---- 响应拦截器：解包 ApiResponse，统一处理错误 ----
service.interceptors.response.use(
  (response) => {
    const res = response.data
    // 不是标准 ApiResponse 格式，直接返回
    if (res.code === undefined) {
      return response
    }
    // 成功：解包返回 data 字段
    if (res.code === 200 || res.code === 0) {
      return res.data
    }
    // 业务错误（code 非 200）
    ElMessage.error(res.message || '请求失败')
    return Promise.reject(new Error(res.message || '请求失败'))
  },
  (error) => {
    const status = error.response?.status
    if (status === 401) {
      // 作业3：401 授权认证失败处理
      ElMessage.error('授权认证失败，请重新登录')
      // 改进点：防重复跳转
      if (!isRedirecting) {
        isRedirecting = true
        removeToken()
        window.location.href = '/login'
      }
    } else if (status === 403) {
      ElMessage.error('没有权限访问该资源')
    } else if (status === 500) {
      ElMessage.error('服务器内部错误，请稍后再试')
    } else {
      ElMessage.error(error.response?.data?.message || error.message || '网络错误')
    }
    return Promise.reject(error)
  }
)

export default service
