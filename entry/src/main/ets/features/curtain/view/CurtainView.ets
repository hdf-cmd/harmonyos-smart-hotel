// 窗帘 Tab 的根页面（第 5 步实现正式内容，当前为骨架占位）
//
// 【三级导航 · 第三级】Tab 根页面自持子栈并注册域内路由。
// 本域暂无子页，子栈与路由先立空架子——有子页面时往 CurtainRouter 里填即可。
import { CommonConstants } from '../../../common/constants/CommonConstants'

@ComponentV2
export struct CurtainView {
  // 本域自持子栈
  @Provider('curtainStack') curtainStack: NavPathStack = new NavPathStack()

  // 本域路由表（暂无域内子页）
  @Builder
  CurtainRouter(name: string, param: Object) {
  }

  build() {
    Navigation(this.curtainStack) {
      Column() {
        Text('窗帘控制')
          .fontSize(CommonConstants.FONT_TITLE)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .fontWeight(FontWeight.Bold)

        Text('页面开发中（第 5 步实现）')
          .fontSize(CommonConstants.FONT_CAPTION)
          .fontColor(CommonConstants.COLOR_TEXT_HINT)
          .margin({ top: CommonConstants.SPACE_M })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(CommonConstants.COLOR_BG_PAGE)
    }
    .navDestination(this.CurtainRouter)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}
