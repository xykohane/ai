// src/api/video.js
// 在线学习视频管理相关 API
import request from './request'

// 分页查询视频
export function getVideoPage(params) {
  return request.get('/api/learning-video/page', { params })
}

// 查询全部视频
export function getVideoList() {
  return request.get('/api/learning-video/list')
}

// 按模块查询视频
export function getVideoByModule(moduleName) {
  return request.get(`/api/learning-video/module/${moduleName}`)
}

// 获取视频详情
export function getVideoById(id) {
  return request.get(`/api/learning-video/${id}`)
}

// 新增视频
export function createVideo(data) {
  return request.post('/api/learning-video', data)
}

// 更新视频
export function updateVideo(id, data) {
  return request.put(`/api/learning-video/${id}`, data)
}

// 删除视频
export function deleteVideo(id) {
  return request.delete(`/api/learning-video/${id}`)
}

// 上传视频文件
export function uploadVideo(file, onProgress) {
  const formData = new FormData()
  formData.append('file', file)
  return request.post('/api/learning-video/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
    timeout: 600000,
    onUploadProgress: (e) => {
      if (onProgress && e.total) {
        onProgress(Math.round((e.loaded / e.total) * 100))
      }
    }
  })
}
