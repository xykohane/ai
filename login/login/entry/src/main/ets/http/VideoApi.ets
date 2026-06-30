import { http } from '@kit.NetworkKit'
import { router } from '@kit.ArkUI'
import { TokenUtil } from '../common/TokenUtil'

const BASE_URL = 'http://172.22.176.1:8080'

export interface VideoItem {
  id: number
  moduleName: string
  title: string
  description: string
  videoUrl: string
  duration: number
  sortOrder: number
  createTime?: string
}

interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

export class VideoApi {
  /**
   * 按模块名查询视频列表
   * 拼接出完整可播放的视频 URL
   */
  static async getVideosByModule(context: Context, moduleName: string): Promise<VideoItem[]> {
    const httpRequest = http.createHttp()
    const token = await TokenUtil.getToken(context)
    if (!token) {
      throw new Error('未登录，请先登录')
    }

    try {
      const response = await httpRequest.request(
        `${BASE_URL}/api/learning-video/module/${encodeURIComponent(moduleName)}`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          }
        }
      )

      if (response.responseCode === 401) {
        await TokenUtil.removeToken(context)
        router.replaceUrl({ url: 'pages/Login' })
        throw new Error('登录已过期，请重新登录')
      } else if (response.responseCode === 200) {
        const result: ApiResponse<VideoItem[]> = JSON.parse(response.result as string) as ApiResponse<VideoItem[]>
        if (result.code === 200) {
          // 拼接完整视频 URL，供 Video 组件播放
          const list = result.data || []
          list.forEach((item: VideoItem) => {
            if (item.videoUrl && !item.videoUrl.startsWith('http')) {
              item.videoUrl = BASE_URL + item.videoUrl
            }
          })
          return list
        } else {
          throw new Error(result.message || '获取视频列表失败')
        }
      } else {
        throw new Error(`请求失败(${response.responseCode})`)
      }
    } finally {
      httpRequest.destroy()
    }
  }

  /**
   * 查询全部视频
   */
  static async getAllVideos(context: Context): Promise<VideoItem[]> {
    const httpRequest = http.createHttp()
    const token = await TokenUtil.getToken(context)
    if (!token) {
      throw new Error('未登录，请先登录')
    }

    try {
      const response = await httpRequest.request(
        `${BASE_URL}/api/learning-video/list`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          }
        }
      )

      if (response.responseCode === 401) {
        await TokenUtil.removeToken(context)
        router.replaceUrl({ url: 'pages/Login' })
        throw new Error('登录已过期，请重新登录')
      } else if (response.responseCode === 200) {
        const result: ApiResponse<VideoItem[]> = JSON.parse(response.result as string) as ApiResponse<VideoItem[]>
        if (result.code === 200) {
          const list = result.data || []
          list.forEach((item: VideoItem) => {
            if (item.videoUrl && !item.videoUrl.startsWith('http')) {
              item.videoUrl = BASE_URL + item.videoUrl
            }
          })
          return list
        } else {
          throw new Error(result.message || '获取视频列表失败')
        }
      } else {
        throw new Error(`请求失败(${response.responseCode})`)
      }
    } finally {
      httpRequest.destroy()
    }
  }
}
