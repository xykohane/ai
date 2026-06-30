// src/main.js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import 'element-plus/dist/index.css'
import App from './App.vue'
import router from './router'

// 1. 创建 Vue 应用实例
const app = createApp(App)

// 2. 全局注册所有 Element Plus 图标组件
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

// 3. 注册插件（顺序：Pinia 必须在 Router 之前）
app.use(createPinia()) // 状态管理
app.use(router) // 路由
app.use(ElementPlus) // UI 组件库

// 4. 挂载到 DOM
app.mount('#app')
