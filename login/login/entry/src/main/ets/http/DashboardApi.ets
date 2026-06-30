import { http } from '@kit.NetworkKit'
import { TokenUtil } from '../common/TokenUtil'

const BASE_URL = 'http://172.22.176.1:8080'

export interface SkillDistribution {
  name: string
  value: number
}

export interface RecentActivity {
  content: string
  time: string
}

export interface DashboardData {
  totalUsers: number
  totalSkills: number
  totalRecords: number
  aiCalls: number
  skillDistribution: SkillDistribution[]
  recentActivities: RecentActivity[]
  aiCallsLast7Days: number[]
  userGrowthLast30Days: number[]
}

interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

export class DashboardApi {
  static async getDashboardData(context: Context): Promise<DashboardData> {
    const httpRequest = http.createHttp()
    const token = await TokenUtil.getToken(context)

    try {
      const response = await httpRequest.request(
        `${BASE_URL}/api/dashboard`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          }
        }
      )

      if (response.responseCode === 200) {
        const result: ApiResponse<DashboardData> = JSON.parse(response.result as string) as ApiResponse<DashboardData>
        if (result.code === 200) {
          return result.data
        } else {
          throw new Error(result.message || '获取仪表盘数据失败')
        }
      } else {
        throw new Error('网络请求失败')
      }
    } finally {
      httpRequest.destroy()
    }
  }
}
