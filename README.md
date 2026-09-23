# 智慧酒店 · 客房智控 App（HarmonyOS / ArkTS）

华为 ICT 学院「广科·未来酒店」智慧客房考核项目：单 HAP 应用，按 5 张设计稿逐屏还原，覆盖登录（入住）、首页、灯光控制、窗帘控制、服务控制五个界面。

## 功能

- **登录（入住）**：房号/用户名双校验 + 「记住我的信息」持久化（preferences）+ 模拟离店
- **首页**：智慧客房顶栏 + 空调卡（开关、设定温度 16~30 夹取）+ 场景模式（明亮/柔和/阅读/温馨）+ 快捷服务（请勿打扰/清理房间）+ 晚安模式（一键关灯，联动灯光页）
- **灯光控制**：总开关（一键全开/全关）+ 5 场景（明亮/柔和/阅读/温馨/睡眠，联动 9 路灯组）+ 9 路独立开关
- **窗帘控制**：布帘/窗纱三态（打开/暂停/关闭，带开合动画）+ 全部打开/全部关闭联动
- **服务控制**：请勿打扰/清理房间开关（与首页快捷服务双向同步）+ SOS 紧急呼叫（二次确认）+ 退出登录（清除记住信息）

## 架构（MVVM + feature 分包）

```
entry/src/main/ets/
├── common/                  # 通用层（不依赖业务）
│   ├── base/                #   BaseViewModel、Result
│   ├── constants/           #   CommonConstants（颜色/尺寸）、RouteConstants（路由名收敛）
│   ├── log/                 #   Logger（统一 hilog 出口）
│   ├── model/               #   MainTabModel（跨 feature 共享的 Tab 状态）
│   └── utils/               #   ValidationUtil（校验纯函数）
├── features/                # 业务层：按功能分包，每包 model / viewmodel / view 三层
│   ├── login/  home/  light/  curtain/  service/
└── pages/                   # 页面入口
    ├── LoginPage.ets        #   登录页（根栈第一页）
    └── MainPage.ets         #   主壳：Tabs + 悬浮图标 TabBar，四个 Tab 域
entry/src/test/              # hypium 单元测试（44 用例，全绿）
```

关键约定：

- **状态共享**：跨页复用的状态走 ViewModel 单例（登录信息、灯光 9 路、窗帘三态、服务开关、Tab 下标），页面之间不互相直连
- **路由**：根栈（登录 / 主界面）+ Tab 域自持子栈（三级 Navigation，域内 push 不顶掉底部 Tab）
- **视图刷新**：`@ObservedV2` / `@Trace` + `@ComponentV2`；`@Builder` 内读取状态做依赖，避免"按值传参不刷新"的坑

## 运行

1. DevEco Studio 打开工程（本机验证环境：HarmonyOS 6.1.0(23) 编译，模拟器 6.1.1(24)，Pura 90）
2. 命令行构建运行：`devecocli run --device <serial> --ability EntryAbility`
3. 单元测试：`hvigorw test --mode module -p module=entry@default -p product=default`
   （结果文件：`entry/.test/default/intermediates/test/coverage_data/test_result.txt`）

## 测试

- **单元测试**：44 用例全绿——登录校验/记住信息/退出清理、空调温度上下限夹取、灯光场景→灯组映射与总开关推导、窗帘三态语义（含"暂停保持原位"）、服务开关、Tab 状态
- **模拟器全链路 E2E**：登录→首页（空调/场景/快捷/晚安）→灯光（总开关+场景联动）→窗帘（开合+全局）→服务（开关/SOS/退出），hilog 日志逐环节核验
- **静态门禁**：DevEco Code Linter 0 错误 0 警告

## 说明

- 设计素材（背景、卡片、图标）来自课程设计稿，位于 `entry/src/main/resources/base/media/`
- 应用图标：以设计稿右下角装饰元素 ✦ 为母题重构的金色分层图标（`AppScope` 与 `entry` 两处 layered_image）
