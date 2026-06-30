<!-- src/views/user/index.vue -->
<!-- 用户管理页面：搜索 + 列表 + 分页 + 角色修改（已连接真实后端） -->
<template>
  <div class="user-page">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <div class="search-bar">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索用户名"
              clearable
              style="width: 240px"
              @clear="handleSearch"
              @keyup.enter="handleSearch"
            />
            <el-select v-model="searchRole" placeholder="角色筛选" clearable style="width: 140px" @change="handleSearch">
              <el-option label="管理员" value="ADMIN" />
              <el-option label="教师" value="TEACHER" />
              <el-option label="学生" value="STUDENT" />
            </el-select>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
          </div>
        </div>
      </template>

      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="nickname" label="昵称" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="role" label="角色" width="120">
          <template #default="{ row }">
            <el-tag :type="roleTagType(row.role)">{{ roleLabel(row.role) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-select
              v-model="row.role"
              size="small"
              style="width: 100px"
              @change="handleRoleChange(row)"
            >
              <el-option label="管理员" value="ADMIN" />
              <el-option label="教师" value="TEACHER" />
              <el-option label="学生" value="STUDENT" />
            </el-select>
            <el-button size="small" type="danger" @click="handleDelete(row)" style="margin-left: 8px">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="fetchData"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getUserList, updateUserRole, deleteUser } from '../../api/user'

// ---- 响应式状态 ----
const list = ref([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const searchKeyword = ref('')
const searchRole = ref('')

// ---- 角色辅助函数 ----
function roleLabel(role) {
  const map = { ADMIN: '管理员', TEACHER: '教师', STUDENT: '学生' }
  return map[(role || '').toUpperCase()] || role
}

function roleTagType(role) {
  const map = { ADMIN: 'danger', TEACHER: 'warning', STUDENT: 'info' }
  return map[(role || '').toUpperCase()] || ''
}

// ---- 从后端 API 加载数据（服务端分页）----
async function fetchData() {
  loading.value = true
  try {
    const res = await getUserList({
      page: page.value,
      size: pageSize.value,
      username: searchKeyword.value || undefined,
      role: searchRole.value || undefined
    })
    // 后端返回 Page 对象：{ records, total, current, size }
    list.value = res.records || []
    total.value = res.total || 0
  } catch (err) {
    ElMessage.error('加载用户列表失败')
    list.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchData()
})

function handleSearch() {
  page.value = 1
  fetchData()
}

// ---- 修改角色 ----
async function handleRoleChange(row) {
  try {
    await updateUserRole(row.id, row.role)
    ElMessage.success(`已将 ${row.nickname} 的角色修改为 ${roleLabel(row.role)}`)
  } catch {
    ElMessage.error('角色修改失败')
    fetchData()
  }
}

// ---- 删除用户 ----
async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(`确定删除用户「${row.nickname}」吗？`, '提示', { type: 'warning' })
    await deleteUser(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch (err) {
    if (err !== 'cancel' && err?.message !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.search-bar {
  display: flex;
  gap: 8px;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
