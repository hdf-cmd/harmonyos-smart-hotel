// 服务 Tab 的根页面：请勿打扰 / 清理房间开关卡 + SOS 紧急呼叫 + 退出登录
//
// 【三级导航 · 第三级】Tab 根页面自持子栈并注册域内路由。本域暂无子页，子栈先立空架子。
// 两个开关的状态在 ServiceViewModel 单例里——首页"快捷服务"与本页共享同一份状态，天然双向同步。
import { common } from '@kit.AbilityKit'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { MainTabModel } from '../../../common/model/MainTabModel'
import { RouteConstants } from '../../../common/constants/RouteConstants'
import { LoginViewModel } from '../../login/viewmodel/LoginViewModel'
import { ServiceViewModel } from '../viewmodel/ServiceViewModel'

@ComponentV2
export struct ServiceView {
  // 本域自持子栈
  @Provider('serviceStack') serviceStack: NavPathStack = new NavPathStack()

  // 本域路由表（暂无域内子页）
  @Builder
  ServiceRouter(name: string, param: Object) {
  }

  // 根栈：退出登录要回登录页
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  @Local viewModel: ServiceViewModel = ServiceViewModel.getInstance()
  @Local loginVM: LoginViewModel = LoginViewModel.getInstance()
  @Local tabModel: MainTabModel = MainTabModel.getInstance()

  private showToast(message: string): void {
    this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 })
  }

  /**
   * 开关状态判定（在 Builder 内部调用，保证状态依赖发生在 Builder 内部）
   */
  private isSwitchOn(isDnd: boolean): boolean {
    return isDnd ? this.viewModel.doNotDisturb : this.viewModel.cleanRoom
  }

  /**
   * 服务开关卡（整卡可点，点击切换；状态在 Builder 内部读）
   */
  @Builder
  serviceCard(icon: Resource, label: string, isDnd: boolean) {
    Stack() {
      Image(isDnd ? $r('app.media.service_do_not_disturb_bg') : $r('app.media.service_clean_room_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)

      Column({ space: 10 }) {
        Image(icon)
          .width(58)
          .height(62)
          .objectFit(ImageFit.Contain)

        Text(label)
          .fontSize(15)
          .fontColor(Color.White)

        // 自绘滑动开关：轨道 + 圆钮（钮随状态贴左/贴右）
        Stack({ alignContent: this.isSwitchOn(isDnd) ? Alignment.End : Alignment.Start }) {
          Image($r('app.media.service_toggle_bg'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Fill)

          Image($r('app.media.service_toggle_dots_bg'))
            .width(CommonConstants.SERVICE_TOGGLE_KNOB)
            .height(CommonConstants.SERVICE_TOGGLE_KNOB)
            .margin({ left: 2, right: 2 })
        }
        .width(CommonConstants.SERVICE_TOGGLE_WIDTH)
        .height(CommonConstants.SERVICE_TOGGLE_HEIGHT)
      }
      .padding({ top: 24, bottom: 16 })
    }
    .layoutWeight(1)
    .aspectRatio(0.92)
    .onClick(() => {
      const ui = this.getUIContext()
      ui.animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
        if (isDnd) {
          const on = this.viewModel.toggleDoNotDisturb()
          this.showToast(on ? '已开启请勿打扰' : '已取消请勿打扰')
        } else {
          const on = this.viewModel.toggleCleanRoom()
          this.showToast(on ? '已开启清理房间' : '已取消清理房间')
        }
      })
    })
  }

  /**
   * SOS：先二次确认，再呼叫
   */
  private confirmSos(): void {
    this.getUIContext().getPromptAction().showDialog({
      title: '紧急呼叫',
      message: '确认向酒店前台发送 SOS 求助？',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '确认呼叫', color: '#D93A2B' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        this.viewModel.callSos(this.loginVM.roomNo)
        this.showToast('SOS 已发送，前台马上响应')
      }
    })
  }

  /**
   * 退出登录：二次确认 → 清记住信息 → 回登录页
   */
  private confirmLogout(): void {
    this.getUIContext().getPromptAction().showDialog({
      title: '退出登录',
      message: '退出后需要重新输入房号入住，确认退出？',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '退出', color: '#D93A2B' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        this.doLogout()
      }
    })
  }

  private async doLogout(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.Context
    await this.loginVM.logout(context)
    this.pageStack.replacePathByName(RouteConstants.LOGIN, null)
  }

  build() {
    // Navigation：本域的子栈容器。域内 push 只在域内发生，不会顶掉底部 Tab
    Navigation(this.serviceStack) {
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

            Text('服务控制')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Row().width(24)
          }
          .width('100%')
          .height(44)

          // 两张服务开关卡
          Row({ space: 12 }) {
            this.serviceCard($r('app.media.service_icon_do_not_disturb'), '请勿打扰', true)
            this.serviceCard($r('app.media.service_icon_clean_room'), '清理房间', false)
          }
          .width('100%')
          .margin({ top: 14 })

          // SOS 紧急呼叫（图内已含铃铛与文字）
          Image($r('app.media.service_btn_sos_bg'))
            .width('88%')
            .aspectRatio(2.68)
            .margin({ top: 18 })
            .onClick(() => {
              this.confirmSos()
            })

          Blank()

          // 退出登录（图内已含文字与图标）
          Image($r('app.media.service_btn_logout'))
            .width('88%')
            .aspectRatio(3.76)
            .margin({ bottom: 8 })
            .onClick(() => {
              this.confirmLogout()
            })
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
    .navDestination(this.ServiceRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
