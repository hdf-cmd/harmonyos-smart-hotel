// ViewModel 基类：统一的 loading / error 状态管理
//
// 【为什么用 @ObservedV2 + @Trace】普通 class 的属性变化 View 是感知不到的。
// 加了 @ObservedV2 类装饰器后，类里标了 @Trace 的字段一旦变更，
// 就会通知引用了它实例的 View 重绘——这就是"ViewModel 改状态 → 界面自动刷新"的实现基础。
import { Logger } from '../log/Logger'

@ObservedV2
export abstract class BaseViewModel {
  // 页面加载态（View 可据此禁用按钮、显示"请稍候..."）
  @Trace loading: boolean = false

  // 可展示的错误信息（怎么渲染由 View 决定，ViewModel 不关心）
  @Trace errorMessage: string = ''

  // 子类可覆盖 tag，便于在日志里区分是哪个模块打的
  protected logger: Logger = new Logger('[ViewModel]')

  protected setLoading(v: boolean): void {
    this.loading = v
  }

  protected setError(msg: string): void {
    this.errorMessage = msg
  }

  protected clearError(): void {
    this.errorMessage = ''
  }
}
