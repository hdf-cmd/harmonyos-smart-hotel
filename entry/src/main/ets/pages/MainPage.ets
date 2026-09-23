// 主页面（TabDomain）：只负责 Tab 装配，不持有子栈、不注册路由
//
// 【三级导航 · 第二级】每个 Tab 对应的 View 自己持 Navigation + 子栈 + 域内路由，
// 所以这一层保持"傻"——只干装配，不加逻辑。
import { CommonConstants } from '../common/constants/CommonConstants'
import { HomeView } from '../features/home/view/HomeView'
import { LightView } from '../features/light/view/LightView'
import { CurtainView } from '../features/curtain/view/CurtainView'
import { ServiceView } from '../features/service/view/ServiceView'

@ComponentV2
export struct MainPage {
  // 当前选中的 Tab 下标
  @Local currentIndex: number = 0

  // 自定义 TabBar：文字 + 选中变色（第 3 步换成带图标的图文版）
  // @Builder 是轻量 UI 片段函数，四个按钮长得一样、只有文字不同，抽出来复用
  @Builder
  tabBarBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(CommonConstants.FONT_BODY)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index
          ? CommonConstants.COLOR_PRIMARY
          : CommonConstants.COLOR_TEXT_HINT)
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    // NavDestination：本页作为"栈里的一个页面"的根节点（Navigation 体系的要求）
    NavDestination() {
      // barPosition: End —— 导航栏放底部；
      // scrollable(false) —— 禁止左右滑动切换 Tab，避免和页面内部的横向手势打架
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          HomeView()
        }
        .tabBar(this.tabBarBuilder('首页', 0))

        TabContent() {
          LightView()
        }
        .tabBar(this.tabBarBuilder('灯光', 1))

        TabContent() {
          CurtainView()
        }
        .tabBar(this.tabBarBuilder('窗帘', 2))

        TabContent() {
          ServiceView()
        }
        .tabBar(this.tabBarBuilder('服务', 3))
      }
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }
}
