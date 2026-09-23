// 主页面（TabDomain）：只负责 Tab 装配 + 悬浮图文 TabBar
//
// 【三级导航 · 第二级】每个 Tab 对应的 View 自己持 Navigation + 子栈 + 域内路由，
// 所以这一层保持"傻"——只干装配，不加逻辑。
import { CommonConstants } from '../common/constants/CommonConstants'
import { MainTabModel } from '../common/model/MainTabModel'
import { HomeView } from '../features/home/view/HomeView'
import { LightView } from '../features/light/view/LightView'
import { CurtainView } from '../features/curtain/view/CurtainView'
import { ServiceView } from '../features/service/view/ServiceView'

// 四个 Tab 的矢量图标（72 px 视口 = 24 vp @3x，Path 命令单位是 px；实心图形）
const ICON_HOME: string =
  'M36 7.2 L66 32.4 L58.8 32.4 L58.8 64.8 L13.2 64.8 L13.2 32.4 L6 32.4 Z'
const ICON_LAMP: string =
  'M32.7 7.8 L39.3 7.8 L39.3 15.6 L32.7 15.6 Z M25.2 22.8 L46.8 22.8 L55.2 45.6 L16.8 45.6 Z ' +
  'M32.7 49.8 L39.3 49.8 L39.3 61.2 L32.7 61.2 Z M24.6 50.4 L28.8 48.6 L23.7 59.7 L19.5 61.5 Z ' +
  'M47.4 50.4 L43.2 48.6 L48.3 59.7 L52.5 61.5 Z'
const ICON_WINDOW: string =
  'M13.8 9.6 L58.2 9.6 L58.2 15.6 L13.8 15.6 Z M13.8 56.4 L58.2 56.4 L58.2 62.4 L13.8 62.4 Z ' +
  'M16.8 11.4 L22.8 11.4 L22.8 60.6 L16.8 60.6 Z M33 11.4 L39 11.4 L39 60.6 L33 60.6 Z ' +
  'M49.2 11.4 L55.2 11.4 L55.2 60.6 L49.2 60.6 Z'
const ICON_BELL: string =
  'M36 12.9 A3.9 3.9 0 1 0 36 20.7 A3.9 3.9 0 1 0 36 12.9 Z M34.2 19.2 L37.8 19.2 L37.8 31.8 L34.2 31.8 Z ' +
  'M18 49.8 A18.6 18.6 0 0 1 54 49.8 Z M13.8 55.8 L58.2 55.8 L58.2 60.6 L13.8 60.6 Z'

@ComponentV2
export struct MainPage {
  // Tab 下标状态源（跨页共享单例：灯光/窗帘/服务页的"返回"要切回首页）
  @Local tabModel: MainTabModel = MainTabModel.getInstance()

  // Tab 内容容器控制器（自绘悬浮栏通过它切换页签）
  private tabsController: TabsController = new TabsController()

  // 任何地方改了 tabModel.index（含子页面"返回"），统一在这里驱动 Tabs 切换
  @Monitor('tabModel.index')
  onTabIndexChange(): void {
    this.tabsController.changeIndex(this.tabModel.index)
  }

  @Builder
  tabItem(label: string, index: number, iconCommands: string) {
    Column({ space: 3 }) {
      Path()
        .commands(iconCommands)
        .width(24)
        .height(24)
        .fill(Color.White)
        .strokeWidth(0)
        .opacity(this.tabModel.index === index ? 1.0 : 0.72)
        .antiAlias(true)

      Text(label)
        .fontSize(10)
        .fontColor(this.tabModel.index === index ? Color.White : CommonConstants.COLOR_TAB_INACTIVE)
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .borderRadius(24)
    .backgroundColor(this.tabModel.index === index
      ? CommonConstants.COLOR_TAB_SELECTED_BG
      : Color.Transparent)
    .onClick(() => {
      this.tabModel.index = index
    })
  }

  build() {
    // NavDestination：本页作为"栈里的一个页面"的根节点（Navigation 体系的要求）
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        // 全屏沉浸背景：提到 Tabs 之外（TabContent 会裁掉子组件的安全区扩展），
        // 让背景铺进状态栏/导航条区域，四个 Tab 页共用这一层
        Image($r('app.media.page_background'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 系统 TabBar 高度置 0（隐藏），页签切换只由下方自绘悬浮栏驱动
        Tabs({ barPosition: BarPosition.End, index: this.tabModel.index, controller: this.tabsController }) {
          TabContent() {
            HomeView()
          }

          TabContent() {
            LightView()
          }

          TabContent() {
            CurtainView()
          }

          TabContent() {
            ServiceView()
          }
        }
        .barHeight(0)
        .scrollable(false)
        .animationDuration(0)
        .onChange((index: number) => {
          this.tabModel.index = index
        })
        .width('100%')
        .height('100%')

        // 悬浮圆角栏（深色半透明 + 选中金色胶囊）
        Row() {
          Row() {
            this.tabItem('首页', 0, ICON_HOME)
            this.tabItem('灯光', 1, ICON_LAMP)
            this.tabItem('窗帘', 2, ICON_WINDOW)
            this.tabItem('服务', 3, ICON_BELL)
          }
          .width('100%')
          .height(CommonConstants.TAB_BAR_HEIGHT)
          .backgroundColor(CommonConstants.COLOR_TAB_BAR_BG)
          .borderRadius(CommonConstants.TAB_BAR_HEIGHT / 2)
          .justifyContent(FlexAlign.SpaceEvenly)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .padding({
          left: CommonConstants.PAGE_SIDE_PADDING,
          right: CommonConstants.PAGE_SIDE_PADDING,
          bottom: 14
        })
      }
    }
    .hideTitleBar(true)
  }
}
