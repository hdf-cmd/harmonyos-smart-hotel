// 测试套注册中心
//
// 【hypium 最容易踩的坑】测试框架只认本文件导出的 testsuite() 函数作为入口，
// 所以每个 Xxx.test.ets 写完后**必须来这里"挂号"**（import + 调用一次），
// 漏注册的测试文件不会被跑，等于没写。
//
// 新增测试文件的标准动作：① 新建 Xxx.test.ets 并导出函数 → ② 这里 import → ③ 这里调用。
import loginViewModelTest from './LoginViewModel.test'
import validationUtilTest from './ValidationUtil.test'
import homeViewModelTest from './HomeViewModel.test'
import lightViewModelTest from './LightViewModel.test'
import serviceViewModelTest from './ServiceViewModel.test'
import mainTabModelTest from './MainTabModel.test'
import curtainViewModelTest from './CurtainViewModel.test'

// 测试入口：函数名固定为 testsuite，由框架约定调用
export default function testsuite() {
  loginViewModelTest()
  validationUtilTest()
  homeViewModelTest()
  lightViewModelTest()
  serviceViewModelTest()
  mainTabModelTest()
  curtainViewModelTest()
}
