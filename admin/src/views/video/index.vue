<!-- src/views/video/index.vue -->
<!-- 在线学习视频管理页面 -->
<template>
  <div class="video-page">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span>在线学习视频管理</span>
          <div class="search-bar">
            <el-select
              v-model="filterModule"
              placeholder="按模块筛选"
              clearable
              style="width: 160px"
              @change="handleFilterChange"
            >
              <el-option v-for="m in modules" :key="m" :label="m" :value="m" />
            </el-select>
            <el-input
              v-model="keyword"
              placeholder="搜索视频标题"
              clearable
              style="width: 220px"
              @clear="handleSearch"
              @keyup.enter="handleSearch"
            />
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button type="success" @click="openAddDialog">
              <el-icon style="margin-right: 4px"><Plus /></el-icon>新增视频
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="moduleName" label="模块" width="120">
          <template #default="{ row }">
            <el-tag :type="moduleTagType(row.moduleName)">{{ row.moduleName }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="视频标题" min-width="180" />
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column label="视频地址" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <el-link type="primary" :href="fullUrl(row.videoUrl)" target="_blank">{{ row.videoUrl }}</el-link>
          </template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="80" align="center" />
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
    <el-dialog v-model="dialogVisible" :title="editingVideo ? '编辑视频' : '新增视频'" width="560px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="模块" prop="moduleName">
          <el-select v-model="form.moduleName" placeholder="请选择模块" style="width: 100%">
            <el-option v-for="m in modules" :key="m" :label="m" :value="m" />
          </el-select>
        </el-form-item>
        <el-form-item label="视频标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入视频标题" />
        </el-form-item>
        <el-form-item label="视频描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入视频描述" />
        </el-form-item>
        <el-form-item label="视频文件" prop="videoUrl">
          <el-upload
            :show-file-list="false"
            :http-request="handleUpload"
            accept="video/*"
          >
            <el-button type="primary" :loading="uploading">
              {{ uploading ? `上传中 ${uploadProgress}%` : '点击上传视频' }}
            </el-button>
          </el-upload>
          <div v-if="form.videoUrl" class="upload-tip">
            已上传：<el-link type="success" :href="fullUrl(form.videoUrl)" target="_blank">{{ form.videoUrl }}</el-link>
          </div>
          <el-input v-model="form.videoUrl" placeholder="或手动填写视频地址" style="margin-top: 8px" />
        </el-form-item>
        <el-form-item label="排序" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" :max="999" />
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
import { getVideoPage, createVideo, updateVideo, deleteVideo, uploadVideo } from '../../api/video'

// 五大学习模块
const modules = ['政治理论', '言语理解', '数量关系', '判断推理', '资料分析']

// ---- 响应式状态 ----
const list = ref([])
const loading = ref(false)
const keyword = ref('')
const filterModule = ref('')
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

// ---- 从后端加载视频列表（服务端分页）----
async function fetchData() {
  loading.value = true
  try {
    const res = await getVideoPage({
      page: page.value,
      size: pageSize.value,
      moduleName: filterModule.value || undefined,
      keyword: keyword.value.trim() || undefined
    })
    list.value = res.records || []
    total.value = res.total || 0
  } catch (err) {
    ElMessage.error('加载视频列表失败')
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

// ---- 模块辅助函数 ----
function moduleTagType(m) {
  return {
    '政治理论': 'danger',
    '言语理解': 'warning',
    '数量关系': 'primary',
    '判断推理': 'success',
    '资料分析': 'info'
  }[m] || ''
}

// 拼接完整可访问 URL
function fullUrl(path) {
  if (!path) return ''
  if (path.startsWith('http')) return path
  return import.meta.env.VITE_API_BASE_URL + path
}

// ---- 新增/编辑弹窗 ----
const dialogVisible = ref(false)
const submitting = ref(false)
const formRef = ref(null)
const editingVideo = ref(null)
const uploading = ref(false)
const uploadProgress = ref(0)
const form = reactive({
  moduleName: '',
  title: '',
  description: '',
  videoUrl: '',
  sortOrder: 0
})

const rules = {
  moduleName: [{ required: true, message: '请选择模块', trigger: 'change' }],
  title: [{ required: true, message: '请输入视频标题', trigger: 'blur' }],
  videoUrl: [{ required: true, message: '请上传视频或填写视频地址', trigger: 'blur' }]
}

function openAddDialog() {
  editingVideo.value = null
  Object.assign(form, { moduleName: '', title: '', description: '', videoUrl: '', sortOrder: 0 })
  dialogVisible.value = true
}

function openEditDialog(row) {
  editingVideo.value = row
  Object.assign(form, {
    moduleName: row.moduleName,
    title: row.title,
    description: row.description,
    videoUrl: row.videoUrl,
    sortOrder: row.sortOrder
  })
  dialogVisible.value = true
}

// ---- 上传视频文件 ----
async function handleUpload(option) {
  uploading.value = true
  uploadProgress.value = 0
  try {
    const url = await uploadVideo(option.file, (p) => {
      uploadProgress.value = p
    })
    form.videoUrl = url
    ElMessage.success('视频上传成功')
  } catch (err) {
    ElMessage.error(err.message || '视频上传失败')
  } finally {
    uploading.value = false
  }
}

// 提交（新增 or 编辑）
async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    if (editingVideo.value) {
      await updateVideo(editingVideo.value.id, { ...form })
      ElMessage.success('编辑成功')
    } else {
      await createVideo({ ...form })
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
    await ElMessageBox.confirm(`确定删除视频「${row.title}」吗？`, '提示', { type: 'warning' })
    await deleteVideo(row.id)
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

.upload-tip {
  margin-top: 8px;
  font-size: 13px;
}
</style>
