// 灯光 ViewModel：场景模式状态 + 9 路独立灯 + 总开关推导（首页与灯光页共享单例）
//
// 【状态设计】9 路灯各自一个 @Trace 布尔（单字段最利于观察刷新与单测）；
// 总开关不是存储位而是"推导值"：任一路亮 = 总开关亮；点总开关 → 全开/全关一键切换。
// 场景 → 灯组的映射是本项目自定的合理预设（题图只给了 UI，没给映射规则）。
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

  // 9 路灯的键（View 的名称/图标映射与单测都用它，避免魔法字符串散落）
  static readonly LIGHT_WASHROOM: string = '洗漱间'
  static readonly LIGHT_WARDROBE: string = '衣柜灯'
  static readonly LIGHT_FLOOR: string = '落地灯'
  static readonly LIGHT_BAR: string = '吧灯'
  static readonly LIGHT_DESK: string = '书桌灯'
  static readonly LIGHT_READ_RIGHT: string = '右阅读灯'
  static readonly LIGHT_READ_LEFT: string = '左阅读灯'
  static readonly LIGHT_FAN: string = '排风扇'
  static readonly LIGHT_CORRIDOR: string = '廊灯'

  // 当前场景（首页与灯光页共享）
  @Trace activeScene: string = LightViewModel.SCENE_BRIGHT

  // 9 路开关状态（初值与设计稿截图一致）
  @Trace washroomOn: boolean = true      // 洗漱间
  @Trace wardrobeOn: boolean = true      // 衣柜灯
  @Trace floorLampOn: boolean = true     // 落地灯
  @Trace barLampOn: boolean = true       // 吧灯
  @Trace deskLampOn: boolean = false     // 书桌灯
  @Trace rightReadOn: boolean = true     // 右阅读灯
  @Trace leftReadOn: boolean = false     // 左阅读灯
  @Trace fanOn: boolean = true           // 排风扇
  @Trace corridorOn: boolean = true      // 廊灯

  constructor() {
    super()
    this.logger = new Logger('[LightViewModel]')
  }

  /**
   * 总开关（推导值）：任意一路亮 = 开
   */
  get masterOn(): boolean {
    return this.washroomOn || this.wardrobeOn || this.floorLampOn || this.barLampOn ||
      this.deskLampOn || this.rightReadOn || this.leftReadOn || this.fanOn || this.corridorOn
  }

  /**
   * 九路是否全部点亮
   */
  get allLightsOn(): boolean {
    return this.washroomOn && this.wardrobeOn && this.floorLampOn && this.barLampOn &&
      this.deskLampOn && this.rightReadOn && this.leftReadOn && this.fanOn && this.corridorOn
  }

  /**
   * 点总开关：全部亮着 → 全关；否则 → 全开（一键全控）
   */
  toggleMaster(): boolean {
    this.setAllLights(!this.allLightsOn)
    this.logger.info(`总开关：${this.masterOn ? '全开' : '全关'}`)
    return this.masterOn
  }

  /**
   * 查询某一路灯的状态（View 在 @Builder 内部读取本方法，
   * 保证状态依赖发生在 Builder 内部，避免按值传参不刷新的坑）
   */
  isLightOn(key: string): boolean {
    if (key === LightViewModel.LIGHT_WASHROOM) {
      return this.washroomOn
    }
    if (key === LightViewModel.LIGHT_WARDROBE) {
      return this.wardrobeOn
    }
    if (key === LightViewModel.LIGHT_FLOOR) {
      return this.floorLampOn
    }
    if (key === LightViewModel.LIGHT_BAR) {
      return this.barLampOn
    }
    if (key === LightViewModel.LIGHT_DESK) {
      return this.deskLampOn
    }
    if (key === LightViewModel.LIGHT_READ_RIGHT) {
      return this.rightReadOn
    }
    if (key === LightViewModel.LIGHT_READ_LEFT) {
      return this.leftReadOn
    }
    if (key === LightViewModel.LIGHT_FAN) {
      return this.fanOn
    }
    if (key === LightViewModel.LIGHT_CORRIDOR) {
      return this.corridorOn
    }
    return false
  }

  /**
   * 切换某一路灯，返回切换后的状态（供界面即时提示）
   */
  toggleLight(key: string): boolean {
    if (key === LightViewModel.LIGHT_WASHROOM) {
      this.washroomOn = !this.washroomOn
      return this.washroomOn
    }
    if (key === LightViewModel.LIGHT_WARDROBE) {
      this.wardrobeOn = !this.wardrobeOn
      return this.wardrobeOn
    }
    if (key === LightViewModel.LIGHT_FLOOR) {
      this.floorLampOn = !this.floorLampOn
      return this.floorLampOn
    }
    if (key === LightViewModel.LIGHT_BAR) {
      this.barLampOn = !this.barLampOn
      return this.barLampOn
    }
    if (key === LightViewModel.LIGHT_DESK) {
      this.deskLampOn = !this.deskLampOn
      return this.deskLampOn
    }
    if (key === LightViewModel.LIGHT_READ_RIGHT) {
      this.rightReadOn = !this.rightReadOn
      return this.rightReadOn
    }
    if (key === LightViewModel.LIGHT_READ_LEFT) {
      this.leftReadOn = !this.leftReadOn
      return this.leftReadOn
    }
    if (key === LightViewModel.LIGHT_FAN) {
      this.fanOn = !this.fanOn
      return this.fanOn
    }
    if (key === LightViewModel.LIGHT_CORRIDOR) {
      this.corridorOn = !this.corridorOn
      return this.corridorOn
    }
    return false
  }

  /**
   * 切换场景模式：同步场景高亮 + 按预设改写 9 路灯
   */
  applyScene(scene: string): void {
    this.activeScene = scene
    if (scene === LightViewModel.SCENE_BRIGHT) {
      this.setAllLights(true)                       // 明亮：全开
    } else if (scene === LightViewModel.SCENE_SOFT) {
      this.setAllLights(false)
      this.floorLampOn = true                       // 柔和：落地灯 + 廊灯
      this.corridorOn = true
    } else if (scene === LightViewModel.SCENE_READ) {
      this.setAllLights(false)
      this.deskLampOn = true                        // 阅读：书桌灯 + 左右阅读灯
      this.rightReadOn = true
      this.leftReadOn = true
    } else if (scene === LightViewModel.SCENE_WARM) {
      this.setAllLights(false)
      this.floorLampOn = true                       // 温馨：落地灯 + 吧灯 + 廊灯
      this.barLampOn = true
      this.corridorOn = true
    } else if (scene === LightViewModel.SCENE_SLEEP) {
      this.setAllLights(false)                      // 睡眠：全关
    }
    this.logger.info(`切换场景：${scene}`)
  }

  /**
   * 晚安模式：一键关闭所有灯光（等价睡眠场景）
   */
  turnAllOff(): void {
    this.applyScene(LightViewModel.SCENE_SLEEP)
  }

  /**
   * 九路统一置位
   */
  private setAllLights(on: boolean): void {
    this.washroomOn = on
    this.wardrobeOn = on
    this.floorLampOn = on
    this.barLampOn = on
    this.deskLampOn = on
    this.rightReadOn = on
    this.leftReadOn = on
    this.fanOn = on
    this.corridorOn = on
  }
}
