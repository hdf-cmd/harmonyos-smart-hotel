// 灯光 ViewModel 单元测试：默认态 / 场景映射 / 总开关推导 / 单路切换
//
// 注意：LightViewModel 是单例，用例之间共享实例——每个用例自己先把状态置到起点再断言。
import { describe, it, expect } from '@ohos/hypium'
import { LightViewModel } from '../main/ets/features/light/viewmodel/LightViewModel'

export default function lightViewModelTest() {
  describe('lightViewModelTest', () => {
    // 常规：默认状态与设计稿一致（7 亮 2 灭的混合态）
    it('should_have_design_default_mixed_state', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.washroomOn = true
      vm.wardrobeOn = true
      vm.floorLampOn = true
      vm.barLampOn = true
      vm.deskLampOn = false
      vm.rightReadOn = true
      vm.leftReadOn = false
      vm.fanOn = true
      vm.corridorOn = true

      expect(vm.masterOn).assertTrue()        // 有灯亮 → 总开关亮
      expect(vm.allLightsOn).assertFalse()    // 但并非全亮
    })

    // 常规：单路切换 + isLightOn 查询一致（返回值供界面提示用）
    it('should_toggle_single_light', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.deskLampOn = false

      const nowOn = vm.toggleLight(LightViewModel.LIGHT_DESK)
      expect(nowOn).assertTrue()
      expect(vm.isLightOn(LightViewModel.LIGHT_DESK)).assertTrue()

      const nowOff = vm.toggleLight(LightViewModel.LIGHT_DESK)
      expect(nowOff).assertFalse()
      expect(vm.isLightOn(LightViewModel.LIGHT_DESK)).assertFalse()
    })

    // 边界：未知灯名查询/切换不报错、返回 false
    it('should_ignore_unknown_light_key', 0, () => {
      const vm = LightViewModel.getInstance()
      expect(vm.isLightOn('不存在的灯')).assertFalse()
      expect(vm.toggleLight('不存在的灯')).assertFalse()
    })

    // 场景映射：明亮 = 全开
    it('should_apply_bright_scene_all_on', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_BRIGHT)
      expect(vm.activeScene).assertEqual('明亮')
      expect(vm.allLightsOn).assertTrue()
      expect(vm.masterOn).assertTrue()
    })

    // 场景映射：阅读 = 书桌 + 左右阅读，其余全灭
    it('should_apply_read_scene_group', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_READ)
      expect(vm.activeScene).assertEqual('阅读')
      expect(vm.deskLampOn).assertTrue()
      expect(vm.rightReadOn).assertTrue()
      expect(vm.leftReadOn).assertTrue()
      expect(vm.washroomOn).assertFalse()
      expect(vm.corridorOn).assertFalse()
      expect(vm.fanOn).assertFalse()
    })

    // 场景映射：柔和 = 落地灯 + 廊灯
    it('should_apply_soft_scene_group', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_SOFT)
      expect(vm.floorLampOn).assertTrue()
      expect(vm.corridorOn).assertTrue()
      expect(vm.barLampOn).assertFalse()
      expect(vm.allLightsOn).assertFalse()
    })

    // 场景映射：温馨 = 落地灯 + 吧灯 + 廊灯
    it('should_apply_warm_scene_group', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_WARM)
      expect(vm.floorLampOn).assertTrue()
      expect(vm.barLampOn).assertTrue()
      expect(vm.corridorOn).assertTrue()
      expect(vm.deskLampOn).assertFalse()
    })

    // 隐含约定：睡眠 = 全关；晚安模式等价于睡眠
    it('should_apply_sleep_scene_all_off', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_WARM)
      vm.turnAllOff()
      expect(vm.activeScene).assertEqual(LightViewModel.SCENE_SLEEP)
      expect(vm.masterOn).assertFalse()
      expect(vm.allLightsOn).assertFalse()
    })

    // 总开关：非全开 → 一键全开；全开 → 一键全关
    it('should_master_toggle_all_on_then_all_off', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_READ)   // 混合态

      const first = vm.toggleMaster()
      expect(first).assertTrue()
      expect(vm.allLightsOn).assertTrue()

      const second = vm.toggleMaster()
      expect(second).assertFalse()
      expect(vm.masterOn).assertFalse()
    })

    // 隐含约定：两次 getInstance 必须是同一个实例（跨页共享的地基）
    it('should_be_singleton', 0, () => {
      expect(LightViewModel.getInstance() === LightViewModel.getInstance()).assertTrue()
    })
  })
}
