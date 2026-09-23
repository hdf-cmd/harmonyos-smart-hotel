// 窗帘 ViewModel：布帘 / 窗纱三态（打开/暂停/关闭）+ 全局开关联动
//
// 【视觉位置为什么要单独一个字段】"暂停"表示停在当前位置——
// 所以三态 state 只管按钮高亮，视觉位置 closed 只在按开/关时改变。
import { BaseViewModel } from '../../../common/base/BaseViewModel'
import { Logger } from '../../../common/log/Logger'

@ObservedV2
export class CurtainViewModel extends BaseViewModel {
  private static instance?: CurtainViewModel

  static getInstance(): CurtainViewModel {
    if (!CurtainViewModel.instance) {
      CurtainViewModel.instance = new CurtainViewModel()
    }
    return CurtainViewModel.instance
  }

  // 三态常量
  static readonly STATE_OPEN: string = 'open'
  static readonly STATE_PAUSE: string = 'pause'
  static readonly STATE_CLOSE: string = 'close'

  // 布帘
  @Trace curtainState: string = CurtainViewModel.STATE_OPEN
  @Trace curtainClosed: boolean = false      // 布帘视觉位置（false=展开）
  // 窗纱
  @Trace screenState: string = CurtainViewModel.STATE_OPEN
  @Trace screenClosed: boolean = false       // 窗纱视觉位置

  constructor() {
    super()
    this.logger = new Logger('[CurtainViewModel]')
  }

  /**
   * 设置布帘三态（打开/关闭同时更新视觉位置，暂停保持原位）
   */
  setCurtain(state: string): void {
    this.curtainState = state
    if (state === CurtainViewModel.STATE_OPEN) {
      this.curtainClosed = false
    } else if (state === CurtainViewModel.STATE_CLOSE) {
      this.curtainClosed = true
    }
    this.logger.info(`布帘：${state}`)
  }

  /**
   * 设置窗纱三态
   */
  setScreening(state: string): void {
    this.screenState = state
    if (state === CurtainViewModel.STATE_OPEN) {
      this.screenClosed = false
    } else if (state === CurtainViewModel.STATE_CLOSE) {
      this.screenClosed = true
    }
    this.logger.info(`窗纱：${state}`)
  }

  /**
   * 全局：全部打开
   */
  openAll(): void {
    this.setCurtain(CurtainViewModel.STATE_OPEN)
    this.setScreening(CurtainViewModel.STATE_OPEN)
  }

  /**
   * 全局：全部关闭
   */
  closeAll(): void {
    this.setCurtain(CurtainViewModel.STATE_CLOSE)
    this.setScreening(CurtainViewModel.STATE_CLOSE)
  }

  /**
   * 全局状态：都打开
   */
  get allOpen(): boolean {
    return this.curtainState === CurtainViewModel.STATE_OPEN &&
      this.screenState === CurtainViewModel.STATE_OPEN
  }

  /**
   * 全局状态：都关闭
   */
  get allClosed(): boolean {
    return this.curtainState === CurtainViewModel.STATE_CLOSE &&
      this.screenState === CurtainViewModel.STATE_CLOSE
  }
}
