// 窗帘 ViewModel 单元测试：三态语义（含暂停保持原位）/ 全局联动 / 聚合推导
//
// 注意：CurtainViewModel 是单例，用例之间共享实例——每个用例自己先把状态置到起点再断言。
import { describe, it, expect } from '@ohos/hypium'
import { CurtainViewModel } from '../main/ets/features/curtain/viewmodel/CurtainViewModel'

export default function curtainViewModelTest() {
  describe('curtainViewModelTest', () => {
    // 常规：默认双帘打开
    it('should_default_open', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.openAll()
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_OPEN)
      expect(vm.screenState).assertEqual(CurtainViewModel.STATE_OPEN)
      expect(vm.curtainClosed).assertFalse()
      expect(vm.screenClosed).assertFalse()
    })

    // 常规：关闭/打开会同时更新三态与视觉位置
    it('should_set_curtain_close_then_open', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.setCurtain(CurtainViewModel.STATE_CLOSE)
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_CLOSE)
      expect(vm.curtainClosed).assertTrue()

      vm.setCurtain(CurtainViewModel.STATE_OPEN)
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_OPEN)
      expect(vm.curtainClosed).assertFalse()
    })

    // 隐含约定（设计决定，必须守住）：暂停 = 停在当前位置，不改视觉位置
    it('should_pause_keep_position', 0, () => {
      const vm = CurtainViewModel.getInstance()

      // 关闭后暂停：仍是"已关"位置
      vm.setCurtain(CurtainViewModel.STATE_CLOSE)
      vm.setCurtain(CurtainViewModel.STATE_PAUSE)
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_PAUSE)
      expect(vm.curtainClosed).assertTrue()

      // 打开后暂停：仍是"已开"位置
      vm.setCurtain(CurtainViewModel.STATE_OPEN)
      vm.setCurtain(CurtainViewModel.STATE_PAUSE)
      expect(vm.curtainClosed).assertFalse()
      vm.setCurtain(CurtainViewModel.STATE_OPEN)   // 还原
    })

    // 常规：窗纱三态与视觉位置同步（与布帘互不干扰）
    it('should_set_screening_state_and_position', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.setScreening(CurtainViewModel.STATE_CLOSE)
      expect(vm.screenState).assertEqual(CurtainViewModel.STATE_CLOSE)
      expect(vm.screenClosed).assertTrue()
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_OPEN)   // 布帘不受影响

      vm.setScreening(CurtainViewModel.STATE_OPEN)
      expect(vm.screenClosed).assertFalse()
    })

    // 全局：全部打开 / 全部关闭 → 双帘同步
    it('should_open_all_and_close_all_both_curtains', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.closeAll()
      expect(vm.allClosed).assertTrue()
      expect(vm.curtainClosed).assertTrue()
      expect(vm.screenClosed).assertTrue()

      vm.openAll()
      expect(vm.allOpen).assertTrue()
      expect(vm.curtainClosed).assertFalse()
      expect(vm.screenClosed).assertFalse()
    })

    // 隐含约定：混合态下两个聚合判定都为 false（全局卡"都不高亮"的依据）
    it('should_report_mixed_state_as_neither', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.setCurtain(CurtainViewModel.STATE_CLOSE)
      vm.setScreening(CurtainViewModel.STATE_OPEN)
      expect(vm.allClosed).assertFalse()
      expect(vm.allOpen).assertFalse()
      vm.openAll()   // 还原
    })

    // 隐含约定：两次 getInstance 必须是同一个实例（跨页共享的地基）
    it('should_be_singleton', 0, () => {
      expect(CurtainViewModel.getInstance() === CurtainViewModel.getInstance()).assertTrue()
    })
  })
}
