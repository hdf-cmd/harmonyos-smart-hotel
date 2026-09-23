// 窗帘 ViewModel：布帘 / 窗纱三态（打开/暂停/关闭）+ 全局开关联动
//
// 【为什么"位置"是 0~1 的进度而不是布尔】"暂停"要能停在半途——
// state 管按钮高亮与目标方向；pos（0=全开 → 1=全关）由 View 的 Animator 逐帧写回，
// 暂停时动画停住、pos 就保留在半途；再点打开/关闭按剩余距离续跑。
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
  @Trace curtainPos: number = 0              // 视觉位置：0=全开 → 1=全关（暂停可停中间值）
  // 窗纱
  @Trace screenState: string = CurtainViewModel.STATE_OPEN
  @Trace screenPos: number = 0

  constructor() {
    super()
    this.logger = new Logger('[CurtainViewModel]')
  }

  /**
   * 设置布帘三态：只改状态标签；视觉位置由 View 的开合动画驱动（暂停=停住动画、位置保留半途）
   */
  setCurtain(state: string): void {
    this.curtainState = state
    this.logger.info(`布帘：${state}（当前位置 ${this.curtainPos.toFixed(2)}）`)
  }

  /**
   * 设置窗纱三态
   */
  setScreening(state: string): void {
    this.screenState = state
    this.logger.info(`窗纱：${state}（当前位置 ${this.screenPos.toFixed(2)}）`)
  }

  /**
   * 动画逐帧写入口：布帘位置（夹取到 0~1，防止动画越界）
   */
  applyCurtainPos(pos: number): void {
    this.curtainPos = Math.max(0, Math.min(1, pos))
  }

  /**
   * 动画逐帧写入口：窗纱位置
   */
  applyScreenPos(pos: number): void {
    this.screenPos = Math.max(0, Math.min(1, pos))
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
