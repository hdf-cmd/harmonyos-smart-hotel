// 服务 ViewModel 单元测试：请勿打扰 / 清理房间开关（单例）
import { describe, it, expect } from '@ohos/hypium'
import { ServiceViewModel } from '../main/ets/features/service/viewmodel/ServiceViewModel'

export default function serviceViewModelTest() {
  describe('serviceViewModelTest', () => {
    // 常规：调用后翻转，且返回值与状态一致（返回值供界面 toast 使用）
    it('should_toggle_dnd_and_return_new_state', 0, () => {
      const vm = ServiceViewModel.getInstance()
      const before = vm.doNotDisturb
      const after = vm.toggleDoNotDisturb()
      expect(after).assertEqual(!before)
      expect(vm.doNotDisturb).assertEqual(after)
      vm.toggleDoNotDisturb()   // 还原
    })

    // 常规：两个开关互不干扰
    it('should_keep_two_switches_independent', 0, () => {
      const vm = ServiceViewModel.getInstance()
      vm.doNotDisturb = false
      vm.cleanRoom = false
      vm.toggleCleanRoom()
      expect(vm.cleanRoom).assertTrue()
      expect(vm.doNotDisturb).assertFalse()
      vm.toggleCleanRoom()      // 还原
    })

    // 隐含约定：两次 getInstance 必须是同一个实例
    it('should_be_singleton', 0, () => {
      expect(ServiceViewModel.getInstance() === ServiceViewModel.getInstance()).assertTrue()
    })
  })
}
