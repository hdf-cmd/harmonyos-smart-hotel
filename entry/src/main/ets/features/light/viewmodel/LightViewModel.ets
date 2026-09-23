// 灯光 ViewModel：场景模式状态（首页与灯光页共享）
//
// 【为什么第 3 步就有它】首页的"场景模式"和"晚安模式"操作的是灯光状态；
// 按脚手架约定，跨页状态由 ViewModel 单例承载，灯光页（第 4 步）再补全独立控制与总开关。
import { BaseViewModel } from '../../../common/base/BaseViewModel'
import { Logger } from '../../../common/log/Logger'

@ObservedV2
export class LightViewModel extends BaseViewModel {
  private static instance?: LightViewModel

  static getInstance(): LightViewModel {
    if (!LightViewModel.instance) {
      LightViewModel.instance = new LightViewModel()
    }
    return LightViewModel.instance
  }

  // 场景名常量（首页 4 项 + 灯光页多一个睡眠）
  static readonly SCENE_BRIGHT: string = '明亮'
  static readonly SCENE_SOFT: string = '柔和'
  static readonly SCENE_READ: string = '阅读'
  static readonly SCENE_WARM: string = '温馨'
  static readonly SCENE_SLEEP: string = '睡眠'

  @Trace activeScene: string = LightViewModel.SCENE_BRIGHT

  constructor() {
    super()
    this.logger = new Logger('[LightViewModel]')
  }

  /**
   * 切换场景模式（首页 4 项与灯光页共用同一状态）
   */
  applyScene(scene: string): void {
    this.activeScene = scene
    this.logger.info(`切换场景：${scene}`)
  }

  /**
   * 晚安模式：一键关闭所有灯光（等价于睡眠场景；第 4 步补全各路灯的开关联动）
   */
  turnAllOff(): void {
    this.applyScene(LightViewModel.SCENE_SLEEP)
  }
}
