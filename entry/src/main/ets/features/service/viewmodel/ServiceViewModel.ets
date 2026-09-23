// 服务 ViewModel：请勿打扰 / 清理房间开关（首页快捷服务与服务页共享）
//
// 按脚手架约定，跨页状态由 ViewModel 单例承载；服务页（第 6 步）再补 SOS 与退出登录。
import { BaseViewModel } from '../../../common/base/BaseViewModel'
import { Logger } from '../../../common/log/Logger'

@ObservedV2
export class ServiceViewModel extends BaseViewModel {
  private static instance?: ServiceViewModel

  static getInstance(): ServiceViewModel {
    if (!ServiceViewModel.instance) {
      ServiceViewModel.instance = new ServiceViewModel()
    }
    return ServiceViewModel.instance
  }

  @Trace doNotDisturb: boolean = false   // 请勿打扰
  @Trace cleanRoom: boolean = false      // 清理房间

  constructor() {
    super()
    this.logger = new Logger('[ServiceViewModel]')
  }

  /**
   * 切换"请勿打扰"，返回切换后的状态（便于界面给出即时提示）
   */
  toggleDoNotDisturb(): boolean {
    this.doNotDisturb = !this.doNotDisturb
    this.logger.info(`请勿打扰：${this.doNotDisturb}`)
    return this.doNotDisturb
  }

  /**
   * 切换"清理房间"，返回切换后的状态
   */
  toggleCleanRoom(): boolean {
    this.cleanRoom = !this.cleanRoom
    this.logger.info(`清理房间：${this.cleanRoom}`)
    return this.cleanRoom
  }
}
