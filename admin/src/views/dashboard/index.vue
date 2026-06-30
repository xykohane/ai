<!-- src/views/dashboard/index.vue -->
<!-- 仪表盘：统计卡片 + 饼图 + 柱状图 + 折线图 + 最近活动 -->
<template>
  <div class="dashboard">
    <!-- 第一行：统计卡片 -->
    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>用户总数</template>
          <div class="stat-value">{{ data?.totalUsers ?? '-' }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>技能数量</template>
          <div class="stat-value">{{ data?.totalSkills ?? '-' }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>学习记录</template>
          <div class="stat-value">{{ data?.totalRecords ?? '-' }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>AI调用次数</template>
          <div class="stat-value">{{ data?.aiCalls ?? '-' }}</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 第二行：饼图 + 柱状图 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>技能分布</template>
          <div ref="pieChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header>近7天 AI 调用次数</template>
          <div ref="barChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 第三行：折线图（用户增长趋势） -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="24">
        <el-card shadow="hover">
          <template #header>近30天用户增长趋势</template>
          <div ref="lineChartRef" class="chart-container-tall"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 第四行：最近活动 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="24">
        <el-card shadow="hover">
          <template #header>最近活动</template>
          <el-table :data="data?.recentActivities ?? []" stripe>
            <el-table-column prop="content" label="内容" />
            <el-table-column prop="time" label="时间" width="180" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getDashboardData } from '../../api/dashboard'

// ---- 响应式数据 ----
const data = ref(null)

// ---- DOM 引用 ----
const pieChartRef = ref(null)
const barChartRef = ref(null)
const lineChartRef = ref(null)

// ---- ECharts 实例 ----
let pieChart = null
let barChart = null
let lineChart = null

// ---- 获取数据 ----
async function fetchData() {
  const res = await getDashboardData()
  data.value = res
  // 等待 DOM 更新后再渲染图表
  await nextTick()
  renderPieChart()
  renderBarChart()
  renderLineChart()
}

// ---- 渲染饼图：技能分布 ----
function renderPieChart() {
  if (!pieChartRef.value || !data.value?.skillDistribution?.length) return
  pieChart = echarts.init(pieChartRef.value)
  pieChart.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: 0 },
    series: [
      {
        type: 'pie',
        radius: '60%',
        data: data.value.skillDistribution,
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  })
}

// ---- 渲染柱状图：近7天 AI 调用次数（真实数据） ----
function renderBarChart() {
  if (!barChartRef.value) return
  barChart = echarts.init(barChartRef.value)
  const days = Array.from({ length: 7 }, (_, i) => {
    const d = new Date()
    d.setDate(d.getDate() - (6 - i))
    return `${d.getMonth() + 1}/${d.getDate()}`
  })
  const calls = data.value?.aiCallsLast7Days ?? [0, 0, 0, 0, 0, 0, 0]
  barChart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: days },
    yAxis: { type: 'value' },
    series: [
      {
        type: 'bar',
        data: calls,
        itemStyle: { color: '#409EFF', borderRadius: [4, 4, 0, 0] }
      }
    ]
  })
}

// ---- 渲染折线图：近30天用户增长趋势（真实数据） ----
function renderLineChart() {
  if (!lineChartRef.value) return
  lineChart = echarts.init(lineChartRef.value)
  const days = Array.from({ length: 30 }, (_, i) => {
    const d = new Date()
    d.setDate(d.getDate() - (29 - i))
    return `${d.getMonth() + 1}/${d.getDate()}`
  })
  const users = data.value?.userGrowthLast30Days ?? Array.from({ length: 30 }, () => 0)
  lineChart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: days, boundaryGap: false },
    yAxis: { type: 'value' },
    series: [
      {
        type: 'line',
        data: users,
        smooth: true,
        itemStyle: { color: '#67C23A' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(103, 194, 58, 0.3)' },
            { offset: 1, color: 'rgba(103, 194, 58, 0.02)' }
          ])
        }
      }
    ]
  })
}

// ---- 窗口大小变化时重绘所有图表 ----
function handleResize() {
  pieChart?.resize()
  barChart?.resize()
  lineChart?.resize()
}

onMounted(() => {
  fetchData()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  // 销毁图表实例，释放 Canvas 和内存
  pieChart?.dispose()
  barChart?.dispose()
  lineChart?.dispose()
  // 移除事件监听，防止内存泄漏
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.dashboard {
  padding: 0;
}

.stat-cards {
  margin-bottom: 20px;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #409eff;
  text-align: center;
  padding: 10px 0;
}

.chart-row {
  margin-bottom: 20px;
}

.chart-container {
  height: 300px;
}

.chart-container-tall {
  height: 320px;
}
</style>
