<!-- src/views/dashboard/CounterDemo.vue -->
<!-- 课后练习1.1：计数器（ref）—— 点击页面的数字可以自增 -->
<template>
  <el-card class="counter-card" shadow="hover">
    <template #header>
      <div class="card-header">
        <span>练习1.1：计数器（ref）</span>
        <el-tag type="success" size="small">ref</el-tag>
      </div>
    </template>

    <div class="counter-body">
      <p class="desc">点击数字或按钮可以自增（ref 包装基本类型）</p>
      <div class="counter-number" @click="increment">{{ count }}</div>
      <div class="counter-actions">
        <el-button type="primary" @click="increment">+1 自增</el-button>
        <el-button @click="decrement">-1 自减</el-button>
        <el-button type="danger" plain @click="reset">重置</el-button>
      </div>
      <p class="tip">当前数值的 2 倍是：{{ double }}（computed 计算属性）</p>
    </div>
  </el-card>
</template>

<script setup>
import { ref, computed } from 'vue'

// ref 包装基本类型（number）
const count = ref(0)

// computed 计算属性
const double = computed(() => count.value * 2)

// 自增方法：JS 中访问 ref 需要 .value
function increment() {
  count.value++
}

// 自减方法
function decrement() {
  count.value--
}

// 重置
function reset() {
  count.value = 0
}
</script>

<style scoped>
.counter-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.counter-body {
  text-align: center;
  padding: 20px 0;
}

.desc {
  color: #909399;
  font-size: 14px;
  margin-bottom: 16px;
}

.counter-number {
  font-size: 64px;
  font-weight: bold;
  color: #409eff;
  cursor: pointer;
  user-select: none;
  margin-bottom: 20px;
  transition: transform 0.15s;
}

.counter-number:hover {
  transform: scale(1.1);
}

.counter-number:active {
  transform: scale(0.95);
}

.counter-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-bottom: 16px;
}

.tip {
  color: #909399;
  font-size: 13px;
}
</style>
