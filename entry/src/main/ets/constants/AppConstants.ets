// AppConstants.ets - 应用常量配置
// ArkTS兼容版本

// UI尺寸配置接口
interface UISizesConfig {
  CARD_BORDER_RADIUS: number;
  BUTTON_HEIGHT: number;
  BUTTON_HEIGHT_SMALL: number;
  BUTTON_BORDER_RADIUS: number;
  INPUT_HEIGHT: number;
  INPUT_BORDER_RADIUS: number;
  DIALOG_WIDTH: number;
  DIALOG_PADDING: number;
  TAB_BAR_HEIGHT: number;
  HEADER_HEIGHT: number;
  LIST_ITEM_HEIGHT: number;
  ICON_SIZE_SMALL: number;
  ICON_SIZE_MEDIUM: number;
  ICON_SIZE_LARGE: number;
  SPACING_SMALL: number;
  SPACING_MEDIUM: number;
  SPACING_LARGE: number;
}

// UI尺寸常量
export const UI_SIZES: UISizesConfig = {
  CARD_BORDER_RADIUS: 16,
  BUTTON_HEIGHT: 48,
  BUTTON_HEIGHT_SMALL: 36,
  BUTTON_BORDER_RADIUS: 12,
  INPUT_HEIGHT: 48,
  INPUT_BORDER_RADIUS: 12,
  DIALOG_WIDTH: 320,
  DIALOG_PADDING: 24,
  TAB_BAR_HEIGHT: 64,
  HEADER_HEIGHT: 56,
  LIST_ITEM_HEIGHT: 64,
  ICON_SIZE_SMALL: 18,
  ICON_SIZE_MEDIUM: 24,
  ICON_SIZE_LARGE: 32,
  SPACING_SMALL: 8,
  SPACING_MEDIUM: 16,
  SPACING_LARGE: 24,
};

// 字体尺寸配置接口
interface FontSizesConfig {
  CAPTION: number;
  BODY_SMALL: number;
  BODY_MEDIUM: number;
  BODY_LARGE: number;
  TITLE_SMALL: number;
  TITLE_MEDIUM: number;
  TITLE_LARGE: number;
  HEADING_SMALL: number;
  HEADING_MEDIUM: number;
  HEADING_LARGE: number;
}

// 字体尺寸常量
export const FONT_SIZES: FontSizesConfig = {
  CAPTION: 12,
  BODY_SMALL: 14,
  BODY_MEDIUM: 16,
  BODY_LARGE: 18,
  TITLE_SMALL: 20,
  TITLE_MEDIUM: 24,
  TITLE_LARGE: 28,
  HEADING_SMALL: 32,
  HEADING_MEDIUM: 36,
  HEADING_LARGE: 40,
};

// 动画时长配置接口
interface AnimationDurationsConfig {
  FAST: number;
  NORMAL: number;
  SLOW: number;
  VERY_SLOW: number;
}

// 动画时长常量
export const ANIMATION_DURATIONS: AnimationDurationsConfig = {
  FAST: 150,
  NORMAL: 300,
  SLOW: 500,
  VERY_SLOW: 800,
};

// 时长配置接口
interface DurationsConfig {
  FOCUS_DEFAULT: number;
  FOCUS_MIN: number;
  FOCUS_MAX: number;
  BREAK_SHORT: number;
  BREAK_LONG: number;
  REMINDER_INTERVAL: number;
}

// 时长常量
export const DURATIONS: DurationsConfig = {
  FOCUS_DEFAULT: 25,
  FOCUS_MIN: 5,
  FOCUS_MAX: 120,
  BREAK_SHORT: 5,
  BREAK_LONG: 15,
  REMINDER_INTERVAL: 30,
};

// 字符串常量配置接口
interface StringsConfig {
  APP_NAME: string;
  CONFIRM: string;
  CANCEL: string;
  OK: string;
  SAVE: string;
  DELETE: string;
  EDIT: string;
  ADD: string;
  CLOSE: string;
  BACK: string;
  LOADING: string;
  ERROR: string;
  SUCCESS: string;
}

// 字符串常量
export const STRINGS: StringsConfig = {
  APP_NAME: '待办助手',
  CONFIRM: '确定',
  CANCEL: '取消',
  OK: '好的',
  SAVE: '保存',
  DELETE: '删除',
  EDIT: '编辑',
  ADD: '添加',
  CLOSE: '关闭',
  BACK: '返回',
  LOADING: '加载中...',
  ERROR: '错误',
  SUCCESS: '成功',
};

// 阴影配置接口
interface ShadowConstantsConfig {
  SMALL: string;
  MEDIUM: string;
  LARGE: string;
  BUTTON: string;
}

// 阴影常量
export const SHADOW_CONSTANTS: ShadowConstantsConfig = {
  SMALL: '0px 2px 4px rgba(0, 0, 0, 0.1)',
  MEDIUM: '0px 4px 8px rgba(0, 0, 0, 0.15)',
  LARGE: '0px 8px 16px rgba(0, 0, 0, 0.2)',
  BUTTON: '0px 2px 8px rgba(0, 0, 0, 0.12)',
};

// 透明度配置接口
interface OpacityConstantsConfig {
  DISABLED: number;
  HOVER: number;
  PRESSED: number;
  OVERLAY: number;
  TEXT_DISABLED: number;
  SEMI_TRANSPARENT: number;
  FULLY_OPAQUE: number;
}

// 透明度常量
export const OPACITY_CONSTANTS: OpacityConstantsConfig = {
  DISABLED: 0.4,
  HOVER: 0.8,
  PRESSED: 0.6,
  OVERLAY: 0.5,
  TEXT_DISABLED: 0.3,
  SEMI_TRANSPARENT: 0.7,
  FULLY_OPAQUE: 1.0,
}; 