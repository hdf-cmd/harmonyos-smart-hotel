// 登录页（View 层）：零业务逻辑，全部委托 LoginViewModel
//
// 输入框 onChange 只做一件事：把值塞给 ViewModel 的 @Trace 字段
// 按钮 onClick 只做一件事：调 ViewModel 并消费结果（res.ok 决定跳不跳转）
import { common } from '@kit.AbilityKit'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RouteConstants } from '../../../common/constants/RouteConstants'
import { LoginViewModel } from '../viewmodel/LoginViewModel'

@ComponentV2
export struct LoginPage {
  // 根栈：登录成功后要 replace 到主页面
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 单例 ViewModel：房号等状态进主界面后还要被首页读取
  @Local viewModel: LoginViewModel = LoginViewModel.getInstance()

  aboutToAppear(): void {
    // 恢复"记住我的信息"；首次启动时没有历史记录，保持设计稿预填值
    const context = this.getUIContext().getHostContext() as common.Context
    this.viewModel.restore(context)
  }

  build() {
    NavDestination() {
      Stack() {
        // 全屏大堂背景（延伸进状态栏与底部导航条）
        Image($r('app.media.bg_hotel_full'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        Column() {
          // 标题区
          Column({ space: 6 }) {
            Text('广科·未来酒店')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE)

            Text('华为ICT学院专属智臻旅居体验')
              .fontSize(CommonConstants.FONT_CAPTION)
              .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE_SUB)
          }
          .margin({ top: 132 })

          // 表单区
          Column({ space: CommonConstants.SPACE_M }) {
            // 房号输入
            Row() {
              Image($r('app.media.icon_input_room'))
                .width(26)
                .height(26)
                .margin({ right: 12 })

              TextInput({ text: this.viewModel.roomNo, placeholder: '请输入房号' })
                .type(InputType.Number)
                .layoutWeight(1)
                .height('100%')
                .backgroundColor(Color.Transparent)
                .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE)
                .fontSize(CommonConstants.FONT_BODY)
                .placeholderColor(CommonConstants.COLOR_TEXT_ON_IMAGE_HINT)
                .showUnderline(false)
                .onChange((value: string) => {
                  this.viewModel.roomNo = value
                })
            }
            .width('100%')
            .height(CommonConstants.INPUT_HEIGHT)
            .backgroundColor(CommonConstants.COLOR_INPUT_BG)
            .borderRadius(CommonConstants.INPUT_RADIUS)
            .padding({ left: CommonConstants.SPACE_L, right: CommonConstants.SPACE_L })

            // 用户名输入
            Row() {
              Image($r('app.media.icon_input_user'))
                .width(26)
                .height(26)
                .margin({ right: 12 })

              TextInput({ text: this.viewModel.userName, placeholder: '请输入用户名' })
                .layoutWeight(1)
                .height('100%')
                .backgroundColor(Color.Transparent)
                .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE)
                .fontSize(CommonConstants.FONT_BODY)
                .placeholderColor(CommonConstants.COLOR_TEXT_ON_IMAGE_HINT)
                .showUnderline(false)
                .onChange((value: string) => {
                  this.viewModel.userName = value
                })
            }
            .width('100%')
            .height(CommonConstants.INPUT_HEIGHT)
            .backgroundColor(CommonConstants.COLOR_INPUT_BG)
            .borderRadius(CommonConstants.INPUT_RADIUS)
            .padding({ left: CommonConstants.SPACE_L, right: CommonConstants.SPACE_L })

            // 记住我的信息
            Row({ space: CommonConstants.SPACE_S }) {
              Image(this.viewModel.rememberMe
                ? $r('app.media.icon_input_checked')
                : $r('app.media.icon_input_unchecked'))
                .width(22)
                .height(22)

              Text('记住我的信息')
                .fontSize(CommonConstants.FONT_CAPTION)
                .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE_SUB)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              this.viewModel.rememberMe = !this.viewModel.rememberMe
            })

            // 错误提示（errorMessage 非空才渲染）
            if (this.viewModel.errorMessage !== '') {
              Text(this.viewModel.errorMessage)
                .fontSize(12)
                .fontColor(CommonConstants.COLOR_ERROR)
                .width('100%')
            }

            // 立即入住按钮
            Button('立即入住')
              .width('100%')
              .height(CommonConstants.LOGIN_BTN_HEIGHT)
              .type(ButtonType.Capsule)
              .fontSize(CommonConstants.FONT_SUBTITLE)
              .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE)
              .backgroundColor(Color.Transparent)
              .linearGradient({
                angle: 90,
                colors: [
                  [CommonConstants.COLOR_GOLD_START, 0.0],
                  [CommonConstants.COLOR_GOLD_END, 1.0]
                ]
              })
              .onClick(() => {
                // View 不做业务判断，只转发事件、消费结果
                const res = this.viewModel.submit()
                if (res.ok) {
                  // 用 replace 而不是 push：登录页不该留在返回历史里
                  const context = this.getUIContext().getHostContext() as common.Context
                  this.viewModel.persistLoginState(context)
                  this.pageStack.replacePathByName(RouteConstants.MAIN, null)
                }
              })
          }
          .width('100%')
          .padding({ left: 28, right: 28 })
          .margin({ top: 56 })

          Blank()

          // 底部标语
          Column({ space: 4 }) {
            Text('温馨·重塑智臻旅居体验，让科技赋能每一次下榻。')
              .fontSize(11)
              .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE_HINT)

            Text('欢迎回家，尽享未来舒适之旅。')
              .fontSize(11)
              .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE_HINT)

            Row() {
              Blank()

              Text('✦')
                .fontSize(16)
                .fontColor(CommonConstants.COLOR_TEXT_ON_IMAGE_HINT)
            }
            .width('100%')
            .margin({ top: 14 })
          }
          .width('100%')
          .padding({ left: 28, right: 28 })
          .margin({ bottom: 12 })
        }
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(true)
  }
}
