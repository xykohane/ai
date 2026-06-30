<!-- src/views/skill/index.vue -->
<!-- 技能树管理页面（已连接真实后端） -->
<template>
  <div class="skill-page">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span>技能树管理</span>
          <div class="search-bar">
            <el-select
              v-model="filterCategory"
              placeholder="按分类筛选"
              clearable
              style="width: 160px"
              @change="handleFilterChange"
            >
              <el-option label="前端" value="FRONTEND" />
              <el-option label="后端" value="BACKEND" />
              <el-option label="数据库" value="DATABASE" />
              <el-option label="工具" value="TOOL" />
            </el-select>
            <el-input
              v-model="keyword"
              placeholder="搜索技能名称"
              clearable
              style="width: 220px"
              @clear="handleSearch"
              @keyup.enter="handleSearch"
            />
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button type="success" @click="openAddDialog">
              <el-icon style="margin-right: 4px"><Plus /></el-icon>新增技能
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="技能名称" min-width="160" />
        <el-table-column prop="category" label="分类" width="120">
          <template #default="{ row }">
            <el-tag :type="categoryTagType(row.category)">{{ categoryLabel(row.category) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="level" label="难度" width="160" align="center">
          <template #default="{ row }">
            <el-rate v-model="row.level" disabled :max="5" />
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="220" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="openEditDialog(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
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

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="editingSkill ? '编辑技能' : '新增技能'" width="520px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入技能名称" />
        </el-form-item>
        <el-form-item label="分类" prop="category">
          <el-select v-model="form.category" placeholder="请选择分类" style="width: 100%">
            <el-option label="前端" value="FRONTEND" />
            <el-option label="后端" value="BACKEND" />
            <el-option label="数据库" value="DATABASE" />
            <el-option label="工具" value="TOOL" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度" prop="level">
          <el-rate v-model="form.level" :max="5" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入技能描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getSkillPage, createSkill, updateSkill, deleteSkill } from '../../api/skill'

// ---- 响应式状态 ----
const list = ref([])
const loading = ref(false)
const keyword = ref('')
const filterCategory = ref('')
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

// ---- 从后端加载技能列表（服务端分页）----
async function fetchData() {
  loading.value = true
  try {
    const res = await getSkillPage({
      page: page.value,
      size: pageSize.value,
      category: filterCategory.value || undefined,
      keyword: keyword.value.trim() || undefined
    })
    list.value = res.records || []
    total.value = res.total || 0
  } catch (err) {
    ElMessage.error('加载技能列表失败')
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

function handleFilterChange() {
  page.value = 1
  fetchData()
}

// ---- 分类辅助函数 ----
function categoryLabel(c) {
  return { FRONTEND: '前端', BACKEND: '后端', DATABASE: '数据库', TOOL: '工具' }[c] || c
}

function categoryTagType(c) {
  return { FRONTEND: 'success', BACKEND: 'warning', DATABASE: 'danger', TOOL: 'info' }[c] || ''
}

// ---- 新增/编辑弹窗 ----
const dialogVisible = ref(false)
const submitting = ref(false)
const formRef = ref(null)
const editingSkill = ref(null)
const form = reactive({
  name: '',
  category: '',
  level: 1,
  description: ''
})

const rules = {
  name: [
    { required: true, message: '请输入技能名称', trigger: 'blur' },
    { min: 2, max: 30, message: '名称长度为 2-30 个字符', trigger: 'blur' }
  ],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }],
  level: [{ required: true, message: '请选择难度', trigger: 'change' }],
  description: [{ required: true, message: '请输入描述', trigger: 'blur' }]
}

function openAddDialog() {
  editingSkill.value = null
  Object.assign(form, { name: '', category: '', level: 1, description: '' })
  dialogVisible.value = true
}

function openEditDialog(row) {
  editingSkill.value = row
  Object.assign(form, {
    name: row.name,
    category: row.category,
    level: row.level,
    description: row.description
  })
  dialogVisible.value = true
}

// 提交（新增 or 编辑）
async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    if (editingSkill.value) {
      await updateSkill(editingSkill.value.id, { ...form })
      ElMessage.success('编辑成功')
    } else {
      await createSkill({ ...form })
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    fetchData()
  } catch (err) {
    ElMessage.error(err.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

// ---- 删除 ----
async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(`确定删除技能「${row.name}」吗？`, '提示', { type: 'warning' })
    await deleteSkill(row.id)
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
