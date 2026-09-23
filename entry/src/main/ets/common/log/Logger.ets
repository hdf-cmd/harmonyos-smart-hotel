// 轻量日志封装：业务代码不直接依赖 hilog 细节
//
// 【为什么要包一层】将来换日志方案（加文件落盘、上报、脱敏）只改这里，业务代码零改动。
// 另外本地单元测试环境不一定有完整的系统 API，包一层后也方便降级处理。
import { hilog } from '@kit.PerformanceAnalysisKit'

export class Logger {
  private static readonly DOMAIN: number = 0x0000
  private tag: string

  constructor(tag: string) {
    this.tag = tag
  }

  info(msg: string): void {
    hilog.info(Logger.DOMAIN, this.tag, '%{public}s', msg)
  }

  warn(msg: string): void {
    hilog.warn(Logger.DOMAIN, this.tag, '%{public}s', msg)
  }

  error(msg: string): void {
    hilog.error(Logger.DOMAIN, this.tag, '%{public}s', msg)
  }
}
