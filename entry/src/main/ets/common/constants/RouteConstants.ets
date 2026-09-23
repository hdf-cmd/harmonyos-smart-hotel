// 路由常量统一收敛，避免到处写魔法字符串
//
// 【为什么必须这么做】pushPathByName 跳转到不存在的路由名**不会抛异常**，
// 只会静默失败或白屏——字符串写错了没有任何编译期保护。
// 收敛成常量后，写错名字编译期就报错，而且"哪条路由属于哪个域"一目了然。
//
// 命名规范：应用级路由加 app. 前缀；域内路由直接用功能名。
export class RouteConstants {
  // ===== 应用级路由（根栈 RootDomain）=====
  static readonly LOGIN: string = 'app.Login'
  static readonly MAIN: string = 'app.Main'
}
