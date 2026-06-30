import { router } from '@kit.ArkUI'
import { SkillTreeApi, SkillTreeItem } from '../http/SkillTreeApi'

const CATEGORY_LABELS: Record<string, string> = {
  'FRONTEND': '前端',
  'BACKEND': '后端',
  'DATABASE': '数据库',
  'TOOL': '工具'
}

const CATEGORY_COLORS: Record<string, string> = {
  'FRONTEND': '#67C23A',
  'BACKEND': '#E6A23C',
  'DATABASE': '#F56C6C',
  'TOOL': '#909399'
}

@Entry
@Component
struct SkillTreePage {
  @State skills: SkillTreeItem[] = []
  @State loading: boolean = true
  @State errorMsg: string = ''
  @State selectedCategory: string = 'ALL'

  async aboutToAppear() {
    await this.fetchSkills()
  }

  async fetchSkills() {
    this.loading = true
    this.errorMsg = ''
    try {
      const context = getContext(this)
      if (this.selectedCategory === 'ALL') {
        this.skills = await SkillTreeApi.getSkillList(context)
      } else {
        this.skills = await SkillTreeApi.getSkillByCategory(context, this.selectedCategory)
      }
    } catch (err) {
      this.errorMsg = (err as Error).message || '加载失败'
    } finally {
      this.loading = false
    }
  }

  private goBack() {
    router.back()
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
        Text('技能树')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#fff')

      // 分类筛选
      Scroll() {
        Row() {
          this.CategoryTab('ALL', '全部')
          this.CategoryTab('FRONTEND', '前端')
          this.CategoryTab('BACKEND', '后端')
          this.CategoryTab('DATABASE', '数据库')
          this.CategoryTab('TOOL', '工具')
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .backgroundColor('#fff')

      // 内容区域
      if (this.loading) {
        Column() {
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMsg) {
        Column() {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#F56C6C')
          Button('重试')
            .type(ButtonType.Capsule)
            .fontSize(14)
            .backgroundColor('#409EFF')
            .margin({ top: 12 })
            .onClick(() => this.fetchSkills())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.skills.length === 0) {
        Column() {
          Text('暂无技能数据')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.skills, (skill: SkillTreeItem) => {
            ListItem() {
              this.SkillCard(skill)
            }
          })
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#F5F7FA')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  CategoryTab(category: string, label: string) {
    Text(label)
      .fontSize(13)
      .fontColor(this.selectedCategory === category ? '#FFF' : '#666')
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .backgroundColor(this.selectedCategory === category ? '#409EFF' : '#F0F0F0')
      .borderRadius(14)
      .margin({ right: 8 })
      .onClick(() => {
        this.selectedCategory = category
        this.fetchSkills()
      })
  }

  @Builder
  SkillCard(skill: SkillTreeItem) {
    Column() {
      Row() {
        // 分类标签
        Text(CATEGORY_LABELS[skill.category] || skill.category)
          .fontSize(11)
          .fontColor('#FFF')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(CATEGORY_COLORS[skill.category] || '#909399')
          .borderRadius(4)

        Blank()

        // 难度星星
        Row() {
          ForEach([1, 2, 3, 4, 5], (star: number) => {
            Text(star <= skill.level ? '★' : '☆')
              .fontSize(14)
              .fontColor(star <= skill.level ? '#E6A23C' : '#DDD')
              .margin({ right: 2 })
          })
        }
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 技能名称
      Text(skill.name)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ bottom: 6 })

      // 描述
      Text(skill.description || '暂无描述')
        .fontSize(13)
        .fontColor('#888')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFF')
    .borderRadius(10)
    .margin({ bottom: 10 })
  }
}
