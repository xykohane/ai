import { router } from '@kit.ArkUI'
import { TokenUtil } from '../common/TokenUtil'

@Entry
@Component
struct Home {
  @State username: string = ''
  @State isLoggedIn: boolean = false

  async aboutToAppear() {
    const context = getContext(this)
    const token = await TokenUtil.getToken(context)

    if (token) {
      this.isLoggedIn = true
      const name = await TokenUtil.getUsername(context)
      this.username = name || ''
    }
  }

  build() {
    Column() {
      // 顶部欢迎区域
      Column() {
        Text('AI伴学与职业成长平台')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#409EFF')
          .margin({ bottom: 8 })

        if (this.isLoggedIn && this.username) {
          Text(`欢迎回来，${this.username}`)
            .fontSize(16)
            .fontColor('#666')
        }
      }
      .margin({ top: 40, bottom: 40 })

      // 功能区域
      Column() {
        // 功能卡片
        Row() {
          this.CardBuilder('在线学习', $r('app.media.startIcon'), () => {
            router.pushUrl({ url: 'pages/SkillTreePage' })
          })
          this.CardBuilder('职业规划', $r('app.media.startIcon'))
        }
        .margin({ bottom: 16 })

        Row() {
          this.CardBuilder('技能评估', $r('app.media.startIcon'), () => {
            router.pushUrl({ url: 'pages/SkillTreePage' })
          })
          this.CardBuilder('就业指导', $r('app.media.startIcon'))
        }
      }
      .padding({ left: 32, right: 32 })

      // AI 对话入口
      if (this.isLoggedIn) {
        Button('AI伴学助手')
          .type(ButtonType.Capsule)
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#67C23A')
          .margin({ top: 40 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/AiTutorPage' })
          })

        Button('AI面试官')
          .type(ButtonType.Capsule)
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#E6A23C')
          .margin({ top: 16 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/InterviewerPage' })
          })

        Button('个人中心')
          .type(ButtonType.Capsule)
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#409EFF')
          .margin({ top: 16 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/PersonalCenter' })
          })

        Button('退出登录')
          .type(ButtonType.Capsule)
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#F56C6C')
          .margin({ top: 16 })
          .onClick(async () => {
            const context = getContext(this)
            await TokenUtil.removeToken(context)
            this.isLoggedIn = false
            this.username = ''
            router.replaceUrl({ url: 'pages/Login' })
          })
      } else {
        Button('登录 / 注册')
          .type(ButtonType.Capsule)
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#409EFF')
          .margin({ top: 40 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/Login' })
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  CardBuilder(title: string, icon: Resource, onClick?: () => void) {
    Column() {
      Image(icon)
        .width(48)
        .height(48)
        .objectFit(ImageFit.Contain)
      Text(title)
        .fontSize(14)
        .fontColor('#333')
        .margin({ top: 8 })
    }
    .width('45%')
    .height(120)
    .backgroundColor('#FFF')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .margin(8)
    .onClick(() => {
      if (onClick) {
        onClick()
      }
    })
  }
}
