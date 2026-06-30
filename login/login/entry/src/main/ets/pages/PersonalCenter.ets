import { router } from '@kit.ArkUI'
import { TokenUtil } from '../common/TokenUtil'

@Entry
@Component
struct PersonalCenter {
  @State username: string = ''
  @State userId: string = ''
  @State isLoggedIn: boolean = false

  async aboutToAppear() {
    const context = getContext(this)
    const token = await TokenUtil.getToken(context)

    if (token) {
      this.isLoggedIn = true
      const name = await TokenUtil.getUsername(context)
      const id = await TokenUtil.getUserId(context)
      this.username = name || ''
      this.userId = id || ''
    } else {
      router.replaceUrl({ url: 'pages/Login' })
    }
  }

  build() {
    Column() {
      // 顶部背景
      Column() {
        // 返回按钮
        Row() {
          Text('<')
            .fontSize(24)
            .fontColor('#FFF')
            .onClick(() => {
              router.back()
            })
          Text('个人中心')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFF')
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 20 })

        // 用户头像区域
        Column() {
          Column() {
            Text(this.username ? this.username.charAt(0).toUpperCase() : 'U')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#409EFF')
          }
          .width(80)
          .height(80)
          .backgroundColor('#FFF')
          .borderRadius(40)
          .justifyContent(FlexAlign.Center)

          Text(this.username)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFF')
            .margin({ top: 12 })

          Text(`ID: ${this.userId}`)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.8)')
            .margin({ top: 4 })
        }
        .margin({ top: 20 })
      }
      .width('100%')
      .height(220)
      .backgroundColor('#409EFF')
      .padding({ left: 24, right: 24, top: 16 })

      // 功能列表
      Column() {
        this.MenuItem('学习记录')
        this.MenuItem('我的收藏')
        this.MenuItem('设置')
        this.MenuItem('关于我们')
      }
      .width('100%')
      .backgroundColor('#FFF')
      .margin({ top: 16 })

      // 退出登录按钮
      Button('退出登录')
        .type(ButtonType.Capsule)
        .width('80%')
        .height(48)
        .fontSize(16)
        .backgroundColor('#F56C6C')
        .margin({ top: 40 })
        .onClick(async () => {
          const context = getContext(this)
          await TokenUtil.removeToken(context)
          router.replaceUrl({ url: 'pages/Login' })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  MenuItem(title: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor('#333')
      Text('>')
        .fontSize(16)
        .fontColor('#999')
    }
    .width('100%')
    .height(56)
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.SpaceBetween)
    .border({
      width: { bottom: 1 },
      color: '#F0F0F0'
    })
  }
}
