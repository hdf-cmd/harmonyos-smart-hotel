// 首页 Tab 的根页面：智慧客房概览（顶栏 / 欢迎语 / 空调卡 / 场景模式 / 快捷服务）
//
// 【三级导航 · 第三级】Tab 根页面自持子栈并注册域内路由。本域暂无子页，子栈先立空架子。
// 跨页状态说明：场景模式走 LightViewModel 单例、快捷服务走 ServiceViewModel 单例，
// 灯光页（第 4 步）/ 服务页（第 6 步）会复用同一份状态。
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RouteConstants } from '../../../common/constants/RouteConstants'
import { LoginViewModel } from '../../login/viewmodel/LoginViewModel'
import { LightViewModel } from '../../light/viewmodel/LightViewModel'
import { ServiceViewModel } from '../../service/viewmodel/ServiceViewModel'
import { HomeViewModel } from '../viewmodel/HomeViewModel'

@ComponentV2
export struct HomeView {
  // 本域自持子栈
  @Provider('homeStack') homeStack: NavPathStack = new NavPathStack()

  // 根栈：右上角"离店测试"要回登录页
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 本域路由表（暂无域内子页）
  @Builder
  HomeRouter(name: string, param: Object) {
  }

  @Local viewModel: HomeViewModel = new HomeViewModel()
  @Local loginVM: LoginViewModel = LoginViewModel.getInstance()
  @Local lightVM: LightViewModel = LightViewModel.getInstance()
  @Local serviceVM: ServiceViewModel = ServiceViewModel.getInstance()

  private showToast(message: string): void {
    this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 })
  }

  // 场景模式格子（金色卡底 + 图标 + 文字）
  @Builder
  sceneTile(icon: Resource, label: string, scene: string) {
    Stack() {
      Image($r('app.media.home_layer_scenemode'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)

      Row({ space: 10 }) {
        Image(icon)
          .width(40)
          .height(40)

        Text(label)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_TEXT_ON_GOLD)
      }
      .width('100%')
      .padding({ left: 14, right: 8 })
    }
    .layoutWeight(1)
    .height(65)
    .onClick(() => {
      this.lightVM.applyScene(scene)
      this.showToast(`已切换到${label}`)
    })
  }

  // 快捷服务格子（action: dnd=请勿打扰 / clean=清理房间）
  @Builder
  quickTile(icon: Resource, label: string, action: string) {
    Stack() {
      Image($r('app.media.home_layer_scenemode'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)

      Row({ space: 10 }) {
        Image(icon)
          .width(40)
          .height(40)

        Text(label)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_TEXT_ON_GOLD)
      }
      .width('100%')
      .padding({ left: 14, right: 8 })
    }
    .layoutWeight(1)
    .height(56)
    .onClick(() => {
      if (action === 'dnd') {
        const on = this.serviceVM.toggleDoNotDisturb()
        this.showToast(on ? '已开启请勿打扰' : '已取消请勿打扰')
      } else {
        const on = this.serviceVM.toggleCleanRoom()
        this.showToast(on ? '已开启清理房间' : '已取消清理房间')
      }
    })
  }

  // 晚安模式（通栏金卡：图标 + 文案 + 月亮）
  @Builder
  nightTile() {
    Stack() {
      Image($r('app.media.home_layer_night'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)

      Row({ space: 10 }) {
        Image($r('app.media.home_icon_night_left'))
          .width(40)
          .height(40)

        Column({ space: 2 }) {
          Text('晚安模式')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(CommonConstants.COLOR_TEXT_ON_GOLD)

          Text('一健关闭所有灯光')
            .fontSize(11)
            .fontColor(CommonConstants.COLOR_TEXT_ON_GOLD_SUB)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Image($r('app.media.home_icon_night_right'))
          .width(22)
          .height(22)
      }
      .width('100%')
      .padding({ left: 14, right: 16 })
    }
    .height(58)
    .margin({ top: 12 })
    .onClick(() => {
      this.lightVM.turnAllOff()
      this.showToast('已关闭所有灯光')
    })
  }

  build() {
    // Navigation：本域的子栈容器。域内 push 只在域内发生，不会顶掉底部 Tab
    Navigation(this.homeStack) {
      Stack() {
        // 全屏底图（延伸进状态栏与底部导航条）
        Image($r('app.media.page_background'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        Column() {
          // 顶栏：标题图 + 离店测试入口
          Row() {
            Image($r('app.media.home_text_smart_guest_room'))
              .width(100)
              .height(25)
              .objectFit(ImageFit.Contain)

            Blank()

            Text('离店测试')
              .fontSize(12)
              .fontColor(CommonConstants.COLOR_TAB_INACTIVE)
              .onClick(() => {
                this.showToast('模拟离店，返回登录')
                this.pageStack.replacePathByName(RouteConstants.LOGIN, null)
              })
          }
          .width('100%')

          // 欢迎语：房号来自登录页
          Text(`欢迎回家，房号 ${this.loginVM.roomNo}`)
            .fontSize(14)
            .fontColor(CommonConstants.COLOR_TEXT_ON_IMG_SOFT)
            .width('100%')
            .margin({ top: 6 })

          // 空调卡片
          Stack() {
            Image($r('app.media.home_layer_airconditioner'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Fill)

            Column() {
              Row() {
                Row({ space: 10 }) {
                  Image($r('app.media.home_icon_airconditioner'))
                    .width(42)
                    .height(42)

                  Column({ space: 2 }) {
                    Text('空调')
                      .fontSize(17)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)

                    Text(this.viewModel.acOn ? '运行中' : '已关闭')
                      .fontSize(11)
                      .fontColor(CommonConstants.COLOR_GOLD_LIGHT_TEXT)
                  }
                  .alignItems(HorizontalAlign.Start)
                }

                Blank()

                Image($r('app.media.home_icon_close'))
                  .width(44)
                  .height(44)
                  .opacity(this.viewModel.acOn ? 1.0 : 0.45)
                  .onClick(() => {
                    this.viewModel.toggleAc()
                    this.showToast(this.viewModel.acOn ? '空调已开启' : '空调已关闭')
                  })
              }
              .width('100%')

              Blank()

              Row() {
                Text('当前温度')
                  .fontSize(12)
                  .fontColor(CommonConstants.COLOR_TEXT_ON_IMG_SOFT)

                Blank()

                Text('设定温度')
                  .fontSize(12)
                  .fontColor(CommonConstants.COLOR_TEXT_ON_IMG_SOFT)

                Text(`  ${this.viewModel.targetTemp}°C`)
                  .fontSize(16)
                  .fontColor(CommonConstants.COLOR_GOLD_LIGHT_TEXT)
              }
              .width('100%')

              Row() {
                Image($r('app.media.home_btn_sub'))
                  .width(44)
                  .height(44)
                  .onClick(() => {
                    this.viewModel.decreaseTemp()
                  })

                Blank()

                Text(`${this.viewModel.currentTemp}°C`)
                  .fontSize(40)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)

                Blank()

                Image($r('app.media.home_btn_add'))
                  .width(44)
                  .height(44)
                  .onClick(() => {
                    this.viewModel.increaseTemp()
                  })
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .padding({ left: 18, right: 18, top: 14, bottom: 14 })
          }
          .width('100%')
          .height(158)
          .margin({ top: 14 })

          // 场景模式
          Text('场景模式')
            .fontSize(15)
            .fontColor(Color.White)
            .width('100%')
            .margin({ top: 20, bottom: 10 })

          Row({ space: 12 }) {
            this.sceneTile($r('app.media.home_icon_bright'), '明亮模式', LightViewModel.SCENE_BRIGHT)
            this.sceneTile($r('app.media.home_icon_soft'), '柔和模式', LightViewModel.SCENE_SOFT)
          }
          .width('100%')

          Row({ space: 12 }) {
            this.sceneTile($r('app.media.home_icon_read'), '阅读模式', LightViewModel.SCENE_READ)
            this.sceneTile($r('app.media.home_icon_warm'), '温馨模式', LightViewModel.SCENE_WARM)
          }
          .width('100%')
          .margin({ top: 12 })

          // 快捷服务
          Text('快捷服务')
            .fontSize(15)
            .fontColor(Color.White)
            .width('100%')
            .margin({ top: 20, bottom: 10 })

          Row({ space: 12 }) {
            this.quickTile($r('app.media.home_icon_undisturb'), '请勿打扰', 'dnd')
            this.quickTile($r('app.media.home_icon_clear'), '清理房间', 'clean')
          }
          .width('100%')

          this.nightTile()
        }
        .width('100%')
        .height('100%')
        .padding({
          left: CommonConstants.PAGE_SIDE_PADDING,
          right: CommonConstants.PAGE_SIDE_PADDING,
          top: 8,
          bottom: 78
        })
      }
    }
    .navDestination(this.HomeRouter)
    .hideTitleBar(true)          // Tab 页有自己的排版，不要系统标题栏
    .mode(NavigationMode.Stack)
  }
}
