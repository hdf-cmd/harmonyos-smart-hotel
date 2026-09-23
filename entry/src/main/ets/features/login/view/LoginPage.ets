// 登录页（第 2 步正式实现，当前为第 1 步骨架占位）
//
// 只做一件事：把"点按钮 → replace 到主壳"的通路跑通，证明根栈接线正确。
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RouteConstants } from '../../../common/constants/RouteConstants'

@ComponentV2
export struct LoginPage {
  // 根栈：登录成功后要 replace 到主页面
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column({ space: CommonConstants.SPACE_M }) {
        Text('智慧酒店')
          .fontSize(CommonConstants.FONT_TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)

        Text('登录页开发中（第 2 步实现）')
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_TEXT_HINT)

        Button('进入主界面（骨架联调）')
          .type(ButtonType.Capsule)
          .height(CommonConstants.BTN_HEIGHT)
          .backgroundColor(CommonConstants.COLOR_PRIMARY)
          .onClick(() => {
            this.pageStack.replacePathByName(RouteConstants.MAIN, null)
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
  }
}
