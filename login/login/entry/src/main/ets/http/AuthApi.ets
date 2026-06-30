import { http } from '@kit.NetworkKit'
import { LoginRequest, LoginResponse, RegisterRequest, RegisterResponse } from '../model/User'

// API 基础地址
const BASE_URL = 'http://172.22.176.1:8080'

// 登录
export async function login(data: LoginRequest): Promise<LoginResponse> {
  const httpRequest = http.createHttp()

  try {
    const response = await httpRequest.request(
      `${BASE_URL}/api/auth/login`,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: data
      }
    )

    if (response.responseCode === 200) {
      const result = JSON.parse(response.result as string) as LoginResponse
      if (result.code === 200) {
        return result
      } else {
        throw new Error(result.message || '登录失败')
      }
    } else {
      throw new Error('网络请求失败')
    }
  } finally {
    httpRequest.destroy()
  }
}

// 注册
export async function register(data: RegisterRequest): Promise<boolean> {
  const httpRequest = http.createHttp()

  try {
    const response = await httpRequest.request(
      `${BASE_URL}/api/auth/register`,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: data
      }
    )

    if (response.responseCode === 200) {
      const result = JSON.parse(response.result as string) as RegisterResponse
      if (result.code === 200) {
        return true
      } else {
        throw new Error(result.message || '注册失败')
      }
    } else {
      throw new Error('网络请求失败')
    }
  } finally {
    httpRequest.destroy()
  }
}

// 封装 AuthApi 类
export class AuthApi {
  static async login(data: LoginRequest): Promise<LoginResponse> {
    return login(data)
  }

  static async register(data: RegisterRequest): Promise<boolean> {
    return register(data)
  }
}
