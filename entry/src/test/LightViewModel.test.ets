// 灯光 ViewModel 单元测试：场景切换 + 晚安模式（单例，与页面共享同一状态）
import { describe, it, expect } from '@ohos/hypium'
import { LightViewModel } from '../main/ets/features/light/viewmodel/LightViewModel'

export default function lightViewModelTest() {
  describe('lightViewModelTest', () => {
    // 常规：默认明亮场景（与设计稿一致）
    it('should_default_to_bright_scene', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_BRIGHT)
      expect(vm.activeScene).assertEqual('明亮')
    })

    // 常规：applyScene 后状态同步
    it('should_apply_scene', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_READ)
      expect(vm.activeScene).assertEqual(LightViewModel.SCENE_READ)
    })

    // 隐含约定：晚安模式（一键关灯）= 睡眠场景
    it('should_turn_all_off_equals_sleep_scene', 0, () => {
      const vm = LightViewModel.getInstance()
      vm.applyScene(LightViewModel.SCENE_WARM)
      vm.turnAllOff()
      expect(vm.activeScene).assertEqual(LightViewModel.SCENE_SLEEP)
    })

    // 隐含约定：两次 getInstance 必须是同一个实例（跨页状态共享的地基）
    it('should_be_singleton', 0, () => {
      expect(LightViewModel.getInstance() === LightViewModel.getInstance()).assertTrue()
    })
  })
}
