import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { TokenUtil } from '../common/TokenUtil'
import { AuthApi } from '../http/AuthApi'
import { LoginRequest } from '../model/User'

// Preferences 实例名称
const PREFS_NAME = 'auth_prefs'

// 记住密码键名
const REMEMBER_USERNAME_KEY = 'remember_username'
const REMEMBER_PASSWORD_KEY = 'remember_password'

@Entry
@Component
struct LoginPage {
  @State username: string = ''
  @State password: string = ''
  @State loading: boolean = false
  @State errorMsg: string = ''
  @State rememberPassword: boolean = false

  private context: Context = getContext(this)

  // 页面即将显示时调用
  async aboutToAppear() {
    // 1. 检查是否已登录，有 Token 则直接跳转首页
    const token = await TokenUtil.getToken(this.context)
    if (token) {
      router.replaceUrl({ url: 'pages/Home' })
      return
    }

    // 2. 加载记住密码的用户名和密码
    await this.loadRememberInfo()
  }

  // 加载记住的密码信息
  async loadRememberInfo() {
    const pref = await preferences.getPreferences(this.context, PREFS_NAME)
    const savedUsername = await pref.get(REMEMBER_USERNAME_KEY, '') as string
    const savedPassword = await pref.get(REMEMBER_PASSWORD_KEY, '') as string
    const rememberFlag = await pref.get('remember_enabled', false) as boolean

    if (rememberFlag && savedUsername) {
      this.username = savedUsername
      this.password = savedPassword
      this.rememberPassword = true
    }
  }

  // 保存登录信息
  async saveRememberInfo() {
    const pref = await preferences.getPreferences(this.context, PREFS_NAME)

    if (this.rememberPassword) {
      await pref.put(REMEMBER_USERNAME_KEY, this.username)
      await pref.put(REMEMBER_PASSWORD_KEY, this.password)
      await pref.put('remember_enabled', true)
    } else {
      await pref.put(REMEMBER_USERNAME_KEY, '')
      await pref.put(REMEMBER_PASSWORD_KEY, '')
      await pref.put('remember_enabled', false)
    }
    await pref.flush()
  }

  // 处理登录
  async handleLogin() {
    // 1. 校验输入
    if (!this.username.trim() || !this.password.trim()) {
      this.errorMsg = '请输入用户名和密码'
      return
    }

    this.loading = true
    this.errorMsg = ''

    try {
      // 2. 调用登录 API
      const data: LoginRequest = { username: this.username, password: this.password }
      const res = await AuthApi.login(data)

      // 3. 保存 Token 和用户信息到本地
      // 后端返回结构: { code, message, data: { token, user: { id, username, nickname, email } } }
      const loginData = res.data
      await TokenUtil.saveToken(this.context, loginData.token)
      await TokenUtil.saveUserInfo(this.context, loginData.user.id.toString(), loginData.user.username)

      // 4. 保存登录信息
      await this.saveRememberInfo()

      // 5. 跳转到首页
      router.replaceUrl({ url: 'pages/Home' })
    } catch (err) {
      // 6. 登录失败，显示错误信息
      const error = err as Error
      this.errorMsg = error.message || '登录失败'
    } finally {
      this.loading = false
    }
  }

  build() {
    Column() {
      // 标题
      Text('AI伴学与职业成长平台')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#409EFF')
        .margin({ bottom: 8 })

      Text('智能学习，职业成长')
        .fontSize(14)
        .fontColor('#999')
        .margin({ bottom: 48 })

      // 用户名输入框
      TextInput({ placeholder: '请输入用户名', text: this.username })
        .onChange((value: string) => this.username = value)
        .height(48)
        .margin({ bottom: 16 })
        .borderRadius(8)

      // 密码输入框
      TextInput({ placeholder: '请输入密码', text: this.password })
        .onChange((value: string) => this.password = value)
        .type(InputType.Password)
        .height(48)
        .margin({ bottom: 16 })
        .borderRadius(8)

      // 记住密码
      Row() {
        Checkbox()
          .select(this.rememberPassword)
          .onChange((isChecked: boolean) => {
            this.rememberPassword = isChecked
          })
        Text('记住密码')
          .fontSize(14)
          .fontColor('#666')
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 错误提示
      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontSize(12)
          .fontColor('#F56C6C')
          .margin({ bottom: 8 })
      }

      // 登录按钮
      Button(this.loading ? '登录中...' : '登录')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(48)
        .fontSize(16)
        .backgroundColor('#409EFF')
        .enabled(!this.loading)
        .onClick(() => this.handleLogin())

      // 注册链接
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#999')
        Text('去注册')
          .fontSize(14)
          .fontColor('#409EFF')
          .margin({ left: 4 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/Register' })
          })
      }
      .margin({ top: 24 })
    }
    .padding(32)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
