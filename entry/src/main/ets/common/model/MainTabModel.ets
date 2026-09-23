// 主壳 Tab 状态（跨 feature 共享）：让灯光/窗帘/服务页的"← 返回"能切回首页 Tab
//
// 【为什么要一个共享模型】Tab 下标本来只在 MainPage 里 (@Local)，但子页面也要改它——
// 按脚手架约定"被两个以上 feature 用 → 上提到 common"，所以收敛到这里做单例。
@ObservedV2
export class MainTabModel {
  private static instance?: MainTabModel

  static getInstance(): MainTabModel {
    if (!MainTabModel.instance) {
      MainTabModel.instance = new MainTabModel()
    }
    return MainTabModel.instance
  }

  // Tab 下标：0=首页 1=灯光 2=窗帘 3=服务
  static readonly TAB_HOME: number = 0
  static readonly TAB_LIGHT: number = 1
  static readonly TAB_CURTAIN: number = 2
  static readonly TAB_SERVICE: number = 3

  @Trace index: number = MainTabModel.TAB_HOME
}
