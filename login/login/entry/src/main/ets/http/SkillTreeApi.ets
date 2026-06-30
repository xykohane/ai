import { http } from '@kit.NetworkKit'
import { router } from '@kit.ArkUI'
import { TokenUtil } from '../common/TokenUtil'

const BASE_URL = 'http://172.22.176.1:8080'

export interface SkillTreeItem {
  id: number
  name: string
  category: string
  difficulty: number
  description: string
  createTime?: string
}

interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

export class SkillTreeApi {
  static async getSkillList(context: Context): Promise<SkillTreeItem[]> {
    const httpRequest = http.createHttp()
    const token = await TokenUtil.getToken(context)
    if (!token) {
      throw new Error('未登录，请先登录')
    }

    try {
      const response = await httpRequest.request(
        `${BASE_URL}/api/skill-tree/list`,
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
        const result: ApiResponse<SkillTreeItem[]> = JSON.parse(response.result as string) as ApiResponse<SkillTreeItem[]>
        if (result.code === 200) {
          return result.data
        } else {
          throw new Error(result.message || '获取技能列表失败')
        }
      } else {
        throw new Error(`请求失败(${response.responseCode})`)
      }
    } finally {
      httpRequest.destroy()
    }
  }

  static async getSkillByCategory(context: Context, category: string): Promise<SkillTreeItem[]> {
    const httpRequest = http.createHttp()
    const token = await TokenUtil.getToken(context)
    if (!token) {
      throw new Error('未登录，请先登录')
    }

    try {
      const response = await httpRequest.request(
        `${BASE_URL}/api/skill-tree/category/${category}`,
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
        const result: ApiResponse<SkillTreeItem[]> = JSON.parse(response.result as string) as ApiResponse<SkillTreeItem[]>
        if (result.code === 200) {
          return result.data
        } else {
          throw new Error(result.message || '获取技能列表失败')
        }
      } else {
        throw new Error(`请求失败(${response.responseCode})`)
      }
    } finally {
      httpRequest.destroy()
    }
  }
}
