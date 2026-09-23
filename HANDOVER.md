# 交接文档（HANDOVER）

> 给接手本项目的同学/下一任维护者。功能与架构细节先看 `README.md`，本文只写**代码里看不出来的东西**：环境约束、验收口径、踩过的坑、自定规则和遗留决策。
> 最后更新：2026-09-23，基线提交 `27bdfb2`。

## 1. 项目现状（截至交接时）

- 考核题五个界面（登录/首页/灯光/窗帘/服务）**全部完成并实机验收通过**，含后续迭代：窗帘真暂停动画、布局适配、全面屏沉浸。
- 单测 **45 用例全绿**（README 里写的 44 是窗帘进度模型改造前的旧数，以本文和实际跑测为准）。
- git：只有 `main` 分支，19 个提交，与 `origin/main`（github.com/hdf-cmd/harmonyos-smart-hotel，公开仓库）完全同步，工作区干净，无待推送内容。
- 模拟器上安装的就是 `27bdfb2` 构建的最终版。

## 2. 环境与路径约束（⚠️ 最容易踩的第一条）

- **工程必须放在纯 ASCII 路径下**（本机在 `C:\Desktop\SmartHotel`）。中文路径会触发 hvigor 00306003 直接禁止构建，且构建 daemon 会锁住目录导致中文名文件夹无法改名/删除。不要把工程挪回中文目录。
- 设计素材与题面 `exam(1).docx` 不在工程内，放在 `C:\Desktop\智慧酒店` 的 5 个同名素材文件夹（题图逐页导出 PNG，图标自带深色 chip 底、卡片自带渐变底图）。素材已入库进 `entry/src/main/resources`，重复底图去重成一张 `page_background`；题面 docx 不入库。
- 工具链：DevEco Studio（装于 `D:\DevEco Studio`）、编译 HarmonyOS 6.1.0(23)、模拟器 6.1.1(24) **Pura 90**（密度 3.5，1320×2856）。
- 命令行工具 `devecocli`（run / build / ui click / ui screenshot / ui layout / emulator start）。

## 3. 常用命令

```bash
# 构建并部署到模拟器/真机
devecocli run --device <serial> --ability EntryAbility

# 单元测试（必须先设 SDK 环境变量，否则报找不到 SDK）
DEVECO_SDK_HOME="D:/DevEco Studio/sdk" hvigorw test --mode module -p module=entry@default -p product=default
# 结果文件：entry/.test/default/intermediates/test/coverage_data/test_result.txt

# 模拟器没开机时
devecocli emulator start "Pura 90"   # 启动后约等 45s 再操作

# UI 验收三件套
devecocli ui layout --mode full      # dump 控件树取坐标（改过布局后必须重新取，见 §6）
devecocli ui screenshot -o xx.png    # 截图（>1MB 才是亮屏，~71KB 是息屏假图）
devecocli ui click <x> <y>           # 或 hdc shell uitest uiInput click（时序更稳）
```

## 4. 架构要点（README 之外的补充）

- 跨页状态全部走 **ViewModel 单例**：`LoginViewModel`（房号）、`LightViewModel`（场景+9 路）、`CurtainViewModel`（三态+0~1 进度）、`ServiceViewModel`、`MainTabModel`。页面之间不直连。
- 窗帘 VM 是**进度模型**：`curtainPos/screenPos ∈ [0,1]`（0=全开、1=全关），写入口统一夹取；时长=基准 2500ms × 剩余距离，所以从半途续开续关都自然变短。
- 灯光/窗帘/服务页的「← 返回」要切回首页 Tab，走 `MainTabModel` 单例 + MainPage 的 `@Monitor` 驱动 TabsController，三页共用，别单独改某页。
- 全面屏背景：全屏 `page_background` 必须放在 **MainPage 根层、Tabs 之外**——TabContent 会裁掉子组件的 expandSafeArea，放子页里无效；状态栏透明靠 `EntryAbility.onWindowStageCreate` 里的 `setWindowSystemBarProperties`。

## 5. Git 工作流（本项目的规矩）

- 每个改动步骤：`feat/xxx` 分支提交 → `--ff-only` 合回 main →（如含测试改动）`test/xxx` 分支 → 合回 main。步骤分支不长期保留，合并即删。
- **push 前四检**：① `git log --name-only` 扫历史确认无敏感/临时文件混入；② 无签名材料（.p12/.cer 等）；③ 工作区干净；④ `git fetch` 后确认与远程无分叉。本项目 push 由原作者发令，接手后动远程前先沟通。
- 提交信息风格：`feat:/fix:/test:/chore:` + 中文一句话，说清「改了什么+为什么」。

## 6. 踩过的坑清单（别再踩）

**ArkUI/ArkTS：**
- `@Builder` 按值传参不刷新：状态依赖必须发生在 Builder 内部直接读 `@Trace`，不能靠参数。
- Row 里未显式设宽的 Image 会被分配**不等宽**（实测 355/259px 不对称）→ 一律 `.width('50%')` + `objectFit(Cover)`。
- **`Animator.cancel()` 陷阱**：官方语义与 finish 相同，cancel 后仍会**迟到派发终点帧**。释放旧动画必须先摘空 `onFrame/onFinish` 再 cancel（见 `CurtainView.releaseAnimator`），且所有动画回调里要校验「当前状态仍是建动画时的目标态」才允许写位置。历史上"暂停过一会弹回"就是这个坑。
- translate 用百分比字符串动画要 `toFixed(2)`，防浮点尾巴打断插值。

**验收/测试：**
- **改过布局后旧坐标全部作废**：曾经拿旧 y 连点 4 次全静默落空，误判应用有 bug。每次改布局后先 `ui layout` 重新 dump。
- 连点间隔 <1.5s 会被吞/漂移；`hdc shell uitest uiInput click` + 1.2s 间隔最稳；hdc 路径含空格必须整体加引号。
- 截图 3MB≈亮屏、~71KB≈息屏全黑——做「动画停住」之类像素断言前先确认是亮屏画面，否则锁屏静止图会制造 0% 差异假阳性。
- 应用可能被回收，冷启动会回登录页；验回归时留意当前到底在哪个页。
- `devecocli check`（lint）本机失效：探针验证永远 0 错误（假绿），别拿它当门禁；用 DevEco 内置 Code Linter 代替。

## 7. 题图没给、开发时自定的规则（改动前先读）

这些是原实现者拍板的口径，已随 diff 被验收默许；若要改，改的是「规则」不只是代码：

- 场景→灯组映射：明亮=全开 / 柔和=落地+廊 / 阅读=书桌+左右阅读 / 温馨=落地+吧+廊 / 睡眠=全关。
- 全局按钮高亮取聚合态：全开亮「全部打开」、全关亮「全部关闭」、混合两个都不亮。
- 窗帘「暂停」= 真暂停（停在半途，再点开/关按剩余距离续跑）。
- 窗帘关闭态视觉 = 两块直布板从两侧往中间合拢；垂帘（纱后主视觉图）仅在**全开静止态**显示，开合全程单层帘板、无叠影。
- 9 路独立控制只有 6 个图标素材：落地灯/吧灯共用一支、书桌+左右阅读共用一支（题图本身即复用）。
- SOS、退出登录有二次确认对话框；登录页首启预填 `2002/xiao` 并勾选记住（与题图一致），取消勾选后登录则下次留空。

## 8. 遗留事项（等拍板，不是 bug）

1. 晚安卡副标题「**一健**关闭所有灯光」——疑似设计稿错字，题图原文如此，目前照抄。改不改等甲方/老师口径。
2. 空调卡中间大数字固定显示 `currentTemp=20`（室温展示值），+/- 调的是 `targetTemp`（16~30，右上角小字）。逻辑有单测覆盖、不算错，但用户可能期望大数字跟手——是否改交互未拍板。

## 9. 验收材料在哪

- 各步验收截图归档：`C:\Desktop\智慧酒店\验收截图\第1步…第7步\`（7 个文件夹，与步骤序列一一对应）。
- 窗帘迭代（真暂停/减速/对称/布局/单层帘板/cancel 修复）的实机像素证据当时在 `%TEMP%\curtain_check\`，**已按清理规则删除**；需要时按 §6 方法重跑复现。
- 复现验收主链路：登录 → 首页四功能区 → 灯光总开关+5 场景 → 窗帘开/暂停/续跑/关+全局 → 服务开关/SOS/退出，全程可看 hilog（`Logger` 统一 `[TAG]` 出口）。
