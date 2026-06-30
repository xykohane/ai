// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/login/index.vue'),
    meta: { title: '登录', requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('../components/layout/AppLayout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/dashboard/index.vue'),
        meta: { title: '仪表盘', requiresAuth: true }
      },
      {
        path: 'user',
        name: 'User',
        component: () => import('../views/user/index.vue'),
        meta: { title: '用户管理', requiresAuth: true }
      },
      {
        path: 'skill',
        name: 'Skill',
        component: () => import('../views/skill/index.vue'),
        meta: { title: '技能树管理', requiresAuth: true }
      },
      {
        path: 'record',
        name: 'Record',
        component: () => import('../views/record/index.vue'),
        meta: { title: '学习记录', requiresAuth: true }
      }
    ]
  },
  {
    // 兜底路由：未匹配的路径重定向到仪表盘
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 全局前置守卫：每次路由跳转前自动执行
router.beforeEach((to, _from, next) => {
  // 1. 设置页面标题
  document.title = `${to.meta.title || 'AI伴学平台'} - 管理后台`

  // 2. 改造点：从 Pinia 读取登录状态（替代 localStorage 直接读取）
  const userStore = useUserStore()

  // 3. 权限判断
  if (to.path !== '/login' && !userStore.isLoggedIn) {
    // 未登录访问需要认证的页面 → 跳转登录页
    next('/login')
  } else if (to.path === '/login' && userStore.isLoggedIn) {
    // 已登录却访问登录页 → 跳转仪表盘
    next('/dashboard')
  } else {
    // 正常放行
    next()
  }
})

export default router
