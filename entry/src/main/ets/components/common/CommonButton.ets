// 通用按钮组件

import { UI_SIZES, FONT_SIZES, SHADOW_CONSTANTS, OPACITY_CONSTANTS } from '../../constants/AppConstants';

/**
 * 按钮类型枚举
 */
export enum ButtonType {
  PRIMARY = 'primary',
  SECONDARY = 'secondary', 
  OUTLINE = 'outline',
  TEXT = 'text',
  DANGER = 'danger',
  SUCCESS = 'success',
  WARNING = 'warning'
}

/**
 * 按钮尺寸枚举
 */
export enum ButtonSize {
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large'
}

/**
 * 按钮形状枚举
 */
export enum ButtonShape {
  RECTANGLE = 'rectangle',
  ROUND = 'round',
  CIRCLE = 'circle'
}

/**
 * 按钮配置接口
 */
export interface ButtonConfig {
  text: string;
  type?: ButtonType;
  size?: ButtonSize;
  shape?: ButtonShape;
  disabled?: boolean;
  loading?: boolean;
  width?: number | string;
  height?: number;
  fontSize?: number;
  fontColor?: string;
  backgroundColor?: string;
  borderColor?: string;
  borderWidth?: number;
  borderRadius?: number;
  shadow?: boolean;
  icon?: string;
  iconPosition?: 'left' | 'right';
  onClick?: () => void;
}

/**
 * 通用按钮组件
 */
@Component
export struct CommonButton {
  @Prop config: ButtonConfig;
  @State isPressed: boolean = false;

  /**
   * 获取按钮高度
   */
  private getButtonHeight(): number {
    switch (this.config.size) {
      case ButtonSize.SMALL:
        return this.config.height || UI_SIZES.BUTTON_HEIGHT_SMALL;
      case ButtonSize.LARGE:
        return this.config.height || 56;
      case ButtonSize.MEDIUM:
      default:
        return this.config.height || UI_SIZES.BUTTON_HEIGHT;
    }
  }

  /**
   * 获取字体大小
   */
  private getFontSize(): number {
    if (this.config.fontSize) {
      return this.config.fontSize;
    }
    
    switch (this.config.size) {
      case ButtonSize.SMALL:
        return FONT_SIZES.BODY_SMALL;
      case ButtonSize.LARGE:
        return FONT_SIZES.BODY_LARGE;
      case ButtonSize.MEDIUM:
      default:
        return FONT_SIZES.BODY_MEDIUM;
    }
  }

  /**
   * 获取背景颜色
   */
  private getBackgroundColor(): string {
    if (this.config.backgroundColor) {
      return this.config.backgroundColor;
    }

    if (this.config.disabled) {
      return '#F5F5F5';
    }

    switch (this.config.type) {
      case ButtonType.PRIMARY:
        return this.isPressed ? '#005bb5' : '#007AFF';
      case ButtonType.DANGER:
        return this.isPressed ? '#d12b20' : '#FF3B30';
      case ButtonType.SUCCESS:
        return this.isPressed ? '#0f5132' : '#198754';
      case ButtonType.WARNING:
        return this.isPressed ? '#664d03' : '#fd7e14';
      case ButtonType.OUTLINE:
      case ButtonType.TEXT:
        return this.isPressed ? 'rgba(0, 122, 255, 0.1)' : 'transparent';
      case ButtonType.SECONDARY:
      default:
        return this.isPressed ? 'rgba(0, 122, 255, 0.2)' : 'rgba(0, 122, 255, 0.1)';
    }
  }

  /**
   * 获取文字颜色
   */
  private getFontColor(): string {
    if (this.config.fontColor) {
      return this.config.fontColor;
    }

    if (this.config.disabled) {
      return '#CCCCCC';
    }

    switch (this.config.type) {
      case ButtonType.PRIMARY:
      case ButtonType.DANGER:
      case ButtonType.SUCCESS:
      case ButtonType.WARNING:
        return '#FFFFFF';
      case ButtonType.OUTLINE:
      case ButtonType.SECONDARY:
      case ButtonType.TEXT:
      default:
        return '#007AFF';
    }
  }

  /**
   * 获取边框颜色
   */
  private getBorderColor(): string {
    if (this.config.borderColor) {
      return this.config.borderColor;
    }

    if (this.config.type === ButtonType.OUTLINE) {
      return this.config.disabled ? '#CCCCCC' : '#007AFF';
    }

    return 'transparent';
  }

  /**
   * 获取边框宽度
   */
  private getBorderWidth(): number {
    if (this.config.borderWidth !== undefined) {
      return this.config.borderWidth;
    }

    return this.config.type === ButtonType.OUTLINE ? 1 : 0;
  }

  /**
   * 获取圆角半径
   */
  private getBorderRadius(): number {
    if (this.config.borderRadius !== undefined) {
      return this.config.borderRadius;
    }

    switch (this.config.shape) {
      case ButtonShape.ROUND:
        return this.getButtonHeight() / 2;
      case ButtonShape.CIRCLE:
        return this.getButtonHeight() / 2;
      case ButtonShape.RECTANGLE:
      default:
        return UI_SIZES.BUTTON_BORDER_RADIUS;
    }
  }

  /**
   * 获取按钮透明度
   */
  private getOpacity(): number {
    if (this.config.disabled) {
      return OPACITY_CONSTANTS.TEXT_DISABLED;
    }
    
    if (this.config.loading) {
      return OPACITY_CONSTANTS.SEMI_TRANSPARENT;
    }

    return OPACITY_CONSTANTS.FULLY_OPAQUE;
  }

  build() {
    Button() {
      Row() {
        // 左侧图标
        if (this.config.icon && this.config.iconPosition === 'left') {
          Text(this.config.icon)
            .fontSize(this.getFontSize())
            .fontColor(this.getFontColor())
            .margin({ right: 8 })
        }

        // 加载状态指示器
        if (this.config.loading) {
          LoadingProgress()
            .width(16)
            .height(16)
            .color(this.getFontColor())
            .margin({ right: this.config.text ? 8 : 0 })
        }

        // 按钮文字
        if (this.config.text) {
          Text(this.config.text)
            .fontSize(this.getFontSize())
            .fontColor(this.getFontColor())
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        // 右侧图标
        if (this.config.icon && this.config.iconPosition === 'right') {
          Text(this.config.icon)
            .fontSize(this.getFontSize())
            .fontColor(this.getFontColor())
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor(this.getBackgroundColor())
    .width(this.config.width || '100%')
    .height(this.getButtonHeight())
    .borderRadius(this.getBorderRadius())
    .border({
      width: this.getBorderWidth(),
      color: this.getBorderColor()
    })
    .opacity(this.getOpacity())
    .enabled(!this.config.disabled && !this.config.loading)
    .shadow(this.config.shadow ? {
      radius: 4,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    } : undefined)
    .stateEffect(true)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
    .onClick(() => {
      if (!this.config.disabled && !this.config.loading && this.config.onClick) {
        this.config.onClick();
      }
    })
  }
}

/**
 * 预设的按钮样式
 */
export class ButtonPresets {
  /**
   * 主要按钮
   */
  static primary(text: string, onClick?: () => void): ButtonConfig {
    return {
      text,
      type: ButtonType.PRIMARY,
      size: ButtonSize.MEDIUM,
      onClick
    };
  }

  /**
   * 次要按钮
   */
  static secondary(text: string, onClick?: () => void): ButtonConfig {
    return {
      text,
      type: ButtonType.SECONDARY,
      size: ButtonSize.MEDIUM,
      onClick
    };
  }

  /**
   * 轮廓按钮
   */
  static outline(text: string, onClick?: () => void): ButtonConfig {
    return {
      text,
      type: ButtonType.OUTLINE,
      size: ButtonSize.MEDIUM,
      onClick
    };
  }

  /**
   * 文字按钮
   */
  static text(text: string, onClick?: () => void): ButtonConfig {
    return {
      text,
      type: ButtonType.TEXT,
      size: ButtonSize.MEDIUM,
      onClick
    };
  }

  /**
   * 危险按钮
   */
  static danger(text: string, onClick?: () => void): ButtonConfig {
    return {
      text,
      type: ButtonType.DANGER,
      size: ButtonSize.MEDIUM,
      onClick
    };
  }

  /**
   * 成功按钮
   */
  static success(text: string, onClick?: () => void): ButtonConfig {
    return {
      text,
      type: ButtonType.SUCCESS,
      size: ButtonSize.MEDIUM,
      onClick
    };
  }

  /**
   * 警告按钮
   */
  static warning(text: string, onClick?: () => void): ButtonConfig {
    return {
      text,
      type: ButtonType.WARNING,
      size: ButtonSize.MEDIUM,
      onClick
    };
  }

  /**
   * 小尺寸按钮
   */
  static small(text: string, type: ButtonType = ButtonType.SECONDARY, onClick?: () => void): ButtonConfig {
    return {
      text,
      type,
      size: ButtonSize.SMALL,
      onClick
    };
  }

  /**
   * 大尺寸按钮
   */
  static large(text: string, type: ButtonType = ButtonType.PRIMARY, onClick?: () => void): ButtonConfig {
    return {
      text,
      type,
      size: ButtonSize.LARGE,
      onClick
    };
  }

  /**
   * 圆形按钮
   */
  static round(text: string, type: ButtonType = ButtonType.PRIMARY, onClick?: () => void): ButtonConfig {
    return {
      text,
      type,
      shape: ButtonShape.ROUND,
      onClick
    };
  }

  /**
   * 图标按钮
   */
  static icon(icon: string, text?: string, type: ButtonType = ButtonType.SECONDARY, onClick?: () => void): ButtonConfig {
    return {
      text: text || '',
      icon,
      iconPosition: text ? 'left' : undefined,
      type,
      shape: text ? ButtonShape.RECTANGLE : ButtonShape.CIRCLE,
      width: text ? undefined : UI_SIZES.BUTTON_HEIGHT,
      onClick
    };
  }

  /**
   * 加载按钮
   */
  static loading(text: string, type: ButtonType = ButtonType.PRIMARY): ButtonConfig {
    return {
      text,
      type,
      loading: true,
      disabled: true
    };
  }
} 