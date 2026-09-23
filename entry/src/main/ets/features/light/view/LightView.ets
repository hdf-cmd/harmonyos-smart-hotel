// 灯光 Tab 的根页面：总开关 + 场景模式（5 项）+ 独立控制（9 路）
//
// 【三级导航 · 第三级】Tab 根页面自持子栈并注册域内路由。本域暂无子页，子栈先立空架子。
// 场景与 9 路灯的状态都在 LightViewModel 单例里——首页与本页共享同一份状态。
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { MainTabModel } from '../../../common/model/MainTabModel'
import { LightViewModel } from '../viewmodel/LightViewModel'

@ComponentV2
export struct LightView {
  // 本域自持子栈
  @Provider('lightStack') lightStack: NavPathStack = new NavPathStack()

  // 本域路由表（暂无域内子页）
  @Builder
  LightRouter(name: string, param: Object) {
  }

  @Local viewModel: LightViewModel = LightViewModel.getInstance()
  @Local tabModel: MainTabModel = MainTabModel.getInstance()

  private showToast(message: string): void {
    this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 })
  }

  // 场景模式按钮（选中态加一圈亮边）
  @Builder
  sceneButton(icon: Resource, label: string, scene: string) {
    Stack() {
      Image($r('app.media.light_btn_mode_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)

      Row({ space: 8 }) {
        Image(icon)
          .width(22)
          .height(22)

        Text(label)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_TEXT_ON_GOLD)
      }
      .width('100%')
      .padding({ left: 12, right: 4 })
      .justifyContent(FlexAlign.Start)
    }
    .layoutWeight(1)
    .height(38)
    .borderRadius(19)
    .borderWidth(this.viewModel.activeScene === scene ? 1.5 : 0)
    .borderColor(CommonConstants.COLOR_GOLD_LIGHT_TEXT)
    .onClick(() => {
      this.viewModel.applyScene(scene)
      this.showToast(`已切换到${label}`)
    })
  }

  // 独立控制的一行：图标 + 名称 + 开关
  // 注意：开关状态在 Builder 内部读取（isLightOn），而不是通过参数传入——
  // @Builder 按值传参时参数变化不会触发刷新（实测过的坑）
  @Builder
  lightRow(icon: Resource, label: string, key: string) {
    Row({ space: 8 }) {
      Image(icon)
        .width(20)
        .height(20)

      Text(label)
        .fontSize(13)
        .fontColor(CommonConstants.COLOR_TEXT_ON_IMG_SOFT)

      Blank()

      Image(this.viewModel.isLightOn(key) ? $r('app.media.light_toggle_on') : $r('app.media.light_toggle_off'))
        .width(CommonConstants.TOGGLE_WIDTH)
        .height(CommonConstants.TOGGLE_HEIGHT)
    }
    .width('100%')
    .height(CommonConstants.LIGHT_ROW_HEIGHT)
    .onClick(() => {
      const newState = this.viewModel.toggleLight(key)
      this.showToast(`${label}已${newState ? '开启' : '关闭'}`)
    })
  }

  build() {
    // Navigation：本域的子栈容器。域内 push 只在域内发生，不会顶掉底部 Tab
    Navigation(this.lightStack) {
      Stack() {
        // 全屏底图
        Image($r('app.media.page_background'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        Column() {
          // 顶栏：返回（切回首页 Tab）+ 居中标题
          Row() {
            Image($r('app.media.light_icon_back'))
              .width(24)
              .height(24)
              .onClick(() => {
                this.tabModel.index = MainTabModel.TAB_HOME
              })

            Text('灯光控制')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Row().width(24)
          }
          .width('100%')
          .height(44)

          // 总开关（一键全开 / 全关）
          Column({ space: 6 }) {
            Image($r('app.media.light_btn_main_switch'))
              .width(CommonConstants.MAIN_SWITCH_SIZE)
              .height(CommonConstants.MAIN_SWITCH_SIZE)
              .opacity(this.viewModel.masterOn ? 1.0 : 0.55)
              .onClick(() => {
                const on = this.viewModel.toggleMaster()
                this.showToast(on ? '已全部开启' : '已全部关闭')
              })

            Text('总开关')
              .fontSize(14)
              .fontColor(CommonConstants.COLOR_TEXT_ON_IMG_SOFT)
          }
          .width('100%')
          .margin({ top: 14 })

          // 场景模式（5 项：明亮/柔和/阅读/温馨/睡眠）
          Stack() {
            Image($r('app.media.light_scene_mode_bg'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Fill)

            Column({ space: 10 }) {
              Text('场景模式')
                .fontSize(15)
                .fontColor(Color.White)
                .width('100%')

              Row({ space: 12 }) {
                this.sceneButton($r('app.media.light_icon_bright_mode'), '明亮模式', LightViewModel.SCENE_BRIGHT)
                this.sceneButton($r('app.media.light_icon_soft'), '柔和模式', LightViewModel.SCENE_SOFT)
              }
              .width('100%')

              Row({ space: 12 }) {
                this.sceneButton($r('app.media.light_icon_read_mode'), '阅读模式', LightViewModel.SCENE_READ)
                this.sceneButton($r('app.media.light_icon_warm_mode'), '温馨模式', LightViewModel.SCENE_WARM)
              }
              .width('100%')

              Row({ space: 12 }) {
                this.sceneButton($r('app.media.light_icon_sleep_mode'), '睡眠模式', LightViewModel.SCENE_SLEEP)
                Row().layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 12, bottom: 12 })
          }
          .width('100%')
          .height(188)
          .margin({ top: 16 })

          // 独立控制（9 路：两列 5+4）
          Stack() {
            Image($r('app.media.light_independent_control_bg'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Fill)

            Column({ space: 4 }) {
              Text('独立控制')
                .fontSize(15)
                .fontColor(Color.White)
                .width('100%')
                .margin({ bottom: 4 })

              Row() {
                Column() {
                  this.lightRow($r('app.media.light_icon_washroom'), '洗漱间',
                    LightViewModel.LIGHT_WASHROOM)
                }
                .layoutWeight(1)

                Column() {
                  this.lightRow($r('app.media.light_icon_wardrobe'), '衣柜灯',
                    LightViewModel.LIGHT_WARDROBE)
                }
                .layoutWeight(1)
                .margin({ left: 18 })
              }
              .width('100%')

              Row() {
                Column() {
                  this.lightRow($r('app.media.light_icon_bar_lamp'), '落地灯',
                    LightViewModel.LIGHT_FLOOR)
                }
                .layoutWeight(1)

                Column() {
                  this.lightRow($r('app.media.light_icon_bar_lamp'), '吧灯',
                    LightViewModel.LIGHT_BAR)
                }
                .layoutWeight(1)
                .margin({ left: 18 })
              }
              .width('100%')

              Row() {
                Column() {
                  this.lightRow($r('app.media.light_icon_right_left_desk_read'), '书桌灯',
                    LightViewModel.LIGHT_DESK)
                }
                .layoutWeight(1)

                Column() {
                  this.lightRow($r('app.media.light_icon_right_left_desk_read'), '右阅读灯',
                    LightViewModel.LIGHT_READ_RIGHT)
                }
                .layoutWeight(1)
                .margin({ left: 18 })
              }
              .width('100%')

              Row() {
                Column() {
                  this.lightRow($r('app.media.light_icon_right_left_desk_read'), '左阅读灯',
                    LightViewModel.LIGHT_READ_LEFT)
                }
                .layoutWeight(1)

                Column() {
                  this.lightRow($r('app.media.light_icon_exhaust_fan'), '排风扇',
                    LightViewModel.LIGHT_FAN)
                }
                .layoutWeight(1)
                .margin({ left: 18 })
              }
              .width('100%')

              Row() {
                Column() {
                  this.lightRow($r('app.media.light_icon_corrid_lights'), '廊灯',
                    LightViewModel.LIGHT_CORRIDOR)
                }
                .layoutWeight(1)

                Column()
                  .layoutWeight(1)
                  .margin({ left: 18 })
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          }
          .width('100%')
          .height(288)
          .margin({ top: 16 })
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
    .navDestination(this.LightRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
