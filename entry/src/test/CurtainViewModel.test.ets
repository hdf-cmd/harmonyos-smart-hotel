// 窗帘 ViewModel 单元测试：三态语义（暂停停在半途）/ 位置写入口夹取 / 全局联动 / 聚合推导
//
// 注意：CurtainViewModel 是单例，用例之间共享实例——每个用例自己先把状态置到起点再断言。
import { describe, it, expect } from '@ohos/hypium'
import { CurtainViewModel } from '../main/ets/features/curtain/viewmodel/CurtainViewModel'

export default function curtainViewModelTest() {
  describe('curtainViewModelTest', () => {
    // 常规：默认双帘打开、位置在全开
    it('should_default_open', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.openAll()
      vm.applyCurtainPos(0)
      vm.applyScreenPos(0)
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_OPEN)
      expect(vm.screenState).assertEqual(CurtainViewModel.STATE_OPEN)
      expect(vm.curtainPos).assertEqual(0)
      expect(vm.screenPos).assertEqual(0)
    })

    // 常规：关闭/打开只改三态；位置由动画落位（用例直接写位置入口模拟动画跑完）
    it('should_set_curtain_close_then_open', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.setCurtain(CurtainViewModel.STATE_CLOSE)
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_CLOSE)
      vm.applyCurtainPos(1)                      // 模拟开合动画走完、落到关闭位
      expect(vm.curtainPos).assertEqual(1)

      vm.setCurtain(CurtainViewModel.STATE_OPEN)
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_OPEN)
      vm.applyCurtainPos(0)
      expect(vm.curtainPos).assertEqual(0)
    })

    // 核心约定（真暂停）：关闭途中点暂停 → 位置停在半途、状态标记为 pause
    it('should_pause_keep_midway_position', 0, () => {
      const vm = CurtainViewModel.getInstance()

      vm.setCurtain(CurtainViewModel.STATE_CLOSE)
      vm.applyCurtainPos(0.4)                    // 动画跑到 40% 时按下暂停
      vm.setCurtain(CurtainViewModel.STATE_PAUSE)
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_PAUSE)
      expect(vm.curtainPos).assertEqual(0.4)     // 停在半途，暂停不改位置

      // 暂停后接着打开：位置从半途向全开推进
      vm.setCurtain(CurtainViewModel.STATE_OPEN)
      vm.applyCurtainPos(0)
      expect(vm.curtainPos).assertEqual(0)
    })

    // 隐含约定：位置写入口把越界值夹取回 0~1（动画越界保护）
    it('should_clamp_position_on_apply', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.applyCurtainPos(1.6)
      expect(vm.curtainPos).assertEqual(1)
      vm.applyCurtainPos(-0.3)
      expect(vm.curtainPos).assertEqual(0)
      vm.applyScreenPos(2)
      expect(vm.screenPos).assertEqual(1)
      vm.applyScreenPos(0)
    })

    // 常规：窗纱三态与位置（与布帘互不干扰）
    it('should_set_screening_state_and_position', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.setScreening(CurtainViewModel.STATE_CLOSE)
      expect(vm.screenState).assertEqual(CurtainViewModel.STATE_CLOSE)
      vm.applyScreenPos(0.6)
      expect(vm.screenPos).assertEqual(0.6)
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_OPEN)   // 布帘不受影响

      vm.setScreening(CurtainViewModel.STATE_OPEN)
      vm.applyScreenPos(0)
      expect(vm.screenPos).assertEqual(0)
    })

    // 全局：全部打开 / 全部关闭 → 双帘状态同步
    it('should_open_all_and_close_all_both_curtains', 0, () => {
      const vm = CurtainViewModel.getInstance()
      vm.closeAll()
      expect(vm.allClosed).assertTrue()
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_CLOSE)
      expect(vm.screenState).assertEqual(CurtainViewModel.STATE_CLOSE)

      vm.openAll()
      expect(vm.allOpen).assertTrue()
      expect(vm.curtainState).assertEqual(CurtainViewModel.STATE_OPEN)
      expect(vm.screenState).assertEqual(CurtainViewModel.STATE_OPEN)
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
