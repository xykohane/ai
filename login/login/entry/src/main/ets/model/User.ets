// 统一响应结果
export interface ResultResponse<T> {
  code: number
  message: string
  data: T
}

// 登录请求参数
export interface LoginRequest {
  username: string
  password: string
}

// 注册请求参数
export interface RegisterRequest {
  username: string
  password: string
  email: string
}

// 用户信息（对应后端 UserVO）
export interface UserVO {
  id: number
  username: string
  nickname: string
  email: string
}

// 登录响应数据（对应后端 LoginVO）
export interface LoginVO {
  token: string
  user: UserVO
}

// 登录响应（Result<LoginVO>）
export interface LoginResponse extends ResultResponse<LoginVO> {
}

// 注册响应（Result<Void>）
export interface RegisterResponse extends ResultResponse<null> {
}

// 用户信息
export interface UserInfo {
  userId: string
  username: string
}
