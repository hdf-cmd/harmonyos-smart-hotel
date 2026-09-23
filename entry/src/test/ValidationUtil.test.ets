// 校验工具单元测试：房号规则边界 + 用户名基本边界
//
// 【这就是纯函数的回报】不启动界面、不接设备，直接喂参数断言结果。
import { describe, it, expect } from '@ohos/hypium'
import { ValidationUtil } from '../main/ets/common/utils/ValidationUtil'

export default function validationUtilTest() {
  describe('validationUtilTest', () => {
    // 常规：合法房号
    it('should_pass_valid_room_no', 0, () => {
      expect(ValidationUtil.validateRoomNo('2002').isValid).assertTrue()
    })

    // 边界：空串 / 纯空格都要拒绝
    it('should_reject_empty_room_no', 0, () => {
      expect(ValidationUtil.validateRoomNo('').isValid).assertFalse()
      expect(ValidationUtil.validateRoomNo('   ').isValid).assertFalse()
    })

    // 边界：只要出现非数字字符就拒绝
    it('should_reject_non_digit_room_no', 0, () => {
      expect(ValidationUtil.validateRoomNo('20a2').isValid).assertFalse()
      expect(ValidationUtil.validateRoomNo('2002室').isValid).assertFalse()
    })

    // 边界：6 位是上限，临界值两侧都踩
    it('should_reject_over_length_room_no', 0, () => {
      expect(ValidationUtil.validateRoomNo('123456').isValid).assertTrue()
      expect(ValidationUtil.validateRoomNo('1234567').isValid).assertFalse()
    })

    // 用户名：短于 3 个字符拒绝，合法值通过（登录页复用现成规则）
    it('should_validate_username_boundary', 0, () => {
      expect(ValidationUtil.validateUsername('xi').isValid).assertFalse()
      expect(ValidationUtil.validateUsername('xiao').isValid).assertTrue()
    })
  })
}
