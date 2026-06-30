import { router } from '@kit.ArkUI'
import { InterviewerViewModel } from '../viewmodel/InterviewerViewModel'
import { ChatMessage } from '../model/ChatMessage'
import { DateUtil } from '../common/DateUtil'
import { Markdown } from '@luvi/lv-markdown-in'

@Entry
@Component
struct InterviewerPage {
  @State viewModel: InterviewerViewModel = new InterviewerViewModel()
  @State inputText: string = ''
  private scroller: Scroller = new Scroller()

  private goBack() {
    router.back()
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('<')
          .fontSize(20)
          .fontColor('#E6A23C')
          .margin({ right: 12 })
          .onClick(() => this.goBack())
        Text('AI面试官')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('清空')
          .fontSize(14)
          .fontColor('#E6A23C')
          .onClick(() => this.viewModel.clearMessages())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#fff')

      // 消息列表
      if (this.viewModel.messages.length === 0) {
        Column() {
          Text('💼')
            .fontSize(48)
          Text('你好！我是AI面试官，专注于Java基础面试。')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 12 })
          Text('我会每次只问一题，根据你的回答追问。')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 4 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ scroller: this.scroller }) {
          ForEach(this.viewModel.messages, (msg: ChatMessage, index: number) => {
            ListItem() {
              if (msg.role === 'user') {
                Row() {
                  Blank()
                  Column() {
                    Text(msg.content)
                      .fontSize(15)
                      .fontColor('#fff')
                      .padding(12)
                      .borderRadius(12)
                      .backgroundColor('#E6A23C')
                    Text(DateUtil.format(msg.timestamp))
                      .fontSize(10)
                      .fontColor('#ccc')
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')
                .padding({ left: 60, right: 12, top: 8, bottom: 8 })
              } else {
                Row() {
                  Column() {
                    Markdown({
                      text: msg.content,
                      mode: 'text'
                    })
                      .width('100%')
                      .padding(12)
                      .borderRadius(12)
                      .backgroundColor('#ECF5FF')
                    Text(DateUtil.format(msg.timestamp))
                      .fontSize(10)
                      .fontColor('#ccc')
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Blank()
                }
                .width('100%')
                .padding({ left: 12, right: 60, top: 8, bottom: 8 })
              }
            }
          })
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#F5F7FA')
      }

      // 输入栏
      Row() {
        TextInput({ placeholder: '输入你的回答...', text: this.inputText })
          .onChange((value: string) => this.inputText = value)
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .padding({ left: 16, right: 16 })

        Button(this.viewModel.sending ? '...' : '发送')
          .type(ButtonType.Capsule)
          .height(40)
          .fontSize(14)
          .backgroundColor('#E6A23C')
          .margin({ left: 8 })
          .enabled(!this.viewModel.sending && this.inputText.trim().length > 0)
          .onClick(() => {
            const msg = this.inputText.trim()
            if (msg) {
              this.viewModel.sendMessage(msg)
              this.inputText = ''
              setTimeout(() => {
                this.scroller.scrollEdge(Edge.Bottom)
              }, 100)
            }
          })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#fff')
    }
    .width('100%')
    .height('100%')
  }
}
