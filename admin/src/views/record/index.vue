<!-- src/views/record/index.vue -->
<!-- 课后练习1：学习记录页面 —— Mock 数据 + 按用户名搜索 + 前端分页 -->
<template>
  <div class="record-page">
    <el-card shadow="hover">
      <!-- 卡片头部：标题 + 搜索栏 -->
      <template #header>
        <div class="card-header">
          <span>学习记录</span>
          <div class="search-bar">
            <el-input
              v-model="keyword"
              placeholder="搜索用户名/昵称"
              clearable
              style="width: 240px"
              @clear="handleSearch"
              @keyup.enter="handleSearch"
            />
            <el-button type="primary" @click="handleSearch">搜索</el-button>
          </div>
        </div>
      </template>

      <!-- 学习记录表格 -->
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="nickname" label="昵称" width="100" />
        <el-table-column prop="course" label="学习课程" min-width="200" />
        <el-table-column prop="duration" label="学习时长(分钟)" width="130" align="center">
          <template #default="{ row }">
            <el-tag type="success" effect="plain">{{ row.duration }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="score" label="得分" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.score >= 90 ? 'success' : row.score >= 80 ? 'warning' : 'danger'">
              {{ row.score }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="学习时间" width="180" />
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { mockRecordList } from '../../mock/record'

// ---- 响应式状态 ----
const allData = ref([...mockRecordList]) // 全量数据（模拟数据库）
const loading = ref(false)
const keyword = ref('') // 搜索关键词
const page = ref(1) // 当前页码
const pageSize = ref(5) // 每页条数

// ---- 计算属性：过滤 + 分页 ----
// 练习1：按用户名搜索（同时支持昵称）
const filteredData = computed(() => {
  if (!keyword.value) return allData.value
  const kw = keyword.value.toLowerCase()
  return allData.value.filter(
    (r) => r.username.toLowerCase().includes(kw) || r.nickname.toLowerCase().includes(kw)
  )
})

const total = computed(() => filteredData.value.length)

const list = computed(() => {
  const start = (page.value - 1) * pageSize.value
  return filteredData.value.slice(start, start + pageSize.value)
})

// ---- 搜索 ----
function handleSearch() {
  page.value = 1 // 搜索后回到第一页
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
