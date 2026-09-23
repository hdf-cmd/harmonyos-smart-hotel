// 智慧酒店 应用唯一入口（全应用只有一个 @Entry）
//
// 【三级导航 · 第一级】根栈 RootDomain，只负责三件事：
//   1) 创建根栈 pageStack，用 @Provider 递到组件树下方（任意层级 @Consumer 都能取到）
//   2) 注册根路由：登录页 + 主壳（本项目暂无沉浸式详情页）
//   3) 首屏放内容（栈空时显示的东西）
import { RouteConstants } from '../common/constants/RouteConstants'
import { MainPage } from './MainPage'
import { LoginPage } from '../features/login/view/LoginPage'

@Entry
@ComponentV2
struct AppNavigation {
  // 一级导航：根栈。@Provider 提供给全局，任意层级用 @Consumer('pageStack') 直接消费
  @Provider('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 根路由注册：name 全部取自 RouteConstants，写错一个字母编译期就报错
  @Builder
  RootRouter(name: string, param: Object) {
    if (name === RouteConstants.MAIN) {
      MainPage()
    } else if (name === RouteConstants.LOGIN) {
      LoginPage()
    }
  }

  build() {
    // Navigation 的内容区（首屏）：栈空时显示它。
    // 登录成功后用 replacePathByName 换成 MainPage，让登录页不进返回历史。
    Navigation(this.pageStack) {
      LoginPage()
    }
    .mode(NavigationMode.Stack)
    .navDestination(this.RootRouter)
    .hideTitleBar(true)
  }
}
