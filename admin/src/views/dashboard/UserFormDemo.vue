<!-- src/views/dashboard/UserFormDemo.vue -->
<!-- 课后练习1.2：用户信息表单（reactive）—— el-form + 参数校验 -->
<!-- 字段：昵称、手机号、邮箱、性别、系统角色（手机号、邮箱做格式校验） -->
<template>
  <el-card class="form-card" shadow="hover">
    <template #header>
      <div class="card-header">
        <span>练习1.2：用户信息表单（reactive）</span>
        <el-tag type="warning" size="small">reactive</el-tag>
      </div>
    </template>

    <el-form ref="formRef" :model="form" :rules="rules" label-width="90px" style="max-width: 560px">
      <el-form-item label="昵称" prop="nickname">
        <el-input v-model="form.nickname" placeholder="请输入昵称" />
      </el-form-item>

      <el-form-item label="手机号" prop="phone">
        <el-input v-model="form.phone" placeholder="请输入手机号" maxlength="11" />
      </el-form-item>

      <el-form-item label="邮箱" prop="email">
        <el-input v-model="form.email" placeholder="请输入邮箱" />
      </el-form-item>

      <el-form-item label="性别" prop="gender">
        <el-radio-group v-model="form.gender">
          <el-radio value="male">男</el-radio>
          <el-radio value="female">女</el-radio>
        </el-radio-group>
      </el-form-item>

      <el-form-item label="系统角色" prop="role">
        <el-select v-model="form.role" placeholder="请选择系统角色" style="width: 100%">
          <el-option label="管理员" value="admin" />
          <el-option label="普通用户" value="user" />
          <el-option label="访客" value="guest" />
        </el-select>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="handleSubmit">提交</el-button>
        <el-button @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 提交结果展示 -->
    <el-divider content-position="left">提交结果</el-divider>
    <pre v-if="submitted" class="result">{{ submitted }}</pre>
    <el-empty v-else description="暂无提交数据" :image-size="60" />
  </el-card>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

// ref 获取表单引用
const formRef = ref(null)
const submitted = ref(null)

// reactive 包装表单对象
const form = reactive({
  nickname: '',
  phone: '',
  email: '',
  gender: 'male',
  role: ''
})

// 自定义校验：手机号格式（11位数字，1开头）
const validatePhone = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入手机号'))
  } else if (!/^1[3-9]\d{9}$/.test(value)) {
    callback(new Error('手机号格式不正确（需为11位、1开头）'))
  } else {
    callback()
  }
}

// 自定义校验：邮箱格式
const validateEmail = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入邮箱'))
  } else if (!/^[\w.-]+@[\w-]+(\.[\w-]+)+$/.test(value)) {
    callback(new Error('邮箱格式不正确'))
  } else {
    callback()
  }
}

// 表单验证规则
const rules = {
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 2, max: 16, message: '昵称长度为 2-16 个字符', trigger: 'blur' }
  ],
  phone: [{ required: true, validator: validatePhone, trigger: 'blur' }],
  email: [{ required: true, validator: validateEmail, trigger: 'blur' }],
  gender: [{ required: true, message: '请选择性别', trigger: 'change' }],
  role: [{ required: true, message: '请选择系统角色', trigger: 'change' }]
}

// 提交
async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) {
    ElMessage.error('表单校验未通过，请检查输入')
    return
  }
  // 展示提交结果（reactive 对象展开）
  submitted.value = JSON.stringify({ ...form }, null, 2)
  ElMessage.success('提交成功')
}

// 重置
function handleReset() {
  formRef.value.resetFields()
  submitted.value = null
}
</script>

<style scoped>
.form-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.result {
  background: #f5f7fa;
  padding: 16px;
  border-radius: 6px;
  font-size: 13px;
  color: #303133;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-all;
}
</style>
