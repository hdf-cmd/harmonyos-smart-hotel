// 首页 ViewModel：空调卡片状态与调整逻辑，零 UI
import { BaseViewModel } from '../../../common/base/BaseViewModel'
import { Logger } from '../../../common/log/Logger'

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  // 设定温度的上下限（单测覆盖夹取逻辑）
  static readonly TEMP_MIN: number = 16
  static readonly TEMP_MAX: number = 30

  @Trace acOn: boolean = true        // 空调开关（运行中 / 已关闭）
  @Trace currentTemp: number = 20    // 当前温度（展示值）
  @Trace targetTemp: number = 22     // 设定温度（可用加减调节）

  constructor() {
    super()
    this.logger = new Logger('[HomeViewModel]')
  }

  /**
   * 空调电源开关
   */
  toggleAc(): void {
    this.acOn = !this.acOn
    this.logger.info(`空调${this.acOn ? '开启' : '关闭'}`)
  }

  /**
   * 调高设定温度（上限 30）
   */
  increaseTemp(): void {
    this.targetTemp = Math.min(HomeViewModel.TEMP_MAX, this.targetTemp + 1)
  }

  /**
   * 调低设定温度（下限 16）
   */
  decreaseTemp(): void {
    this.targetTemp = Math.max(HomeViewModel.TEMP_MIN, this.targetTemp - 1)
  }
}
