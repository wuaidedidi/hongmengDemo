import { ThemeService, ThemeConfig } from '../services/ThemeService';

// 样式接口定义
export interface StyleConfig {
  backgroundColor?: string;
  backdropFilter?: BlurConfig;
  borderRadius?: number;
  border?: BorderOptions;
  shadow?: ShadowOptions;
  padding?: PaddingConfig;
  linearGradient?: GradientConfig;
  textShadow?: TextShadowOptions;
}

export interface BlurConfig {
  blur: number;
}

export interface BorderOptions {
  width: number | EdgeWidths;
  color: string;
}

export interface ShadowOptions {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

export interface TextShadowOptions {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

export interface EdgeWidths {
  top?: number;
  bottom?: number;
  left?: number;
  right?: number;
}

export interface PaddingConfig {
  left?: number;
  right?: number;
  top?: number;
  bottom?: number;
}

export interface GradientConfig {
  angle: number;
  colors: Array<[string, number]>;
}

// 文字发光强度映射接口
export interface GlowIntensityMap {
  subtle: number;
  medium: number;
  strong: number;
  intense: number;
}

export interface GlowOpacityMap {
  subtle: string;
  medium: string;
  strong: string;
  intense: string;
}

// 高端玻璃拟态样式工具类 - 重新设计
export class GlassmorphismStyles {
  private static themeService: ThemeService = ThemeService.getInstance();
  
  // 获取当前主题的玻璃拟态配色
  private static async getGlassColors() {
    const theme = await GlassmorphismStyles.themeService.getCurrentTheme();
    return theme.glassmorphism;
  }

  // === 精细化玻璃卡片样式系列 ===
  
  // 极轻玻璃卡片样式 - 用于悬浮元素和微妙装饰
  static async ultraLightGlassCard(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceUltraLight,
      borderRadius: 12,
      border: {
        width: 0.5,
        color: colors.borderSubtle
      },
      shadow: {
        radius: 6,
        color: colors.shadowSubtle,
        offsetX: 0,
        offsetY: 3
      }
    };
  }

  // 轻玻璃卡片样式 - 用于次要内容和辅助信息
  static async lightGlassCard(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceLight,
      borderRadius: 16,
      border: {
        width: 1,
        color: colors.borderLight
      },
      shadow: {
        radius: 10,
        color: colors.shadowSoft,
        offsetX: 0,
        offsetY: 5
      }
    };
  }

  // 中等玻璃卡片样式 - 用于主要内容区域
  static async mediumGlassCard(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceMedium,
      borderRadius: 20,
      border: {
        width: 1,
        color: colors.borderMedium
      },
      shadow: {
        radius: 15,
        color: colors.shadowMedium,
        offsetX: 0,
        offsetY: 8
      }
    };
  }

  // 强玻璃卡片样式 - 用于重要内容和焦点区域
  static async strongGlassCard(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceStrong,
      borderRadius: 24,
      border: {
        width: 1.5,
        color: colors.borderStrong
      },
      shadow: {
        radius: 20,
        color: colors.shadowStrong,
        offsetX: 0,
        offsetY: 10
      }
    };
  }

  // 不透明玻璃卡片样式 - 用于模态框和弹窗
  static async opaqueGlassCard(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceOpaque,
      borderRadius: 28,
      border: {
        width: 2,
        color: colors.borderStrong
      },
      shadow: {
        radius: 25,
        color: colors.shadowDeep,
        offsetX: 0,
        offsetY: 15
      }
    };
  }

  // 发光玻璃卡片样式 - 用于特殊强调和高级效果
  static async glowGlassCard(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceStrong,
      borderRadius: 24,
      border: {
        width: 1,
        color: colors.borderGlow
      },
      shadow: {
        radius: 30,
        color: colors.shadowGlow,
        offsetX: 0,
        offsetY: 0
      }
    };
  }

  // === 精细化按钮样式系列 ===

  // 轻量按钮样式 - 用于次要操作
  static async lightGlassButton(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceLight,
      borderRadius: 12,
      border: {
        width: 1,
        color: colors.borderLight
      },
      shadow: {
        radius: 8,
        color: colors.shadowSoft,
        offsetX: 0,
        offsetY: 4
      }
    };
  }

  // 主要按钮样式 - 带主题色高光
  static async primaryGlassButton(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceMedium,
      borderRadius: 16,
      border: {
        width: 1.5,
        color: colors.accentPrimary
      },
      shadow: {
        radius: 18,
        color: colors.glowEffect,
        offsetX: 0,
        offsetY: 0
      },
      linearGradient: {
        angle: 135,
        colors: [
          [colors.gradientPrimary[0] + '30', 0],
          [colors.gradientPrimary[1] + '20', 1]
        ]
      }
    };
  }

  // 次要按钮样式 - 带次要色调
  static async secondaryGlassButton(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceLight,
      borderRadius: 14,
      border: {
        width: 1,
        color: colors.accentSecondary
      },
      shadow: {
        radius: 12,
        color: colors.accentSecondary + '25',
        offsetX: 0,
        offsetY: 0
      }
    };
  }

  // 第三级按钮样式 - 用于补充操作
  static async tertiaryGlassButton(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceUltraLight,
      borderRadius: 10,
      border: {
        width: 1,
        color: colors.accentTertiary
      },
      shadow: {
        radius: 8,
        color: colors.accentTertiary + '20',
        offsetX: 0,
        offsetY: 2
      }
    };
  }

  // 成功按钮样式
  static async successGlassButton(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceLight,
      borderRadius: 16,
      border: {
        width: 1.5,
        color: colors.accentSuccess
      },
      shadow: {
        radius: 15,
        color: colors.accentSuccess + '30',
        offsetX: 0,
        offsetY: 0
      }
    };
  }

  // 警告按钮样式
  static async warningGlassButton(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceLight,
      borderRadius: 16,
      border: {
        width: 1.5,
        color: colors.accentWarning
      },
      shadow: {
        radius: 15,
        color: colors.accentWarning + '30',
        offsetX: 0,
        offsetY: 0
      }
    };
  }

  // 错误按钮样式
  static async errorGlassButton(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.surfaceLight,
      borderRadius: 16,
      border: {
        width: 1.5,
        color: colors.accentError
      },
      shadow: {
        radius: 15,
        color: colors.accentError + '30',
        offsetX: 0,
        offsetY: 0
      }
    };
  }

  // === 渐变背景样式系列 ===

  // 主渐变背景
  static async primaryGradientBackground(): Promise<GradientConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      angle: 135,
      colors: [
        [colors.gradientPrimary[0], 0],
        [colors.gradientPrimary[1], 1]
      ]
    };
  }

  // 次渐变背景
  static async secondaryGradientBackground(): Promise<GradientConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      angle: 225,
      colors: [
        [colors.gradientSecondary[0], 0],
        [colors.gradientSecondary[1], 1]
      ]
    };
  }

  // 强调渐变背景
  static async accentGradientBackground(): Promise<GradientConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      angle: 45,
      colors: [
        [colors.gradientAccent[0], 0],
        [colors.gradientAccent[1], 1]
      ]
    };
  }

  // 暖色渐变背景
  static async warmGradientBackground(): Promise<GradientConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      angle: 180,
      colors: [
        [colors.gradientWarm[0], 0],
        [colors.gradientWarm[1], 1]
      ]
    };
  }

  // 冷色渐变背景
  static async coolGradientBackground(): Promise<GradientConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      angle: 270,
      colors: [
        [colors.gradientCool[0], 0],
        [colors.gradientCool[1], 1]
      ]
    };
  }

  // === 文字发光效果系列 ===

  // 文字发光强度映射
  private static glowIntensityMap: GlowIntensityMap = {
    subtle: 4,
    medium: 8,
    strong: 12,
    intense: 16
  };

  // 文字发光透明度映射
  private static glowOpacityMap: GlowOpacityMap = {
    subtle: '40',
    medium: '60',
    strong: '80',
    intense: '100'
  };

  // 主色调文字发光
  static async primaryTextGlow(intensity: 'subtle' | 'medium' | 'strong' | 'intense' = 'medium'): Promise<TextShadowOptions> {
    const colors = await GlassmorphismStyles.getGlassColors();
    let radius: number;
    let opacity: string;
    
    if (intensity === 'subtle') {
      radius = 4;
      opacity = '40';
    } else if (intensity === 'medium') {
      radius = 8;
      opacity = '60';
    } else if (intensity === 'strong') {
      radius = 12;
      opacity = '80';
    } else {
      radius = 16;
      opacity = '100';
    }
    
    return {
      radius: radius,
      color: colors.accentPrimary + opacity,
      offsetX: 0,
      offsetY: 0
    };
  }

  // 次色调文字发光
  static async secondaryTextGlow(intensity: 'subtle' | 'medium' | 'strong' | 'intense' = 'medium'): Promise<TextShadowOptions> {
    const colors = await GlassmorphismStyles.getGlassColors();
    let radius: number;
    let opacity: string;
    
    if (intensity === 'subtle') {
      radius = 4;
      opacity = '40';
    } else if (intensity === 'medium') {
      radius = 8;
      opacity = '60';
    } else if (intensity === 'strong') {
      radius = 12;
      opacity = '80';
    } else {
      radius = 16;
      opacity = '100';
    }
    
    return {
      radius: radius,
      color: colors.accentSecondary + opacity,
      offsetX: 0,
      offsetY: 0
    };
  }

  // 成功色文字发光
  static async successTextGlow(intensity: 'subtle' | 'medium' | 'strong' | 'intense' = 'medium'): Promise<TextShadowOptions> {
    const colors = await GlassmorphismStyles.getGlassColors();
    let radius: number;
    let opacity: string;
    
    if (intensity === 'subtle') {
      radius = 4;
      opacity = '40';
    } else if (intensity === 'medium') {
      radius = 8;
      opacity = '60';
    } else if (intensity === 'strong') {
      radius = 12;
      opacity = '80';
    } else {
      radius = 16;
      opacity = '100';
    }
    
    return {
      radius: radius,
      color: colors.accentSuccess + opacity,
      offsetX: 0,
      offsetY: 0
    };
  }

  // 警告色文字发光
  static async warningTextGlow(intensity: 'subtle' | 'medium' | 'strong' | 'intense' = 'medium'): Promise<TextShadowOptions> {
    const colors = await GlassmorphismStyles.getGlassColors();
    let radius: number;
    let opacity: string;
    
    if (intensity === 'subtle') {
      radius = 4;
      opacity = '40';
    } else if (intensity === 'medium') {
      radius = 8;
      opacity = '60';
    } else if (intensity === 'strong') {
      radius = 12;
      opacity = '80';
    } else {
      radius = 16;
      opacity = '100';
    }
    
    return {
      radius: radius,
      color: colors.accentWarning + opacity,
      offsetX: 0,
      offsetY: 0
    };
  }

  // 错误色文字发光
  static async errorTextGlow(intensity: 'subtle' | 'medium' | 'strong' | 'intense' = 'medium'): Promise<TextShadowOptions> {
    const colors = await GlassmorphismStyles.getGlassColors();
    let radius: number;
    let opacity: string;
    
    if (intensity === 'subtle') {
      radius = 4;
      opacity = '40';
    } else if (intensity === 'medium') {
      radius = 8;
      opacity = '60';
    } else if (intensity === 'strong') {
      radius = 12;
      opacity = '80';
    } else {
      radius = 16;
      opacity = '100';
    }
    
    return {
      radius: radius,
      color: colors.accentError + opacity,
      offsetX: 0,
      offsetY: 0
    };
  }

  // 白色文字发光 - 用于深色背景
  static async whiteTextGlow(intensity: 'subtle' | 'medium' | 'strong' | 'intense' = 'medium'): Promise<TextShadowOptions> {
    let radius: number;
    let opacity: string;
    
    if (intensity === 'subtle') {
      radius = 4;
      opacity = '40';
    } else if (intensity === 'medium') {
      radius = 8;
      opacity = '60';
    } else if (intensity === 'strong') {
      radius = 12;
      opacity = '80';
    } else {
      radius = 16;
      opacity = '100';
    }
    
    return {
      radius: radius,
      color: 'rgba(255, 255, 255, 0.' + opacity + ')',
      offsetX: 0,
      offsetY: 0
    };
  }

  // === 特殊效果样式 ===

  // 微光效果样式
  static async shimmerEffect(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.shimmerEffect,
      borderRadius: 8,
      border: {
        width: 0.5,
        color: colors.borderSubtle
      }
    };
  }

  // 模糊遮罩样式
  static async blurOverlay(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.blurOverlay,
      backdropFilter: {
        blur: 20
      }
    };
  }

  // 高级模糊遮罩样式
  static async premiumBlurOverlay(): Promise<StyleConfig> {
    const colors = await GlassmorphismStyles.getGlassColors();
    return {
      backgroundColor: colors.blurOverlay,
      backdropFilter: {
        blur: 30
      },
      border: {
        width: 1,
        color: colors.borderSubtle
      }
    };
  }

  // === 组合样式方法 ===

  // 获取完整的玻璃卡片样式配置
  static async getCompleteGlassCardStyle(level: 'ultraLight' | 'light' | 'medium' | 'strong' | 'opaque' | 'glow'): Promise<StyleConfig> {
    if (level === 'ultraLight') {
      return await GlassmorphismStyles.ultraLightGlassCard();
    } else if (level === 'light') {
      return await GlassmorphismStyles.lightGlassCard();
    } else if (level === 'medium') {
      return await GlassmorphismStyles.mediumGlassCard();
    } else if (level === 'strong') {
      return await GlassmorphismStyles.strongGlassCard();
    } else if (level === 'opaque') {
      return await GlassmorphismStyles.opaqueGlassCard();
    } else {
      return await GlassmorphismStyles.glowGlassCard();
    }
  }

  // 获取完整的按钮样式配置
  static async getCompleteButtonStyle(type: 'light' | 'primary' | 'secondary' | 'tertiary' | 'success' | 'warning' | 'error'): Promise<StyleConfig> {
    if (type === 'light') {
      return await GlassmorphismStyles.lightGlassButton();
    } else if (type === 'primary') {
      return await GlassmorphismStyles.primaryGlassButton();
    } else if (type === 'secondary') {
      return await GlassmorphismStyles.secondaryGlassButton();
    } else if (type === 'tertiary') {
      return await GlassmorphismStyles.tertiaryGlassButton();
    } else if (type === 'success') {
      return await GlassmorphismStyles.successGlassButton();
    } else if (type === 'warning') {
      return await GlassmorphismStyles.warningGlassButton();
    } else {
      return await GlassmorphismStyles.errorGlassButton();
    }
  }
}

// === 主题感知智能组件 ===

// 智能玻璃卡片组件
@Component
export struct ThemeAwareGlassCard {
  @Prop level: 'ultraLight' | 'light' | 'medium' | 'strong' | 'opaque' | 'glow' = 'medium';
  @State private style: StyleConfig = {};
  @BuilderParam cardContent: () => void;

  async aboutToAppear() {
    this.style = await GlassmorphismStyles.getCompleteGlassCardStyle(this.level);
  }

  build() {
    Column() {
      if (this.cardContent) {
        this.cardContent();
      }
    }
    .backgroundColor(this.style.backgroundColor)
    .borderRadius(this.style.borderRadius)
    .border(this.style.border)
    .shadow(this.style.shadow)
    .padding(this.style.padding)
  }
}

// 智能玻璃按钮组件
@Component
export struct ThemeAwareGlassButton {
  @Prop type: 'light' | 'primary' | 'secondary' | 'tertiary' | 'success' | 'warning' | 'error' = 'primary';
  @Prop text: string = '';
  onClickCallback: () => void = () => {};
  @State private style: StyleConfig = {};

  async aboutToAppear() {
    this.style = await GlassmorphismStyles.getCompleteButtonStyle(this.type);
  }

  build() {
    Button(this.text)
      .backgroundColor(this.style.backgroundColor)
      .borderRadius(this.style.borderRadius)
      .border(this.style.border)
      .shadow(this.style.shadow)
      .onClick(() => {
        this.onClickCallback();
      })
  }
}

// 智能渐变背景组件
@Component
export struct ThemeAwareGradientBackground {
  @Prop gradientType: 'primary' | 'secondary' | 'accent' | 'warm' | 'cool' = 'primary';
  @State private gradient: GradientConfig = { angle: 135, colors: [] };
  @BuilderParam backgroundContent: () => void;

  async aboutToAppear() {
    if (this.gradientType === 'primary') {
      this.gradient = await GlassmorphismStyles.primaryGradientBackground();
    } else if (this.gradientType === 'secondary') {
      this.gradient = await GlassmorphismStyles.secondaryGradientBackground();
    } else if (this.gradientType === 'accent') {
      this.gradient = await GlassmorphismStyles.accentGradientBackground();
    } else if (this.gradientType === 'warm') {
      this.gradient = await GlassmorphismStyles.warmGradientBackground();
    } else {
      this.gradient = await GlassmorphismStyles.coolGradientBackground();
    }
  }

  build() {
    Column() {
      if (this.backgroundContent) {
        this.backgroundContent();
      }
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: this.gradient.angle,
      colors: this.gradient.colors
    })
  }
} 