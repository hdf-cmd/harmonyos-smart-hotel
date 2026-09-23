// 登录 ViewModel 单元测试：校验分支 + "记住我的信息"落盘/恢复逻辑
//
// 【替身注入】RememberMeStore 被换成内存替身，单测不碰 preferences（不需要设备环境）。
import { describe, it, expect } from '@ohos/hypium'
import { common } from '@kit.AbilityKit'
import { LoginViewModel } from '../main/ets/features/login/viewmodel/LoginViewModel'
import { RememberMeStore } from '../main/ets/features/login/viewmodel/RememberMeStore'
import { LoginInfo } from '../main/ets/features/login/model/LoginInfo'

// 内存替身：记录 save 收到什么、load 返回什么
class FakeRememberMeStore extends RememberMeStore {
  savedInfo?: LoginInfo
  private mockLoad?: LoginInfo

  setMockLoad(info: LoginInfo): void {
    this.mockLoad = info
  }

  async load(context: common.Context): Promise<LoginInfo | undefined> {
    return this.mockLoad
  }

  async save(context: common.Context, info: LoginInfo): Promise<void> {
    this.savedInfo = info
  }
}

export default function loginViewModelTest() {
  describe('loginViewModelTest', () => {
    // 常规：合法输入 → 成功，返回值与表单一致
    it('should_submit_success_with_valid_input', 0, () => {
      const vm = new LoginViewModel(new FakeRememberMeStore())
      vm.roomNo = '2002'
      vm.userName = 'xiao'
      const res = vm.submit()
      expect(res.ok).assertTrue()
      expect(res.value?.roomNo).assertEqual('2002')
      expect(res.value?.userName).assertEqual('xiao')
      expect(vm.errorMessage).assertEqual('')
    })

    // 边界：房号为空 → 失败并给出提示
    it('should_fail_when_room_no_empty', 0, () => {
      const vm = new LoginViewModel(new FakeRememberMeStore())
      vm.roomNo = ''
      vm.userName = 'xiao'
      const res = vm.submit()
      expect(res.ok).assertFalse()
      expect(vm.errorMessage).assertEqual('房号不能为空')
    })

    // 边界：房号含非数字 → 失败
    it('should_fail_when_room_no_not_digit', 0, () => {
      const vm = new LoginViewModel(new FakeRememberMeStore())
      vm.roomNo = '20a2'
      vm.userName = 'xiao'
      expect(vm.submit().ok).assertFalse()
    })

    // 边界：房号合法但用户名为空 → 失败并提示用户名
    it('should_fail_when_username_empty', 0, () => {
      const vm = new LoginViewModel(new FakeRememberMeStore())
      vm.roomNo = '2002'
      vm.userName = ''
      const res = vm.submit()
      expect(res.ok).assertFalse()
      expect(vm.errorMessage).assertEqual('用户名不能为空')
    })

    // 隐含约定：校验失败不该留下 loading 副作用（提交是同步操作）
    it('should_keep_loading_false_after_failure', 0, () => {
      const vm = new LoginViewModel(new FakeRememberMeStore())
      vm.roomNo = ''
      vm.submit()
      expect(vm.loading).assertFalse()
    })

    // 记住信息：勾选 → 保存当前表单值
    it('should_save_values_when_remember_checked', 0, async () => {
      const fake = new FakeRememberMeStore()
      const vm = new LoginViewModel(fake)
      vm.roomNo = '3003'
      vm.userName = 'abc'
      vm.rememberMe = true
      await vm.persistLoginState({} as common.Context)
      expect(fake.savedInfo?.roomNo).assertEqual('3003')
      expect(fake.savedInfo?.userName).assertEqual('abc')
      expect(fake.savedInfo?.rememberMe).assertTrue()
    })

    // 记住信息：未勾选 → 保存空值（保证下次打开是空的）
    it('should_save_empty_when_remember_unchecked', 0, async () => {
      const fake = new FakeRememberMeStore()
      const vm = new LoginViewModel(fake)
      vm.roomNo = '3003'
      vm.userName = 'abc'
      vm.rememberMe = false
      await vm.persistLoginState({} as common.Context)
      expect(fake.savedInfo?.roomNo).assertEqual('')
      expect(fake.savedInfo?.userName).assertEqual('')
      expect(fake.savedInfo?.rememberMe).assertFalse()
    })

    // 记住信息：无历史记录 → 保持预填值；有记录 → 回填
    it('should_restore_saved_info_or_keep_default', 0, async () => {
      const fake = new FakeRememberMeStore()
      const vm = new LoginViewModel(fake)
      await vm.restore({} as common.Context)
      expect(vm.roomNo).assertEqual('2002')
      expect(vm.userName).assertEqual('xiao')

      const saved = new LoginInfo()
      saved.roomNo = '8888'
      saved.userName = 'guest'
      saved.rememberMe = false
      fake.setMockLoad(saved)
      await vm.restore({} as common.Context)
      expect(vm.roomNo).assertEqual('8888')
      expect(vm.userName).assertEqual('guest')
      expect(vm.rememberMe).assertFalse()
    })

    // 退出登录：内存态复位（表单清空、取消勾选）
    it('should_logout_reset_memory_state', 0, async () => {
      const vm = new LoginViewModel(new FakeRememberMeStore())
      vm.roomNo = '2002'
      vm.userName = 'xiao'
      vm.rememberMe = true

      await vm.logout({} as common.Context)

      expect(vm.roomNo).assertEqual('')
      expect(vm.userName).assertEqual('')
      expect(vm.rememberMe).assertFalse()
    })

    // 退出登录：持久化也被清空（存空值 + 未勾选，下一位客人看不到残留）
    it('should_logout_clear_persisted_store', 0, async () => {
      const fake = new FakeRememberMeStore()
      const vm = new LoginViewModel(fake)
      vm.roomNo = '2002'
      vm.userName = 'xiao'
      vm.rememberMe = true

      await vm.logout({} as common.Context)

      expect(fake.savedInfo?.roomNo).assertEqual('')
      expect(fake.savedInfo?.userName).assertEqual('')
      expect(fake.savedInfo?.rememberMe).assertFalse()
    })
  })
}
