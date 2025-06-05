import preferences from '@ohos.data.preferences';

const PREFERENCES_NAME = 'theme_preferences';
const THEME_KEY = 'selected_theme';

// 主题配置接口
export interface ThemeConfig {
  id: string;
  name: string;
  primaryColor: string;
  backgroundColor: string;
  textColor: string;
  cardBackgroundColor: string;
  borderColor: string;
  shadowColor: string;
  errorColor: string;
}

// 主题配置类
class ThemeConfigs {
  light: ThemeConfig = {
    id: 'light',
    name: '浅色主题',
    primaryColor: '#007AFF',
    backgroundColor: '#FFFFFF',
    textColor: '#000000',
    cardBackgroundColor: '#F8F8F8',
    borderColor: '#E0E0E0',
    shadowColor: 'rgba(0, 0, 0, 0.1)',
    errorColor: '#FF3B30'
  };
  
  dark: ThemeConfig = {
    id: 'dark',
    name: '深色主题',
    primaryColor: '#0A84FF',
    backgroundColor: '#1C1C1E',
    textColor: '#FFFFFF',
    cardBackgroundColor: '#2C2C2E',
    borderColor: '#3A3A3C',
    shadowColor: 'rgba(255, 255, 255, 0.1)',
    errorColor: '#FF453A'
  };
  
  auto: ThemeConfig = {
    id: 'auto',
    name: '跟随系统',
    primaryColor: '#007AFF',
    backgroundColor: '#F2F2F7',
    textColor: '#000000',
    cardBackgroundColor: '#FFFFFF',
    borderColor: '#E0E0E0',
    shadowColor: 'rgba(0, 0, 0, 0.1)',
    errorColor: '#FF3B30'
  };
  
  blue: ThemeConfig = {
    id: 'blue',
    name: '海洋蓝',
    primaryColor: '#0066CC',
    backgroundColor: '#F0F8FF',
    textColor: '#003366',
    cardBackgroundColor: '#E6F3FF',
    borderColor: '#B3D9FF',
    shadowColor: 'rgba(0, 102, 204, 0.2)',
    errorColor: '#CC0000'
  };
  
  green: ThemeConfig = {
    id: 'green',
    name: '森林绿',
    primaryColor: '#228B22',
    backgroundColor: '#F0FFF0',
    textColor: '#006400',
    cardBackgroundColor: '#E6FFE6',
    borderColor: '#B3FFB3',
    shadowColor: 'rgba(34, 139, 34, 0.2)',
    errorColor: '#DC143C'
  };
  
  purple: ThemeConfig = {
    id: 'purple',
    name: '梦幻紫',
    primaryColor: '#8A2BE2',
    backgroundColor: '#F8F0FF',
    textColor: '#4B0082',
    cardBackgroundColor: '#F0E6FF',
    borderColor: '#D9B3FF',
    shadowColor: 'rgba(138, 43, 226, 0.2)',
    errorColor: '#B22222'
  };
}

// 预定义主题配置
export const THEME_CONFIGS = new ThemeConfigs();

export class ThemeService {
  private static instance: ThemeService;
  private preferences: preferences.Preferences | null = null;
  private currentTheme: ThemeConfig = THEME_CONFIGS.light;
  private initPromise: Promise<void> | null = null;
  private themeChangeListeners: Array<(theme: ThemeConfig) => void> = [];

  private constructor() {
    this.initPromise = this.init();
  }

  static getInstance(): ThemeService {
    if (!ThemeService.instance) {
      ThemeService.instance = new ThemeService();
    }
    return ThemeService.instance;
  }

  private async init() {
    try {
      const context = getContext(this);
      this.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
      await this.loadCurrentTheme();
    } catch (error) {
      console.error('ThemeService初始化失败:', error);
    }
  }

  private async ensureInitialized() {
    if (this.initPromise) {
      await this.initPromise;
      this.initPromise = null;
    }
  }

  private async loadCurrentTheme() {
    if (this.preferences) {
      try {
        const themeId = await this.preferences.get(THEME_KEY, 'light') as string;
        this.currentTheme = ThemeService.getThemeConfig(themeId) || THEME_CONFIGS.light;
        console.info('加载主题:', this.currentTheme.name);
      } catch (error) {
        console.error('加载主题失败:', error);
        this.currentTheme = THEME_CONFIGS.light;
      }
    }
  }

  async getCurrentTheme(): Promise<ThemeConfig> {
    await this.ensureInitialized();
    return this.currentTheme;
  }

  async getCurrentThemeId(): Promise<string> {
    await this.ensureInitialized();
    return this.currentTheme.id;
  }

  async setTheme(themeId: string): Promise<boolean> {
    await this.ensureInitialized();
    
    const newTheme = ThemeService.getThemeConfig(themeId);
    if (!newTheme) {
      console.error('未知的主题ID:', themeId);
      return false;
    }

    try {
      if (this.preferences) {
        await this.preferences.put(THEME_KEY, themeId);
        await this.preferences.flush();
      }
      
      this.currentTheme = newTheme;
      console.info('主题切换成功:', newTheme.name);
      
      // 通知所有监听器
      this.notifyThemeChange(newTheme);
      
      return true;
    } catch (error) {
      console.error('保存主题失败:', error);
      return false;
    }
  }

  // 添加主题变化监听器
  addThemeChangeListener(listener: (theme: ThemeConfig) => void) {
    this.themeChangeListeners.push(listener);
  }

  // 移除主题变化监听器
  removeThemeChangeListener(listener: (theme: ThemeConfig) => void) {
    const index = this.themeChangeListeners.indexOf(listener);
    if (index > -1) {
      this.themeChangeListeners.splice(index, 1);
    }
  }

  // 通知主题变化
  private notifyThemeChange(theme: ThemeConfig) {
    this.themeChangeListeners.forEach(listener => {
      try {
        listener(theme);
      } catch (error) {
        console.error('主题变化监听器执行失败:', error);
      }
    });
  }

  // 获取所有可用主题
  getAllThemes(): ThemeConfig[] {
    return Object.values(THEME_CONFIGS);
  }

  // 获取主题配置的静态方法
  static getThemeConfig(themeId: string): ThemeConfig | undefined {
    switch (themeId) {
      case 'light':
        return THEME_CONFIGS.light;
      case 'dark':
        return THEME_CONFIGS.dark;
      case 'auto':
        return THEME_CONFIGS.auto;
      case 'blue':
        return THEME_CONFIGS.blue;
      case 'green':
        return THEME_CONFIGS.green;
      case 'purple':
        return THEME_CONFIGS.purple;
      default:
        return undefined;
    }
  }

  // 根据系统主题自动选择
  async setAutoTheme(): Promise<boolean> {
    // 这里可以根据系统设置来决定使用浅色还是深色主题
    // 目前简单返回浅色主题
    return await this.setTheme('light');
  }
}