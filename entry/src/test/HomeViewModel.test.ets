// 首页 ViewModel 单元测试：空调开关 + 设定温度夹取边界
import { describe, it, expect } from '@ohos/hypium'
import { HomeViewModel } from '../main/ets/features/home/viewmodel/HomeViewModel'

export default function homeViewModelTest() {
  describe('homeViewModelTest', () => {
    // 常规：默认状态与设计稿一致（设定 22 / 当前 20 / 开机运行）
    it('should_have_design_defaults', 0, () => {
      const vm = new HomeViewModel()
      expect(vm.acOn).assertTrue()
      expect(vm.currentTemp).assertEqual(20)
      expect(vm.targetTemp).assertEqual(22)
    })

    // 常规：加/减各一次 → 每次 ±1
    it('should_step_temp_by_one', 0, () => {
      const vm = new HomeViewModel()
      vm.increaseTemp()
      expect(vm.targetTemp).assertEqual(23)
      vm.decreaseTemp()
      expect(vm.targetTemp).assertEqual(22)
    })

    // 边界：下限 16 连减到底不越界（临界值两侧都踩）
    it('should_clamp_at_min_temp', 0, () => {
      const vm = new HomeViewModel()
      for (let i = 0; i < 20; i++) {
        vm.decreaseTemp()
      }
      expect(vm.targetTemp).assertEqual(HomeViewModel.TEMP_MIN)
      expect(vm.targetTemp).assertEqual(16)
    })

    // 边界：上限 30 连加到底不越界
    it('should_clamp_at_max_temp', 0, () => {
      const vm = new HomeViewModel()
      for (let i = 0; i < 20; i++) {
        vm.increaseTemp()
      }
      expect(vm.targetTemp).assertEqual(HomeViewModel.TEMP_MAX)
      expect(vm.targetTemp).assertEqual(30)
    })

    // 隐含约定：开关每调用一次恰好翻转一次
    it('should_toggle_ac_once_per_call', 0, () => {
      const vm = new HomeViewModel()
      vm.toggleAc()
      expect(vm.acOn).assertFalse()
      vm.toggleAc()
      expect(vm.acOn).assertTrue()
    })
  })
}
