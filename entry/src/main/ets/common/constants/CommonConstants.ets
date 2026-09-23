// 通用常量类：集中管理颜色、字号、间距、圆角，避免魔法数散落各页面
//
// 【什么时候往这里加常量】同一个值在 2 个以上地方出现，就该收敛进来。
// 好处是改一次全局生效；坏处是过度集中会让常量名失去意义——把握这个度。
export class CommonConstants {
  // 颜色
  static readonly COLOR_PRIMARY: string = '#007AFF'      // 主色（按钮、强调）
  static readonly COLOR_TEXT_MAIN: string = '#333333'    // 主文本
  static readonly COLOR_TEXT_SUB: string = '#666666'     // 次文本
  static readonly COLOR_TEXT_HINT: string = '#999999'    // 提示文本
  static readonly COLOR_BG_PAGE: string = '#F5F6FA'      // 页面背景
  static readonly COLOR_SURFACE: string = '#FFFFFF'      // 卡片/容器底色
  static readonly COLOR_SUCCESS: string = '#4CAF50'      // 成功/正确
  static readonly COLOR_ERROR: string = '#F44336'        // 失败/错误
  static readonly COLOR_WARN: string = '#FF6600'         // 警示/倒计时

  // 渐变（主按钮）
  static readonly GRADIENT_START: string = '#70b8f8'
  static readonly GRADIENT_END: string = '#416ff5'

  // 字号
  static readonly FONT_TITLE: number = 24
  static readonly FONT_SUBTITLE: number = 18
  static readonly FONT_BODY: number = 16
  static readonly FONT_CAPTION: number = 14

  // 尺寸
  static readonly BTN_HEIGHT: number = 50
  static readonly SPACE_S: number = 8
  static readonly SPACE_M: number = 16
  static readonly SPACE_L: number = 24
  static readonly RADIUS_CARD: number = 12

  // —— 智慧酒店金色主题（登录页/各控制页通用）——
  static readonly COLOR_GOLD_START: string = '#DDB77B'           // 金色渐变亮端（按钮）
  static readonly COLOR_GOLD_END: string = '#C49E6D'             // 金色渐变暗端（按钮）
  static readonly COLOR_TEXT_ON_IMAGE: string = '#FFFFFF'        // 图片背景上的主文字
  static readonly COLOR_TEXT_ON_IMAGE_SUB: string = '#CCFFFFFF'  // 图片背景上的次要文字（80% 白）
  static readonly COLOR_TEXT_ON_IMAGE_HINT: string = '#99FFFFFF' // 图片背景上的弱化文字（60% 白）
  static readonly COLOR_INPUT_BG: string = '#33FFFFFF'           // 输入框半透明白底（20% 白）
  static readonly INPUT_HEIGHT: number = 56                      // 输入框高度
  static readonly INPUT_RADIUS: number = 28                      // 输入框圆角
  static readonly LOGIN_BTN_HEIGHT: number = 56                  // 登录按钮高度

  // —— 首页 / 主壳（第 3 步）——
  static readonly COLOR_TEXT_ON_GOLD: string = '#5F420F'         // 金色卡片上的深色文字
  static readonly COLOR_TEXT_ON_GOLD_SUB: string = '#7A5A22'     // 金色卡片上的次要文字
  static readonly COLOR_GOLD_LIGHT_TEXT: string = '#F2DCAE'      // 金色卡片上的浅金数值
  static readonly COLOR_TEXT_ON_IMG_SOFT: string = '#E6E0D4'     // 图片背景上的柔和文字
  static readonly COLOR_TAB_BAR_BG: string = '#D92B2622'         // 底部悬浮栏底色
  static readonly COLOR_TAB_INACTIVE: string = '#B3FFFFFF'       // TabBar 未选中图标/文字
  static readonly COLOR_TAB_SELECTED_BG: string = '#C9A46D'      // TabBar 选中胶囊金色
  static readonly TAB_BAR_HEIGHT: number = 60                    // 底部悬浮栏高度
  static readonly PAGE_SIDE_PADDING: number = 16                 // 页面左右边距

  // —— 灯光页（第 4 步）——
  static readonly TOGGLE_WIDTH: number = 38                      // 独立控制开关宽
  static readonly TOGGLE_HEIGHT: number = 21                     // 独立控制开关高
  static readonly MAIN_SWITCH_SIZE: number = 88                  // 总开关尺寸
  static readonly LIGHT_ROW_HEIGHT: number = 40                  // 独立控制行高

  // —— 窗帘页（第 5 步）——
  static readonly CURTAIN_BTN_SIZE: number = 46                  // 三态按钮圆底尺寸
  static readonly CURTAIN_VISUAL_HEIGHT: number = 150            // 帘布可视区高度
  static readonly CURTAIN_CARD_HEIGHT: number = 268              // 布帘/窗纱卡高度
}
