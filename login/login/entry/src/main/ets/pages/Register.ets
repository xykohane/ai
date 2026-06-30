import { router } from '@kit.ArkUI'
import { AuthApi } from '../http/AuthApi'

@Entry
@Component
struct Register {
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State email: string = ''
  @State loading: boolean = false
  @State errorMsg: string = ''
  @State successMsg: string = ''

  async handleRegister() {
    // 1. 校验输入
    if (!this.username.trim()) {
      this.errorMsg = '请输入用户名'
      return
    }
    if (!this.email.trim()) {
      this.errorMsg = '请输入邮箱'
      return
    }
    if (!this.password.trim()) {
      this.errorMsg = '请输入密码'
      return
    }
    if (this.password !== this.confirmPassword) {
      this.errorMsg = '两次输入的密码不一致'
      return
    }
    if (this.password.length < 6) {
      this.errorMsg = '密码长度不能少于6位'
      return
    }

    // 简单邮箱格式校验
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(this.email)) {
      this.errorMsg = '邮箱格式不正确'
      return
    }

    this.loading = true
    this.errorMsg = ''
    this.successMsg = ''

    try {
      // 2. 调用注册 API
      const success = await AuthApi.register({
        username: this.username,
        password: this.password,
        email: this.email
      })

      if (success) {
        this.successMsg = '注册成功，即将跳转到登录页'
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/Login' })
        }, 1500)
      } else {
        this.errorMsg = '注册失败，请稍后重试'
      }
    } catch (err) {
      const error = err as Error
      this.errorMsg = error.message || '注册失败'
    } finally {
      this.loading = false
    }
  }

  build() {
    Stack() {
      // 背景渐变
      Column() {
        Column() {
          // 返回按钮和标题
          Row() {
            Text('<')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#666')
              .onClick(() => {
                router.back()
              })
            Blank()
          }
          .width('100%')
          .margin({ top: 16 })

          // Logo 区域
          Column() {
            Text('AI伴学')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#409EFF')
            Text('与职业成长平台')
              .fontSize(14)
              .fontColor('#999')
              .margin({ top: 4 })
          }
          .margin({ top: 16, bottom: 32 })

          // 标题
          Text('创建新账号')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .margin({ bottom: 32 })

          // 表单区域
          Column() {
            // 用户名
            Column() {
              Text('用户名')
                .fontSize(14)
                .fontColor('#666')
                .margin({ bottom: 8 })
              TextInput({ placeholder: '请输入用户名', text: this.username })
                .onChange((value: string) => this.username = value)
                .height(48)
                .borderRadius(12)
                .backgroundColor('#F5F7FA')
                .placeholderColor('#C0C4CC')
            }
            .margin({ bottom: 20 })

            // 邮箱
            Column() {
              Text('邮箱')
                .fontSize(14)
                .fontColor('#666')
                .margin({ bottom: 8 })
              TextInput({ placeholder: '请输入邮箱', text: this.email })
                .onChange((value: string) => this.email = value)
                .type(InputType.Email)
                .height(48)
                .borderRadius(12)
                .backgroundColor('#F5F7FA')
                .placeholderColor('#C0C4CC')
            }
            .margin({ bottom: 20 })

            // 密码
            Column() {
              Text('密码')
                .fontSize(14)
                .fontColor('#666')
                .margin({ bottom: 8 })
              TextInput({ placeholder: '请输入密码', text: this.password })
                .onChange((value: string) => this.password = value)
                .type(InputType.Password)
                .height(48)
                .borderRadius(12)
                .backgroundColor('#F5F7FA')
                .placeholderColor('#C0C4CC')
            }
            .margin({ bottom: 20 })

            // 确认密码
            Column() {
              Text('确认密码')
                .fontSize(14)
                .fontColor('#666')
                .margin({ bottom: 8 })
              TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
                .onChange((value: string) => this.confirmPassword = value)
                .type(InputType.Password)
                .height(48)
                .borderRadius(12)
                .backgroundColor('#F5F7FA')
                .placeholderColor('#C0C4CC')
            }
            .margin({ bottom: 24 })

            // 错误提示
            if (this.errorMsg) {
              Row() {
                Text(this.errorMsg)
                  .fontSize(12)
                  .fontColor('#F56C6C')
              }
              .margin({ bottom: 16 })
            }

            // 成功提示
            if (this.successMsg) {
              Row() {
                Text(this.successMsg)
                  .fontSize(12)
                  .fontColor('#67C23A')
              }
              .margin({ bottom: 16 })
            }

            // 注册按钮
            Button(this.loading ? '注册中...' : '注册')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#409EFF')
              .enabled(!this.loading)
              .onClick(() => this.handleRegister())
          }
          .padding({ left: 24, right: 24, top: 32, bottom: 32 })
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .shadow({
            radius: 20,
            color: 'rgba(0, 0, 0, 0.08)',
            offsetX: 0,
            offsetY: 4
          })

          // 登录链接
          Row() {
            Text('已有账号？')
              .fontSize(14)
              .fontColor('#999')
            Text('去登录')
              .fontSize(14)
              .fontColor('#409EFF')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 4 })
              .onClick(() => {
                router.replaceUrl({ url: 'pages/Login' })
              })
          }
          .margin({ top: 32 })
        }
        .padding(24)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F2F4F7')
    }
    .width('100%')
    .height('100%')
  }
}
