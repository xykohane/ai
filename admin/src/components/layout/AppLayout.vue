<!-- src/components/layout/AppLayout.vue -->
<!-- 后台管理布局：侧边栏 + 顶栏 + 内容区 -->
<!-- 改造点：使用 Pinia userStore 管理用户信息，onMounted 自动恢复 -->
<template>
  <el-container class="app-layout">
    <!-- 左侧边栏 -->
    <el-aside :width="appStore.sidebarCollapsed ? '64px' : '220px'" class="sidebar">
      <div class="logo">
        <h1 v-show="!appStore.sidebarCollapsed">AI伴学平台</h1>
        <h1 v-show="appStore.sidebarCollapsed">AI</h1>
      </div>
      <el-menu
        :default-active="route.path"
        :collapse="appStore.sidebarCollapsed"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409eff"
      >
        <el-menu-item index="/dashboard">
          <el-icon><Odometer /></el-icon>
          <template #title>仪表盘</template>
        </el-menu-item>
        <el-menu-item index="/user">
          <el-icon><User /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>
        <el-menu-item index="/skill">
          <el-icon><Share /></el-icon>
          <template #title>技能树管理</template>
        </el-menu-item>
        <el-menu-item index="/record">
          <el-icon><Document /></el-icon>
          <template #title>学习记录</template>
        </el-menu-item>
        <el-menu-item index="/video">
          <el-icon><VideoCamera /></el-icon>
          <template #title>视频管理</template>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- 右侧内容区 -->
    <el-container>
      <el-header class="header">
        <div class="header-left">
          <el-icon class="collapse-btn" @click="appStore.toggleSidebar">
            <Fold v-if="!appStore.sidebarCollapsed" />
            <Expand v-else />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/dashboard' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item>{{ route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <span class="welcome">欢迎，{{ displayName }}</span>
          <el-button type="danger" plain size="small" @click="handleLogout">退出登录</el-button>
        </div>
      </el-header>
      <el-main class="main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAppStore } from '../../stores/app'
import { useUserStore } from '../../stores/user'
import { Odometer, User, Share, Document, Fold, Expand, VideoCamera } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const appStore = useAppStore()
const userStore = useUserStore()

// 改造点：从 userStore 读取用户信息（替代 localStorage 直接读取）
const displayName = computed(() => userStore.user?.nickname || userStore.user?.username || '管理员')

// 页面加载时，如果已登录但没有用户信息（如刷新页面），重新获取
onMounted(async () => {
  if (userStore.isLoggedIn && !userStore.user) {
    try {
      await userStore.fetchUserInfo()
    } catch {
      userStore.logout()
      router.push('/login')
    }
  }
})

// 退出登录：统一走 userStore.logout()
function handleLogout() {
  userStore.logout()
  ElMessage.success('已退出登录')
  router.push('/login')
}
</script>

<style scoped>
.app-layout {
  height: 100vh;
}

/* 练习4：侧边栏宽度过渡动画 */
.sidebar {
  background-color: #304156;
  transition: width 0.3s ease;
  overflow-x: hidden;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #2b3a4d;
}

.logo h1 {
  color: #fff;
  font-size: 18px;
  white-space: nowrap;
}

/* el-menu 折叠时的过渡 */
.sidebar :deep(.el-menu) {
  border-right: none;
  transition: width 0.3s ease;
}

.header {
  height: 60px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collapse-btn {
  font-size: 20px;
  cursor: pointer;
  color: #5a5e66;
  transition: color 0.2s;
}

.collapse-btn:hover {
  color: #409eff;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.welcome {
  color: #606266;
  font-size: 14px;
}

.main {
  background: #f0f2f5;
  padding: 20px;
  overflow-y: auto;
}
</style>
