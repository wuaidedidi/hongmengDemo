import preferences from '@ohos.data.preferences';

// 玻璃拟态颜色配置接口
export interface GlassmorphismColors {
  // 基础背景色系 - 5层深浅变化
  backgroundPrimary: string;
  backgroundSecondary: string;
  backgroundTertiary: string;
  
  // 玻璃表面色系 - 5种透明度
  surfaceUltraLight: string;  // 3% 透明度
  surfaceLight: string;       // 8% 透明度
  surfaceMedium: string;      // 15% 透明度
  surfaceStrong: string;      // 25% 透明度
  surfaceOpaque: string;      // 不透明表面
  
  // 边框色系 - 4级强度
  borderSubtle: string;       // 极细边框
  borderLight: string;        // 轻边框
  borderMedium: string;       // 中等边框
  borderStrong: string;       // 强边框
  borderGlow: string;         // 发光边框
  
  // 阴影系统 - 5级深度
  shadowSubtle: string;       // 极轻阴影
  shadowSoft: string;         // 柔和阴影
  shadowMedium: string;       // 中等阴影
  shadowStrong: string;       // 强阴影
  shadowDeep: string;         // 深阴影
  shadowGlow: string;         // 发光阴影
  
  // 强调色彩 - 主要、次要、第三级的和谐搭配
  accentPrimary: string;      // 主强调色
  accentSecondary: string;    // 次强调色
  accentTertiary: string;     // 第三强调色
  accentSuccess: string;      // 成功色
  accentWarning: string;      // 警告色
  accentError: string;        // 错误色
  
  // 专业渐变 - 3套精心调配的渐变方案
  gradientPrimary: [string, string];
  gradientSecondary: [string, string];
  gradientAccent: [string, string];
  gradientWarm: [string, string];
  gradientCool: [string, string];
  
  // 特殊效果
  glowEffect: string;         // 发光效果
  shimmerEffect: string;      // 微光效果
  blurOverlay: string;        // 模糊遮罩
}

// 主题预览颜色接口
export interface ThemePreviewColors {
  primary: string;
  secondary: string;
  accent: string;
}

// 主题配置接口
export interface ThemeConfig {
  id: string;                 // 主题ID
  name: string;               // 主题名称
  displayName: string;        // 显示名称
  description: string;        // 主题描述
  backgroundColor: string;    // 背景色
  textColor: string;         // 文字色
  
  // 兼容旧接口的属性
  primaryColor: string;       // 主色调
  cardBackgroundColor: string; // 卡片背景色
  borderColor: string;        // 边框色
  shadowColor: string;        // 阴影色
  errorColor: string;         // 错误色
  
  glassmorphism: GlassmorphismColors;
}

// 苹果风格的高端主题配置
export class ThemeService {
  private static instance: ThemeService;
  private currentTheme: ThemeConfig;
  private preferences: preferences.Preferences | null = null;
  private themeChangeListeners: Array<() => void> = [];

  private constructor() {
    this.currentTheme = this.getAppleInspiredThemes()[0]; // 默认使用第一个主题
  }

  static getInstance(): ThemeService {
    if (!ThemeService.instance) {
      ThemeService.instance = new ThemeService();
    }
    return ThemeService.instance;
  }

  // 苹果风格的精致主题配置
  private getAppleInspiredThemes(): ThemeConfig[] {
    return [
      {
        id: 'appleClassic',
        name: 'appleClassic',
        displayName: '苹果经典',
        description: '苹果经典浅色主题，清新优雅',
        backgroundColor: '#F2F2F7',
        textColor: '#1C1C1E',
        primaryColor: '#007AFF',
        cardBackgroundColor: '#FFFFFF',
        borderColor: 'rgba(0, 0, 0, 0.08)',
        shadowColor: 'rgba(0, 0, 0, 0.08)',
        errorColor: '#FF3B30',
        glassmorphism: {
          // 基础背景 - 苹果经典的浅色系
          backgroundPrimary: '#F2F2F7',
          backgroundSecondary: '#FFFFFF',
          backgroundTertiary: '#E5E5EA',
          
          // 玻璃表面 - 苹果式的精致透明度
          surfaceUltraLight: 'rgba(255, 255, 255, 0.60)',
          surfaceLight: 'rgba(255, 255, 255, 0.75)',
          surfaceMedium: 'rgba(255, 255, 255, 0.85)',
          surfaceStrong: 'rgba(255, 255, 255, 0.95)',
          surfaceOpaque: '#FFFFFF',
          
          // 边框 - 苹果的细腻边框
          borderSubtle: 'rgba(0, 0, 0, 0.04)',
          borderLight: 'rgba(0, 0, 0, 0.08)',
          borderMedium: 'rgba(0, 0, 0, 0.12)',
          borderStrong: 'rgba(0, 0, 0, 0.18)',
          borderGlow: 'rgba(0, 122, 255, 0.25)',
          
          // 阴影 - 苹果式的柔和阴影
          shadowSubtle: 'rgba(0, 0, 0, 0.02)',
          shadowSoft: 'rgba(0, 0, 0, 0.04)',
          shadowMedium: 'rgba(0, 0, 0, 0.08)',
          shadowStrong: 'rgba(0, 0, 0, 0.12)',
          shadowDeep: 'rgba(0, 0, 0, 0.16)',
          shadowGlow: 'rgba(0, 122, 255, 0.15)',
          
          // 强调色 - 苹果系统色彩
          accentPrimary: '#007AFF',    // 苹果蓝
          accentSecondary: '#5856D6',  // 苹果紫
          accentTertiary: '#FF9500',   // 苹果橙
          accentSuccess: '#34C759',    // 苹果绿
          accentWarning: '#FF9500',    // 苹果橙
          accentError: '#FF3B30',      // 苹果红
          
          // 渐变 - 苹果风格的精致渐变
          gradientPrimary: ['#007AFF', '#5856D6'],
          gradientSecondary: ['#FFFFFF', '#F2F2F7'],
          gradientAccent: ['#FF9500', '#FF6B35'],
          gradientWarm: ['#FF9500', '#FF6B6B'],
          gradientCool: ['#007AFF', '#00D4AA'],
          
          // 特殊效果
          glowEffect: 'rgba(0, 122, 255, 0.20)',
          shimmerEffect: 'rgba(255, 255, 255, 0.30)',
          blurOverlay: 'rgba(242, 242, 247, 0.80)'
        }
      },
      {
        id: 'appleDark',
        name: 'appleDark',
        displayName: '苹果深色',
        description: '苹果深色模式，护眼舒适',
        backgroundColor: '#000000',
        textColor: '#FFFFFF',
        primaryColor: '#0A84FF',
        cardBackgroundColor: '#1C1C1E',
        borderColor: 'rgba(255, 255, 255, 0.10)',
        shadowColor: 'rgba(0, 0, 0, 0.40)',
        errorColor: '#FF453A',
        glassmorphism: {
          // 基础背景 - 苹果深色模式
          backgroundPrimary: '#000000',
          backgroundSecondary: '#1C1C1E',
          backgroundTertiary: '#2C2C2E',
          
          // 玻璃表面 - 深色模式的精致透明度
          surfaceUltraLight: 'rgba(28, 28, 30, 0.60)',
          surfaceLight: 'rgba(44, 44, 46, 0.75)',
          surfaceMedium: 'rgba(58, 58, 60, 0.85)',
          surfaceStrong: 'rgba(72, 72, 74, 0.95)',
          surfaceOpaque: '#1C1C1E',
          
          // 边框 - 深色模式边框
          borderSubtle: 'rgba(255, 255, 255, 0.06)',
          borderLight: 'rgba(255, 255, 255, 0.10)',
          borderMedium: 'rgba(255, 255, 255, 0.16)',
          borderStrong: 'rgba(255, 255, 255, 0.24)',
          borderGlow: 'rgba(10, 132, 255, 0.35)',
          
          // 阴影 - 深色模式阴影
          shadowSubtle: 'rgba(0, 0, 0, 0.20)',
          shadowSoft: 'rgba(0, 0, 0, 0.30)',
          shadowMedium: 'rgba(0, 0, 0, 0.40)',
          shadowStrong: 'rgba(0, 0, 0, 0.50)',
          shadowDeep: 'rgba(0, 0, 0, 0.60)',
          shadowGlow: 'rgba(10, 132, 255, 0.25)',
          
          // 强调色 - 苹果深色模式系统色彩
          accentPrimary: '#0A84FF',    // 深色模式苹果蓝
          accentSecondary: '#5E5CE6',  // 深色模式苹果紫
          accentTertiary: '#FF9F0A',   // 深色模式苹果橙
          accentSuccess: '#30D158',    // 深色模式苹果绿
          accentWarning: '#FF9F0A',    // 深色模式苹果橙
          accentError: '#FF453A',      // 深色模式苹果红
          
          // 渐变 - 深色模式渐变
          gradientPrimary: ['#0A84FF', '#5E5CE6'],
          gradientSecondary: ['#1C1C1E', '#2C2C2E'],
          gradientAccent: ['#FF9F0A', '#FF6B35'],
          gradientWarm: ['#FF9F0A', '#FF6B6B'],
          gradientCool: ['#0A84FF', '#00D4AA'],
          
          // 特殊效果
          glowEffect: 'rgba(10, 132, 255, 0.30)',
          shimmerEffect: 'rgba(255, 255, 255, 0.10)',
          blurOverlay: 'rgba(0, 0, 0, 0.70)'
        }
      },
      {
        id: 'appleGraphite',
        name: 'appleGraphite',
        displayName: '苹果石墨',
        description: '苹果石墨色系，商务专业',
        backgroundColor: '#8E8E93',
        textColor: '#FFFFFF',
        primaryColor: '#5856D6',
        cardBackgroundColor: '#AEAEB2',
        borderColor: 'rgba(255, 255, 255, 0.12)',
        shadowColor: 'rgba(0, 0, 0, 0.20)',
        errorColor: '#FF3B30',
        glassmorphism: {
          // 基础背景 - 苹果石墨色系
          backgroundPrimary: '#8E8E93',
          backgroundSecondary: '#AEAEB2',
          backgroundTertiary: '#C7C7CC',
          
          // 玻璃表面 - 石墨色透明度
          surfaceUltraLight: 'rgba(142, 142, 147, 0.60)',
          surfaceLight: 'rgba(174, 174, 178, 0.75)',
          surfaceMedium: 'rgba(199, 199, 204, 0.85)',
          surfaceStrong: 'rgba(209, 209, 214, 0.95)',
          surfaceOpaque: '#AEAEB2',
          
          // 边框 - 石墨色边框
          borderSubtle: 'rgba(255, 255, 255, 0.08)',
          borderLight: 'rgba(255, 255, 255, 0.12)',
          borderMedium: 'rgba(255, 255, 255, 0.18)',
          borderStrong: 'rgba(255, 255, 255, 0.25)',
          borderGlow: 'rgba(88, 86, 214, 0.30)',
          
          // 阴影 - 石墨色阴影
          shadowSubtle: 'rgba(0, 0, 0, 0.10)',
          shadowSoft: 'rgba(0, 0, 0, 0.15)',
          shadowMedium: 'rgba(0, 0, 0, 0.20)',
          shadowStrong: 'rgba(0, 0, 0, 0.25)',
          shadowDeep: 'rgba(0, 0, 0, 0.30)',
          shadowGlow: 'rgba(88, 86, 214, 0.20)',
          
          // 强调色 - 石墨主题强调色
          accentPrimary: '#5856D6',    // 苹果紫
          accentSecondary: '#007AFF',  // 苹果蓝
          accentTertiary: '#FF2D92',   // 苹果粉
          accentSuccess: '#34C759',    // 苹果绿
          accentWarning: '#FF9500',    // 苹果橙
          accentError: '#FF3B30',      // 苹果红
          
          // 渐变 - 石墨色渐变
          gradientPrimary: ['#5856D6', '#007AFF'],
          gradientSecondary: ['#8E8E93', '#AEAEB2'],
          gradientAccent: ['#FF2D92', '#FF6B35'],
          gradientWarm: ['#FF9500', '#FF6B6B'],
          gradientCool: ['#007AFF', '#5856D6'],
          
          // 特殊效果
          glowEffect: 'rgba(88, 86, 214, 0.25)',
          shimmerEffect: 'rgba(255, 255, 255, 0.15)',
          blurOverlay: 'rgba(142, 142, 147, 0.75)'
        }
      },
      {
        id: 'appleGold',
        name: 'appleGold',
        displayName: '苹果金色',
        description: '苹果金色主题，奢华温暖',
        backgroundColor: '#FFD60A',
        textColor: '#1C1C1E',
        primaryColor: '#FF9500',
        cardBackgroundColor: '#FFCC02',
        borderColor: 'rgba(28, 28, 30, 0.10)',
        shadowColor: 'rgba(0, 0, 0, 0.12)',
        errorColor: '#FF3B30',
        glassmorphism: {
          // 基础背景 - 苹果金色系
          backgroundPrimary: '#FFD60A',
          backgroundSecondary: '#FFCC02',
          backgroundTertiary: '#F2CC00',
          
          // 玻璃表面 - 金色透明度
          surfaceUltraLight: 'rgba(255, 214, 10, 0.60)',
          surfaceLight: 'rgba(255, 204, 2, 0.75)',
          surfaceMedium: 'rgba(242, 204, 0, 0.85)',
          surfaceStrong: 'rgba(229, 194, 0, 0.95)',
          surfaceOpaque: '#FFCC02',
          
          // 边框 - 金色边框
          borderSubtle: 'rgba(28, 28, 30, 0.06)',
          borderLight: 'rgba(28, 28, 30, 0.10)',
          borderMedium: 'rgba(28, 28, 30, 0.15)',
          borderStrong: 'rgba(28, 28, 30, 0.20)',
          borderGlow: 'rgba(255, 149, 0, 0.35)',
          
          // 阴影 - 金色阴影
          shadowSubtle: 'rgba(0, 0, 0, 0.05)',
          shadowSoft: 'rgba(0, 0, 0, 0.08)',
          shadowMedium: 'rgba(0, 0, 0, 0.12)',
          shadowStrong: 'rgba(0, 0, 0, 0.16)',
          shadowDeep: 'rgba(0, 0, 0, 0.20)',
          shadowGlow: 'rgba(255, 149, 0, 0.25)',
          
          // 强调色 - 金色主题强调色
          accentPrimary: '#FF9500',    // 苹果橙
          accentSecondary: '#FF2D92',  // 苹果粉
          accentTertiary: '#AF52DE',   // 苹果紫
          accentSuccess: '#34C759',    // 苹果绿
          accentWarning: '#FF9500',    // 苹果橙
          accentError: '#FF3B30',      // 苹果红
          
          // 渐变 - 金色渐变
          gradientPrimary: ['#FFD60A', '#FF9500'],
          gradientSecondary: ['#FFCC02', '#F2CC00'],
          gradientAccent: ['#FF2D92', '#AF52DE'],
          gradientWarm: ['#FF9500', '#FF6B35'],
          gradientCool: ['#FFD60A', '#34C759'],
          
          // 特殊效果
          glowEffect: 'rgba(255, 149, 0, 0.30)',
          shimmerEffect: 'rgba(255, 255, 255, 0.25)',
          blurOverlay: 'rgba(255, 214, 10, 0.80)'
        }
      },
      {
        id: 'appleRose',
        name: 'appleRose',
        displayName: '苹果玫瑰金',
        description: '苹果玫瑰金主题，优雅浪漫',
        backgroundColor: '#FF2D92',
        textColor: '#FFFFFF',
        primaryColor: '#AF52DE',
        cardBackgroundColor: '#E8267A',
        borderColor: 'rgba(255, 255, 255, 0.12)',
        shadowColor: 'rgba(0, 0, 0, 0.20)',
        errorColor: '#FF453A',
        glassmorphism: {
          // 基础背景 - 苹果玫瑰金色系
          backgroundPrimary: '#FF2D92',
          backgroundSecondary: '#E8267A',
          backgroundTertiary: '#D11F63',
          
          // 玻璃表面 - 玫瑰金透明度
          surfaceUltraLight: 'rgba(255, 45, 146, 0.60)',
          surfaceLight: 'rgba(232, 38, 122, 0.75)',
          surfaceMedium: 'rgba(209, 31, 99, 0.85)',
          surfaceStrong: 'rgba(186, 28, 88, 0.95)',
          surfaceOpaque: '#E8267A',
          
          // 边框 - 玫瑰金边框
          borderSubtle: 'rgba(255, 255, 255, 0.08)',
          borderLight: 'rgba(255, 255, 255, 0.12)',
          borderMedium: 'rgba(255, 255, 255, 0.18)',
          borderStrong: 'rgba(255, 255, 255, 0.25)',
          borderGlow: 'rgba(175, 82, 222, 0.35)',
          
          // 阴影 - 玫瑰金阴影
          shadowSubtle: 'rgba(0, 0, 0, 0.10)',
          shadowSoft: 'rgba(0, 0, 0, 0.15)',
          shadowMedium: 'rgba(0, 0, 0, 0.20)',
          shadowStrong: 'rgba(0, 0, 0, 0.25)',
          shadowDeep: 'rgba(0, 0, 0, 0.30)',
          shadowGlow: 'rgba(175, 82, 222, 0.25)',
          
          // 强调色 - 玫瑰金主题强调色
          accentPrimary: '#AF52DE',    // 苹果紫
          accentSecondary: '#5856D6',  // 苹果靛蓝
          accentTertiary: '#007AFF',   // 苹果蓝
          accentSuccess: '#34C759',    // 苹果绿
          accentWarning: '#FF9500',    // 苹果橙
          accentError: '#FF453A',      // 苹果红
          
          // 渐变 - 玫瑰金渐变
          gradientPrimary: ['#FF2D92', '#AF52DE'],
          gradientSecondary: ['#E8267A', '#D11F63'],
          gradientAccent: ['#AF52DE', '#5856D6'],
          gradientWarm: ['#FF2D92', '#FF6B35'],
          gradientCool: ['#AF52DE', '#007AFF'],
          
          // 特殊效果
          glowEffect: 'rgba(175, 82, 222, 0.30)',
          shimmerEffect: 'rgba(255, 255, 255, 0.15)',
          blurOverlay: 'rgba(255, 45, 146, 0.75)'
        }
      },
      {
        id: 'appleGreen',
        name: 'appleGreen',
        displayName: '苹果自然绿',
        description: '苹果自然绿主题，清新活力',
        backgroundColor: '#34C759',
        textColor: '#FFFFFF',
        primaryColor: '#00D4AA',
        cardBackgroundColor: '#2FB84F',
        borderColor: 'rgba(255, 255, 255, 0.12)',
        shadowColor: 'rgba(0, 0, 0, 0.20)',
        errorColor: '#FF3B30',
        glassmorphism: {
          // 基础背景 - 苹果自然绿色系
          backgroundPrimary: '#34C759',
          backgroundSecondary: '#2FB84F',
          backgroundTertiary: '#2AA946',
          
          // 玻璃表面 - 自然绿透明度
          surfaceUltraLight: 'rgba(52, 199, 89, 0.60)',
          surfaceLight: 'rgba(47, 184, 79, 0.75)',
          surfaceMedium: 'rgba(42, 169, 70, 0.85)',
          surfaceStrong: 'rgba(37, 154, 61, 0.95)',
          surfaceOpaque: '#2FB84F',
          
          // 边框 - 自然绿边框
          borderSubtle: 'rgba(255, 255, 255, 0.08)',
          borderLight: 'rgba(255, 255, 255, 0.12)',
          borderMedium: 'rgba(255, 255, 255, 0.18)',
          borderStrong: 'rgba(255, 255, 255, 0.25)',
          borderGlow: 'rgba(0, 212, 170, 0.35)',
          
          // 阴影 - 自然绿阴影
          shadowSubtle: 'rgba(0, 0, 0, 0.10)',
          shadowSoft: 'rgba(0, 0, 0, 0.15)',
          shadowMedium: 'rgba(0, 0, 0, 0.20)',
          shadowStrong: 'rgba(0, 0, 0, 0.25)',
          shadowDeep: 'rgba(0, 0, 0, 0.30)',
          shadowGlow: 'rgba(0, 212, 170, 0.25)',
          
          // 强调色 - 自然绿主题强调色
          accentPrimary: '#00D4AA',    // 苹果青绿
          accentSecondary: '#007AFF',  // 苹果蓝
          accentTertiary: '#5856D6',   // 苹果紫
          accentSuccess: '#34C759',    // 苹果绿
          accentWarning: '#FF9500',    // 苹果橙
          accentError: '#FF3B30',      // 苹果红
          
          // 渐变 - 自然绿渐变
          gradientPrimary: ['#34C759', '#00D4AA'],
          gradientSecondary: ['#2FB84F', '#2AA946'],
          gradientAccent: ['#00D4AA', '#007AFF'],
          gradientWarm: ['#34C759', '#FF9500'],
          gradientCool: ['#00D4AA', '#5856D6'],
          
          // 特殊效果
          glowEffect: 'rgba(0, 212, 170, 0.30)',
          shimmerEffect: 'rgba(255, 255, 255, 0.15)',
          blurOverlay: 'rgba(52, 199, 89, 0.75)'
        }
      }
    ];
  }

  // 获取所有可用主题
  async getAvailableThemes(): Promise<ThemeConfig[]> {
    return this.getAppleInspiredThemes();
  }

  // 兼容旧接口 - 获取所有主题
  async getAllThemes(): Promise<ThemeConfig[]> {
    return this.getAppleInspiredThemes();
  }

  // 获取当前主题
  async getCurrentTheme(): Promise<ThemeConfig> {
    return this.currentTheme;
  }

  // 兼容旧接口 - 获取当前主题ID
  async getCurrentThemeId(): Promise<string> {
    return this.currentTheme.id;
  }

  // 切换主题
  async switchTheme(themeName: string): Promise<void> {
    const themes = this.getAppleInspiredThemes();
    const targetTheme = themes.find(theme => theme.name === themeName || theme.id === themeName);
    
    if (targetTheme) {
      this.currentTheme = targetTheme;
      await this.saveThemePreference(themeName);
      this.notifyThemeChange();
    }
  }

  // 兼容旧接口 - 设置主题
  async setTheme(themeId: string): Promise<void> {
    await this.switchTheme(themeId);
  }

  // 主题变更监听器管理
  addThemeChangeListener(listener: () => void): void {
    this.themeChangeListeners.push(listener);
  }

  removeThemeChangeListener(listener: () => void): void {
    const index = this.themeChangeListeners.indexOf(listener);
    if (index > -1) {
      this.themeChangeListeners.splice(index, 1);
    }
  }

  private notifyThemeChange(): void {
    this.themeChangeListeners.forEach(listener => listener());
  }

  // 保存主题偏好设置
  private async saveThemePreference(themeName: string): Promise<void> {
    try {
      if (!this.preferences) {
        this.preferences = await preferences.getPreferences(getContext(), 'theme_preferences');
      }
      await this.preferences.put('selected_theme', themeName);
      await this.preferences.flush();
    } catch (error) {
      console.error('保存主题偏好失败:', error);
    }
  }

  // 加载主题偏好设置
  async loadThemePreference(): Promise<void> {
    try {
      if (!this.preferences) {
        this.preferences = await preferences.getPreferences(getContext(), 'theme_preferences');
      }
      const savedTheme = await this.preferences.get('selected_theme', 'appleClassic') as string;
      await this.switchTheme(savedTheme);
    } catch (error) {
      console.error('加载主题偏好失败:', error);
    }
  }

  // 获取主题预览色彩
  getThemePreviewColors(themeName: string): ThemePreviewColors {
    const themes = this.getAppleInspiredThemes();
    const theme = themes.find(t => t.name === themeName || t.id === themeName);
    
    if (!theme) {
      return { primary: '#007AFF', secondary: '#5856D6', accent: '#FF9500' };
    }
    
    return {
      primary: theme.glassmorphism.accentPrimary,
      secondary: theme.glassmorphism.accentSecondary,
      accent: theme.glassmorphism.accentTertiary
    };
  }
}

// 默认主题配置常量 - 苹果经典主题
export const DEFAULT_THEME_CONFIG: ThemeConfig = {
  id: 'appleClassic',
  name: 'appleClassic',
  displayName: '苹果经典',
  description: '苹果经典浅色主题，清新优雅',
  backgroundColor: '#F2F2F7',
  textColor: '#1C1C1E',
  primaryColor: '#007AFF',
  cardBackgroundColor: '#FFFFFF',
  borderColor: 'rgba(0, 0, 0, 0.08)',
  shadowColor: 'rgba(0, 0, 0, 0.08)',
  errorColor: '#FF3B30',
  glassmorphism: {
    backgroundPrimary: '#F2F2F7',
    backgroundSecondary: '#FFFFFF',
    backgroundTertiary: '#E5E5EA',
    
    surfaceUltraLight: 'rgba(255, 255, 255, 0.60)',
    surfaceLight: 'rgba(255, 255, 255, 0.75)',
    surfaceMedium: 'rgba(255, 255, 255, 0.85)',
    surfaceStrong: 'rgba(255, 255, 255, 0.95)',
    surfaceOpaque: '#FFFFFF',
    
    borderSubtle: 'rgba(0, 0, 0, 0.04)',
    borderLight: 'rgba(0, 0, 0, 0.08)',
    borderMedium: 'rgba(0, 0, 0, 0.12)',
    borderStrong: 'rgba(0, 0, 0, 0.18)',
    borderGlow: 'rgba(0, 122, 255, 0.25)',
    
    shadowSubtle: 'rgba(0, 0, 0, 0.02)',
    shadowSoft: 'rgba(0, 0, 0, 0.04)',
    shadowMedium: 'rgba(0, 0, 0, 0.08)',
    shadowStrong: 'rgba(0, 0, 0, 0.12)',
    shadowDeep: 'rgba(0, 0, 0, 0.16)',
    shadowGlow: 'rgba(0, 122, 255, 0.15)',
    
    accentPrimary: '#007AFF',
    accentSecondary: '#5856D6',
    accentTertiary: '#FF9500',
    accentSuccess: '#34C759',
    accentWarning: '#FF9500',
    accentError: '#FF3B30',
    
    gradientPrimary: ['#007AFF', '#5856D6'],
    gradientSecondary: ['#FFFFFF', '#F2F2F7'],
    gradientAccent: ['#FF9500', '#FF6B35'],
    gradientWarm: ['#FF9500', '#FF6B6B'],
    gradientCool: ['#007AFF', '#00D4AA'],
    
    glowEffect: 'rgba(0, 122, 255, 0.20)',
    shimmerEffect: 'rgba(255, 255, 255, 0.30)',
    blurOverlay: 'rgba(242, 242, 247, 0.80)'
  }
};

// 导出主题配置供其他组件使用
export const PREMIUM_THEME_CONFIGS = ThemeService.getInstance().getAvailableThemes(); 