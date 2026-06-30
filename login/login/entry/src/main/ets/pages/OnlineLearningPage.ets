import { router } from '@kit.ArkUI'

interface LearningModule {
  name: string
  desc: string
  color: string
  icon: string
}

@Entry
@Component
struct OnlineLearningPage {
  private modules: LearningModule[] = [
    { name: '政治理论', desc: '马克思主义基本原理、中国特色社会主义理论体系等', color: '#F56C6C', icon: '📐' },
    { name: '言语理解', desc: '逻辑填空、片段阅读、语句表达等', color: '#E6A23C', icon: '📖' },
    { name: '数量关系', desc: '数字推理、数学运算等', color: '#409EFF', icon: '🔢' },
    { name: '判断推理', desc: '图形推理、定义判断、类比推理、逻辑判断等', color: '#67C23A', icon: '🧩' },
    { name: '资料分析', desc: '文字资料、表格资料、图形资料分析等', color: '#909399', icon: '📊' }
  ]

  private goBack() {
    router.back()
  }

  private enterModule(module: LearningModule) {
    router.pushUrl({
      url: 'pages/ModuleLearningPage',
      params: { moduleName: module.name }
    })
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('<')
          .fontSize(20)
          .fontColor('#409EFF')
          .margin({ right: 12 })
          .onClick(() => this.goBack())
        Text('在线学习')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#fff')

      // 提示语
      Text('请选择学习模块')
        .fontSize(14)
        .fontColor('#999')
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 8 })

      // 模块列表
      List() {
        ForEach(this.modules, (module: LearningModule) => {
          ListItem() {
            this.ModuleCard(module)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F7FA')
      .padding({ left: 12, right: 12, top: 4, bottom: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  ModuleCard(module: LearningModule) {
    Row() {
      // 模块图标
      Column() {
        Text(module.icon)
          .fontSize(32)
      }
      .width(56)
      .height(56)
      .borderRadius(12)
      .backgroundColor(module.color)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 模块信息
      Column() {
        Text(module.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .margin({ bottom: 6 })

        Text(module.desc)
          .fontSize(12)
          .fontColor('#888')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 箭头
      Text('>')
        .fontSize(18)
        .fontColor('#CCC')
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFF')
    .borderRadius(10)
    .margin({ bottom: 10 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.enterModule(module))
  }
}
