// 窗帘 Tab 的根页面：全局开关（全部打开/全部关闭）+ 布帘 / 窗纱三态控制（含开合动画）
//
// 【三级导航 · 第三级】Tab 根页面自持子栈并注册域内路由。本域暂无子页，子栈先立空架子。
// 视觉逻辑：展开态用"垂帘"部件；关闭态用"直布板"部件各占半幅——
// 两块布沿外边缘向中间生长/回收 + 垂帘淡出淡入，用 animateTo 补出开合动画。
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { MainTabModel } from '../../../common/model/MainTabModel'
import { CurtainViewModel } from '../viewmodel/CurtainViewModel'

@ComponentV2
export struct CurtainView {
  // 本域自持子栈
  @Provider('curtainStack') curtainStack: NavPathStack = new NavPathStack()

  // 本域路由表（暂无域内子页）
  @Builder
  CurtainRouter(name: string, param: Object) {
  }

  @Local viewModel: CurtainViewModel = CurtainViewModel.getInstance()
  @Local tabModel: MainTabModel = MainTabModel.getInstance()

  private showToast(message: string): void {
    this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 })
  }

  /**
   * 当前态判定（在 Builder 内部调用，保证状态依赖发生在 Builder 内部）
   */
  private isStateActive(state: string, isScreening: boolean): boolean {
    if (isScreening) {
      return this.viewModel.screenState === state
    }
    return this.viewModel.curtainState === state
  }

  /**
   * 三态按钮（金色圆底=当前态；暗色圆底=非当前态）
   */
  @Builder
  stateButton(icon: Resource, label: string, state: string, isScreening: boolean) {
    Column({ space: 6 }) {
      Stack() {
        Image(this.isStateActive(state, isScreening)
          ? $r('app.media.curtain_btn_selected_bg')
          : $r('app.media.curtain_btn_unselected_bg'))
          .width(CommonConstants.CURTAIN_BTN_SIZE)
          .height(CommonConstants.CURTAIN_BTN_SIZE)

        Image(icon)
          .width(24)
          .height(22)
      }

      Text(label)
        .fontSize(13)
        .fontColor(this.isStateActive(state, isScreening) ? Color.White : CommonConstants.COLOR_TEXT_ON_IMG_SOFT)
    }
    .layoutWeight(1)
    .onClick(() => {
      // 用 animateTo 包住状态变更，让帘布的宽度/透明度变化播成开合动画（已用慢动作构建实测验证）
      this.getUIContext().animateTo({ duration: 500, curve: Curve.EaseInOut }, () => {
        if (isScreening) {
          this.viewModel.setScreening(state)
        } else {
          this.viewModel.setCurtain(state)
        }
      })
      this.showToast(`${label}${isScreening ? '窗纱' : '布帘'}`)
    })
  }

  /**
   * 全局按钮（选中的那个是金色胶囊）
   */
  @Builder
  globalButton(icon: Resource, label: string, isOpenAction: boolean) {
    Stack() {
      if (isOpenAction ? this.viewModel.allOpen : this.viewModel.allClosed) {
        Image($r('app.media.curtain_btn_all_open_or_close_selected_bg'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
      }

      Row({ space: 8 }) {
        Image(icon)
          .width(22)
          .height(20)

        Text(label)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor((isOpenAction ? this.viewModel.allOpen : this.viewModel.allClosed)
            ? CommonConstants.COLOR_TEXT_ON_GOLD
            : CommonConstants.COLOR_TEXT_ON_IMG_SOFT)
      }
    }
    .layoutWeight(1)
    .height(46)
    .onClick(() => {
      this.getUIContext().animateTo({ duration: 600, curve: Curve.EaseInOut }, () => {
        if (isOpenAction) {
          this.viewModel.openAll()
        } else {
          this.viewModel.closeAll()
        }
      })
      this.showToast(isOpenAction ? '已全部打开' : '已全部关闭')
    })
  }

  build() {
    // Navigation：本域的子栈容器。域内 push 只在域内发生，不会顶掉底部 Tab
    Navigation(this.curtainStack) {
      Stack() {
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

            Text('窗帘控制')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Row().width(24)
          }
          .width('100%')
          .height(44)

          // 全局开关卡：全部打开 / 全部关闭
          Stack() {
            Image($r('app.media.curtain_all_open_close_part_bg'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Fill)

            Row({ space: 12 }) {
              this.globalButton($r('app.media.curtain_icon_open_all'), '全部打开', true)
              this.globalButton($r('app.media.curtain_icon_close_all'), '全部关闭', false)
            }
            .width('100%')
            .padding({ left: 14, right: 14 })
          }
          .width('100%')
          .height(72)
          .margin({ top: 8 })

          // 布帘卡
          Stack() {
            Image($r('app.media.curtain_curtain_section_part_bg'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Fill)

            Column() {
              Text('布帘')
                .fontSize(15)
                .fontColor(CommonConstants.COLOR_TEXT_ON_IMG_SOFT)
                .width('100%')

              // 帘布可视区：帘杆 + 展开态垂帘 + 关闭态直布板（宽度动画）
              Stack({ alignContent: Alignment.Top }) {
                Image($r('app.media.curtain_icon_top_bar'))
                  .width('100%')
                  .height(10)
                  .objectFit(ImageFit.Fill)

                // 展开态：两侧垂帘（打开时可见）
                Row() {
                  Image($r('app.media.curtain_icon_left_part'))
                    .height('100%')
                    .objectFit(ImageFit.Contain)

                  Blank()

                  Image($r('app.media.curtain_icon_right_part'))
                    .height('100%')
                    .objectFit(ImageFit.Contain)
                }
                .width('100%')
                .height('100%')
                .margin({ top: 8 })
                .opacity(this.viewModel.curtainClosed ? 0.0 : 1.0)

                // 关闭态：两块直布板沿外边缘向中间生长（关闭时可见）
                Row() {
                  Image($r('app.media.curtain_icon_left_closed'))
                    .height('100%')
                    .width(this.viewModel.curtainClosed ? '50%' : '10%')
                    .objectFit(ImageFit.Fill)

                  Image($r('app.media.curtain_icon_right_closed'))
                    .height('100%')
                    .width(this.viewModel.curtainClosed ? '50%' : '10%')
                    .objectFit(ImageFit.Fill)
                }
                .width('100%')
                .height('100%')
                .margin({ top: 8 })
                .opacity(this.viewModel.curtainClosed ? 1.0 : 0.0)
              }
              .width('56%')
              .height(CommonConstants.CURTAIN_VISUAL_HEIGHT)
              .margin({ top: 6 })
              .clip(true)

              // 三态按钮
              Row() {
                this.stateButton($r('app.media.curtain_icon_open'), '打开', CurtainViewModel.STATE_OPEN, false)
                this.stateButton($r('app.media.curtain_icon_pause'), '暂停', CurtainViewModel.STATE_PAUSE, false)
                this.stateButton($r('app.media.curtain_icon_close'), '关闭', CurtainViewModel.STATE_CLOSE, false)
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 8 })
          }
          .width('100%')
          .height(CommonConstants.CURTAIN_CARD_HEIGHT)
          .margin({ top: 10 })

          // 窗纱卡（结构同布帘，素材换成窗纱部件）
          Stack() {
            Image($r('app.media.curtain_window_screening_part_bg'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Fill)

            Column() {
              Text('窗纱')
                .fontSize(15)
                .fontColor(CommonConstants.COLOR_TEXT_ON_IMG_SOFT)
                .width('100%')

              Stack({ alignContent: Alignment.Top }) {
                Image($r('app.media.curtain_icon_top_bar'))
                  .width('100%')
                  .height(10)
                  .objectFit(ImageFit.Fill)

                Row() {
                  Image($r('app.media.curtain_icon_window_screening_left_part'))
                    .height('100%')
                    .objectFit(ImageFit.Contain)

                  Blank()

                  Image($r('app.media.curtain_icon_window_screening_right_part'))
                    .height('100%')
                    .objectFit(ImageFit.Contain)
                }
                .width('100%')
                .height('100%')
                .margin({ top: 8 })
                .opacity(this.viewModel.screenClosed ? 0.0 : 1.0)

                Row() {
                  Image($r('app.media.curtain_icon_window_screening_left_part_closed'))
                    .height('100%')
                    .width(this.viewModel.screenClosed ? '50%' : '10%')
                    .objectFit(ImageFit.Fill)

                  Image($r('app.media.curtain_icon_window_screening_right_part_closed'))
                    .height('100%')
                    .width(this.viewModel.screenClosed ? '50%' : '10%')
                    .objectFit(ImageFit.Fill)
                }
                .width('100%')
                .height('100%')
                .margin({ top: 8 })
                .opacity(this.viewModel.screenClosed ? 1.0 : 0.0)
              }
              .width('56%')
              .height(CommonConstants.CURTAIN_VISUAL_HEIGHT)
              .margin({ top: 6 })
              .clip(true)

              Row() {
                this.stateButton($r('app.media.curtain_icon_open'), '打开', CurtainViewModel.STATE_OPEN, true)
                this.stateButton($r('app.media.curtain_icon_pause'), '暂停', CurtainViewModel.STATE_PAUSE, true)
                this.stateButton($r('app.media.curtain_icon_close'), '关闭', CurtainViewModel.STATE_CLOSE, true)
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 8 })
          }
          .width('100%')
          .height(CommonConstants.CURTAIN_CARD_HEIGHT)
          .margin({ top: 10 })
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
    .navDestination(this.CurtainRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
