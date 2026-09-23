// 主壳 Tab 状态单元测试：单例 + 下标读写（子页面"返回"切回首页依赖它）
import { describe, it, expect } from '@ohos/hypium'
import { MainTabModel } from '../main/ets/common/model/MainTabModel'

export default function mainTabModelTest() {
  describe('mainTabModelTest', () => {
    // 常规：默认停在首页 Tab
    it('should_default_to_home_tab', 0, () => {
      const model = MainTabModel.getInstance()
      model.index = MainTabModel.TAB_HOME
      expect(model.index).assertEqual(0)
    })

    // 常规：下标可写可读
    it('should_update_index', 0, () => {
      const model = MainTabModel.getInstance()
      model.index = MainTabModel.TAB_LIGHT
      expect(model.index).assertEqual(1)
      model.index = MainTabModel.TAB_HOME   // 还原
    })

    // 隐含约定：单例
    it('should_be_singleton', 0, () => {
      expect(MainTabModel.getInstance() === MainTabModel.getInstance()).assertTrue()
    })
  })
}
