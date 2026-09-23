// 窗帘 Tab 的根页面：全局开关（全部打开/全部关闭）+ 布帘 / 窗纱三态控制（含开合动画）
//
// 【三级导航 · 第三级】Tab 根页面自持子栈并注册域内路由。本域暂无子页，子栈先立空架子。
// 视觉逻辑：展开态用"垂帘"部件；关闭态用"直布板"部件各占半幅——
// 打开 = 两块布板各自向两侧平移滑出（中缝向两边张开）；关闭 = 从两侧滑回中间合拢。
// 动画：VM 存位置进度 pos（0=全开 → 1=全关），View 用 Animator 逐帧写回——
// 暂停可真停住半途，再点打开/关闭按剩余距离续跑；平移出画 + 外层裁切，布面不压缩。
import { AnimatorResult } from '@kit.ArkUI'
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

  // 开合动画执行器：布帘 / 窗纱各一个（可暂停停住、可按剩余距离续跑）
  private curtainAnimator?: AnimatorResult
  private screenAnimator?: AnimatorResult

  aboutToDisappear(): void {
    // 拆掉回调再取消：cancel 带"到终点"语义会迟到派发终点帧，避免写坏共享 VM 的位置
    this.releaseAnimator(this.curtainAnimator)
    this.releaseAnimator(this.screenAnimator)
  }

  /**
   * 安全释放动画：先摘掉回调再 cancel——
   * cancel 与 finish 同语义（会"到终点"并迟到派发终点帧），
   * 若不清回调，旧动画结束后会把位置写回旧目标（实测踩坑：暂停后改点另一方向，帘布过一会弹回）
   */
  private releaseAnimator(animator?: AnimatorResult): void {
    if (animator) {
      animator.onFrame = (): void => {}
      animator.onFinish = (): void => {}
      animator.cancel()
    }
  }

  /**
   * 布帘状态变化 → 驱动开合动画（暂停=停住当前帧；打开/关闭=滑向目标）
   */
  @Monitor('viewModel.curtainState')
  onCurtainStateChange(): void {
    this.driveAnim(false, this.viewModel.curtainState)
  }

  /**
   * 窗纱状态变化 → 驱动开合动画
   */
  @Monitor('viewModel.screenState')
  onScreenStateChange(): void {
    this.driveAnim(true, this.viewModel.screenState)
  }

  /**
   * 驱动开合动画：暂停停在当前帧；打开/关闭从当前位置滑到目标
   * （时长按剩余距离等比缩放——剩得少就用得短，续跑不突兀）
   */
  private driveAnim(isScreening: boolean, state: string): void {
    const from: number = isScreening ? this.viewModel.screenPos : this.viewModel.curtainPos

    if (state === CurtainViewModel.STATE_PAUSE) {
      if (isScreening) {
        this.screenAnimator?.pause()
      } else {
        this.curtainAnimator?.pause()
      }
      return
    }

    const target: number = state === CurtainViewModel.STATE_CLOSE ? 1 : 0
    const distance: number = Math.abs(target - from)
    if (distance < 0.001) {
      return // 已在目标位（例如全开时再点打开），无需动画
    }

    // 结束上一个动画：先摘回调再 cancel（见 releaseAnimator 注释）
    if (isScreening) {
      this.releaseAnimator(this.screenAnimator)
    } else {
      this.releaseAnimator(this.curtainAnimator)
    }

    const animator: AnimatorResult = this.getUIContext().createAnimator({
      duration: Math.round(CommonConstants.CURTAIN_ANIM_DURATION * distance),
      easing: 'ease-in-out',
      delay: 0,
      fill: 'forwards',
      direction: 'normal',
      iterations: 1,
      begin: 0,
      end: 1
    })
    animator.onFrame = (progress: number): void => {
      // 状态已被暂停/改向时本动画作废（防过期回调污染位置）
      if ((isScreening ? this.viewModel.screenState : this.viewModel.curtainState) !== state) {
        return
      }
      const pos: number = from + (target - from) * progress
      if (isScreening) {
        this.viewModel.applyScreenPos(pos)
      } else {
        this.viewModel.applyCurtainPos(pos)
      }
    }
    animator.onFinish = (): void => {
      if ((isScreening ? this.viewModel.screenState : this.viewModel.curtainState) !== state) {
        return // 已被暂停/改向：落位作废，位置留在当前帧由下一次状态变化驱动
      }
      if (isScreening) {
        this.viewModel.applyScreenPos(target)
      } else {
        this.viewModel.applyCurtainPos(target)
      }
    }
    if (isScreening) {
      this.screenAnimator = animator
    } else {
      this.curtainAnimator = animator
    }
    animator.play()
  }

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
      // 只改状态：开合动画由状态监听统一驱动（暂停可真停住，开/关按剩余距离续跑）
      if (isScreening) {
        this.viewModel.setScreening(state)
      } else {
        this.viewModel.setCurtain(state)
      }
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
      if (isOpenAction) {
        this.viewModel.openAll()
      } else {
        this.viewModel.closeAll()
      }
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
          .height(68)
          .margin({ top: 6 })

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

                // 展开态：两侧垂帘（打开时可见）。左右素材为同尺寸镜像对，
                // 各占半幅强制等宽 + Cover 撑满，保证打开后左右严格对称、帘布贴杆垂下
                Row() {
                  Image($r('app.media.curtain_icon_left_part'))
                    .width('50%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)

                  Image($r('app.media.curtain_icon_right_part'))
                    .width('50%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                }
                .width('100%')
                .height('100%')
                .margin({ top: 8 })
                .opacity(1.0 - this.viewModel.curtainPos)

                // 关闭态：两块直布板——打开时各自向两侧平移滑出（中缝向两边张开），
                // 关闭时从两侧滑回中间合拢；位置由进度 pos 驱动，可停在半途（暂停）
                Row() {
                  Image($r('app.media.curtain_icon_left_closed'))
                    .height('100%')
                    .width('50%')
                    .objectFit(ImageFit.Fill)
                    .translate({ x: `${(-100 * (1 - this.viewModel.curtainPos)).toFixed(2)}%` })

                  Image($r('app.media.curtain_icon_right_closed'))
                    .height('100%')
                    .width('50%')
                    .objectFit(ImageFit.Fill)
                    .translate({ x: `${(100 * (1 - this.viewModel.curtainPos)).toFixed(2)}%` })
                }
                .width('100%')
                .height('100%')
                .margin({ top: 8 })
                .opacity(this.viewModel.curtainPos)
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
          .margin({ top: 8 })

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

                // 展开态：两侧垂帘（同布帘卡：等宽半幅 + Cover，左右对称）
                Row() {
                  Image($r('app.media.curtain_icon_window_screening_left_part'))
                    .width('50%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)

                  Image($r('app.media.curtain_icon_window_screening_right_part'))
                    .width('50%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                }
                .width('100%')
                .height('100%')
                .margin({ top: 8 })
                .opacity(1.0 - this.viewModel.screenPos)

                // 关闭态：两块窗纱板——打开时各自向两侧平移滑出，关闭时从两侧滑回中间合拢
                Row() {
                  Image($r('app.media.curtain_icon_window_screening_left_part_closed'))
                    .height('100%')
                    .width('50%')
                    .objectFit(ImageFit.Fill)
                    .translate({ x: `${(-100 * (1 - this.viewModel.screenPos)).toFixed(2)}%` })

                  Image($r('app.media.curtain_icon_window_screening_right_part_closed'))
                    .height('100%')
                    .width('50%')
                    .objectFit(ImageFit.Fill)
                    .translate({ x: `${(100 * (1 - this.viewModel.screenPos)).toFixed(2)}%` })
                }
                .width('100%')
                .height('100%')
                .margin({ top: 8 })
                .opacity(this.viewModel.screenPos)
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
          .margin({ top: 8 })
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
