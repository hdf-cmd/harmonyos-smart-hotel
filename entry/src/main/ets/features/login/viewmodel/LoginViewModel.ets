// 登录（入住）ViewModel：业务逻辑与状态管理，零 UI
//
// 【为什么是单例】房号/用户名进主界面后还要被首页读取（"欢迎回家，房号 2002"）。
// 按脚手架约定，跨模块取数据只走 ViewModel 实例，页面之间不互相直连。
import { common } from '@kit.AbilityKit'
import { BaseViewModel } from '../../../common/base/BaseViewModel'
import { Result } from '../../../common/base/Result'
import { Logger } from '../../../common/log/Logger'
import { ValidationUtil } from '../../../common/utils/ValidationUtil'
import { LoginInfo } from '../model/LoginInfo'
import { RememberMeStore } from './RememberMeStore'

@ObservedV2
export class LoginViewModel extends BaseViewModel {
  private static instance?: LoginViewModel

  static getInstance(): LoginViewModel {
    if (!LoginViewModel.instance) {
      LoginViewModel.instance = new LoginViewModel()
    }
    return LoginViewModel.instance
  }

  // 表单字段（@Trace：变更自动刷新 View）
  // 首次启动的预填值与设计稿一致；"记住我的信息"会覆盖它
  @Trace roomNo: string = '2002'
  @Trace userName: string = 'xiao'
  @Trace rememberMe: boolean = true

  // 持久化存储（构造时可注入替身，便于单测）
  private store: RememberMeStore = new RememberMeStore()

  constructor(store?: RememberMeStore) {
    super()
    if (store) {
      this.store = store
    }
    this.logger = new Logger('[LoginViewModel]')
  }

  /**
   * 提交入住：房号、用户名依次校验，全部通过才算成功
   */
  submit(): Result<LoginInfo> {
    this.clearError()

    const roomValidation = ValidationUtil.validateRoomNo(this.roomNo)
    if (!roomValidation.isValid) {
      const msg = roomValidation.message ?? '房号不合法'
      this.setError(msg)
      return Result.fail(-1, msg)
    }

    const nameValidation = ValidationUtil.validateUsername(this.userName)
    if (!nameValidation.isValid) {
      const msg = nameValidation.message ?? '用户名不合法'
      this.setError(msg)
      return Result.fail(-1, msg)
    }

    const info = new LoginInfo()
    info.roomNo = this.roomNo
    info.userName = this.userName
    info.rememberMe = this.rememberMe
    this.logger.info(`入住成功：房号 ${info.roomNo}，用户 ${info.userName}`)
    return Result.ok(info)
  }

  /**
   * 恢复"记住我的信息"：有历史记录就回填；首次启动保持预填值
   */
  async restore(context: common.Context): Promise<void> {
    try {
      const saved = await this.store.load(context)
      if (saved) {
        this.roomNo = saved.roomNo
        this.userName = saved.userName
        this.rememberMe = saved.rememberMe
      }
    } catch (e) {
      this.logger.error(`恢复记住信息失败：${e}`)
    }
  }

  /**
   * 入住成功后落盘：勾选=保存当前值，未勾选=保存空值（下次打开就是空的）
   */
  async persistLoginState(context: common.Context): Promise<void> {
    try {
      const info = new LoginInfo()
      info.rememberMe = this.rememberMe
      if (this.rememberMe) {
        info.roomNo = this.roomNo
        info.userName = this.userName
      }
      await this.store.save(context, info)
    } catch (e) {
      this.logger.error(`保存记住信息失败：${e}`)
    }
  }
}
