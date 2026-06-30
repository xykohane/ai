import { router } from '@kit.ArkUI'
import { VideoApi, VideoItem } from '../http/VideoApi'

@Entry
@Component
struct ModuleLearningPage {
  @State moduleName: string = ''
  @State videos: VideoItem[] = []
  @State currentVideo: VideoItem | null = null
  @State loading: boolean = true
  @State errorMsg: string = ''
  private controller: VideoController = new VideoController()

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string>
    this.moduleName = params?.moduleName || ''
    await this.fetchVideos()
  }

  async fetchVideos() {
    this.loading = true
    this.errorMsg = ''
    try {
      const context = getContext(this)
      this.videos = await VideoApi.getVideosByModule(context, this.moduleName)
      // 默认播放第一个视频
      if (this.videos.length > 0) {
        this.currentVideo = this.videos[0]
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

  private selectVideo(video: VideoItem) {
    this.currentVideo = video
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
        Text(this.moduleName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#fff')

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
            .onClick(() => this.fetchVideos())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 视频播放区域
            Stack({ alignContent: Alignment.Center }) {
              if (this.currentVideo && this.currentVideo.videoUrl) {
                Video({
                  src: this.currentVideo.videoUrl,
                  controller: this.controller
                })
                  .width('100%')
                  .height('100%')
                  .autoPlay(false)
                  .controls(true)
                  .objectFit(ImageFit.Contain)
              } else {
                Column() {
                  Text('▶')
                    .fontSize(40)
                    .fontColor('#FFF')
                    .margin({ bottom: 8 })
                  Text('暂无视频')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.8)')
                }
              }
            }
            .width('100%')
            .aspectRatio(16 / 9)
            .backgroundColor('#000')
            .borderRadius(12)
            .margin({ bottom: 12 })

            // 当前视频标题
            if (this.currentVideo) {
              Text(this.currentVideo.title)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
                .margin({ bottom: 6 })

              if (this.currentVideo.description) {
                Text(this.currentVideo.description)
                  .fontSize(13)
                  .fontColor('#888')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .margin({ bottom: 12 })
              }
            }

            // 学习内容标题
            Row() {
              Text('课程列表')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
              Blank()
              Text(`共${this.videos.length}个视频`)
                .fontSize(12)
                .fontColor('#999')
            }
            .width('100%')
            .margin({ top: 4, bottom: 12 })

            // 视频列表
            if (this.videos.length === 0) {
              Column() {
                Text('该模块暂无视频')
                  .fontSize(14)
                  .fontColor('#999')
              }
              .width('100%')
              .padding(20)
            } else {
              ForEach(this.videos, (video: VideoItem) => {
                this.VideoListItem(video)
              })
            }
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
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
  VideoListItem(video: VideoItem) {
    Row() {
      Column() {
        Text(video.title)
          .fontSize(14)
          .fontColor(this.currentVideo?.id === video.id ? '#409EFF' : '#333')
          .fontWeight(this.currentVideo?.id === video.id ? FontWeight.Bold : FontWeight.Normal)
          .margin({ bottom: 4 })
        Text(video.description || '暂无描述')
          .fontSize(12)
          .fontColor('#999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.currentVideo?.id === video.id ? '▶' : '>')
        .fontSize(14)
        .fontColor(this.currentVideo?.id === video.id ? '#409EFF' : '#CCC')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.currentVideo?.id === video.id ? '#ECF5FF' : '#FFF')
    .borderRadius(10)
    .margin({ bottom: 10 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.selectVideo(video))
  }
}
