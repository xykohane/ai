import { preferences } from '@kit.ArkData'

// Preferences 实例名称
const PREFS_NAME = 'auth_prefs'

// Token 键名
const TOKEN_KEY = 'auth_token'
const USER_ID_KEY = 'user_id'
const USERNAME_KEY = 'username'

// 获取 Preferences 实例
async function getPrefs(context: Context): Promise<preferences.Preferences> {
  return await preferences.getPreferences(context, PREFS_NAME)
}

export class TokenUtil {
  // 保存 Token
  static async saveToken(context: Context, token: string): Promise<void> {
    const pref = await getPrefs(context)
    await pref.put(TOKEN_KEY, token)
    await pref.flush()
  }

  // 获取 Token
  static async getToken(context: Context): Promise<string | null> {
    const pref = await getPrefs(context)
    const value = await pref.get(TOKEN_KEY, '')
    if (value === '') {
      return null
    }
    return value.toString()
  }

  // 删除 Token
  static async removeToken(context: Context): Promise<void> {
    const pref = await getPrefs(context)
    await pref.delete(TOKEN_KEY)
    await pref.flush()
  }

  // 保存用户信息
  static async saveUserInfo(context: Context, userId: string, username: string): Promise<void> {
    const pref = await getPrefs(context)
    await pref.put(USER_ID_KEY, userId)
    await pref.put(USERNAME_KEY, username)
    await pref.flush()
  }

  // 获取用户名
  static async getUsername(context: Context): Promise<string | null> {
    const pref = await getPrefs(context)
    const value = await pref.get(USERNAME_KEY, '')
    if (value === '') {
      return null
    }
    return value.toString()
  }

  // 获取用户ID
  static async getUserId(context: Context): Promise<string | null> {
    const pref = await getPrefs(context)
    const value = await pref.get(USER_ID_KEY, '')
    if (value === '') {
      return null
    }
    return value.toString()
  }
}
