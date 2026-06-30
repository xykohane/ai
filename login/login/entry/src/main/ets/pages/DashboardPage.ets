import { router } from '@kit.ArkUI'
import { DashboardApi, DashboardData, SkillDistribution, RecentActivity } from '../http/DashboardApi'

@Entry
@Component
struct DashboardPage {
  @State dashboardData: DashboardData | null = null
  @State loading: boolean = true
  @State errorMsg: string = ''

  async aboutToAppear() {
    await this.fetchData()
  }

  async fetchData() {
    this.loading = true
    this.errorMsg = ''
    try {
      const context = getContext(this)
      this.dashboardData = await DashboardApi.getDashboardData(context)
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
        Text('仪表盘')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
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
            .onClick(() => this.fetchData())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.dashboardData) {
        Scroll() {
          Column() {
            // 统计卡片
            Row() {
              this.StatCard('用户总数', this.dashboardData!.totalUsers.toString())
              this.StatCard('技能数量', this.dashboardData!.totalSkills.toString())
            }
            .width('100%')
            .margin({ bottom: 12 })

            Row() {
              this.StatCard('学习记录', this.dashboardData!.totalRecords.toString())
              this.StatCard('AI调用次数', this.dashboardData!.aiCalls.toString())
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 技能分布
            if (this.dashboardData!.skillDistribution.length > 0) {
              Column() {
                Text('技能分布')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')
                  .margin({ bottom: 12 })

                ForEach(this.dashboardData!.skillDistribution, (item: SkillDistribution) => {
                  Row() {
                    Text(item.name)
                      .fontSize(14)
                      .fontColor('#666')
                      .width('30%')

                    // 进度条
                    Row() {
                      Row()
                        .width(`${Math.min(100, (item.value / this.dashboardData!.totalSkills) * 100)}%`)
                        .height(8)
                        .backgroundColor('#409EFF')
                        .borderRadius(4)
                    }
                    .width('60%')
                    .height(8)
                    .backgroundColor('#F0F0F0')
                    .borderRadius(4)

                    Text(`${item.value}`)
                      .fontSize(14)
                      .fontColor('#333')
                      .width('10%')
                      .textAlign(TextAlign.End)
                  }
                  .width('100%')
                  .margin({ bottom: 8 })
                })
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FFF')
              .borderRadius(10)
              .margin({ bottom: 12 })
            }

            // 最近活动
            if (this.dashboardData!.recentActivities.length > 0) {
              Column() {
                Text('最近活动')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')
                  .margin({ bottom: 12 })

                ForEach(this.dashboardData!.recentActivities, (activity: RecentActivity) => {
                  Row() {
                    Text('•')
                      .fontSize(14)
                      .fontColor('#409EFF')
                      .margin({ right: 8 })

                    Text(activity.content)
                      .fontSize(13)
                      .fontColor('#666')
                      .layoutWeight(1)

                    Text(activity.time)
                      .fontSize(11)
                      .fontColor('#999')
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })
                  .border({
                    width: { bottom: 1 },
                    color: '#F0F0F0'
                  })
                })
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FFF')
              .borderRadius(10)
            }
          }
          .width('100%')
          .padding(12)
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#F5F7FA')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StatCard(title: string, value: string) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontColor('#999')
        .margin({ bottom: 8 })

      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#409EFF')
    }
    .width('48%')
    .height(80)
    .backgroundColor('#FFF')
    .borderRadius(10)
    .justifyContent(FlexAlign.Center)
    .margin({ right: 4 })
  }
}
