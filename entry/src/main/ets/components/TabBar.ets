import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';

interface TabItem {
  icon: string;
  text: string;
  path: string;
}

@Component
export struct TabBar {
  @Prop currentIndex: number = 0;
  @Prop isLocked?: boolean = false;  // 添加锁机状态属性
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;

  private themeService: ThemeService = ThemeService.getInstance();
  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('TabBar主题更新失败:', error);
    }
  };

  private tabs: TabItem[] = [
    { icon: '📅', text: '待办', path: 'pages/Index' },
    { icon: '📝', text: '待办管理', path: 'pages/TodoPage' },
    { icon: '🔒', text: '锁机', path: 'pages/LockPage' },
    { icon: '📊', text: '统计数据', path: 'pages/StatisticsPage' },
    { icon: '👤', text: '我的', path: 'pages/Profile' }
  ];

  @Builder
  TabBuilder(index: number, icon: string, text: string) {
    Column() {
      Text(icon)
        .fontSize(24)
        .fontColor(this.currentIndex === index ? this.currentTheme.primaryColor : this.currentTheme.textColor)
        .opacity(this.currentIndex === index ? 1.0 : 0.6)
      Text(text)
        .fontSize(12)
        .margin({ top: 4 })
        .fontColor(this.currentIndex === index ? this.currentTheme.primaryColor : this.currentTheme.textColor)
        .opacity(this.currentIndex === index ? 1.0 : 0.6)
    }
    .width('20%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.currentIndex !== index) {
        // 检查是否在锁机状态
        if (this.isLocked && this.currentIndex === 2) {
          promptAction.showToast({ 
            message: '请先解除锁机状态再切换页面',
            duration: 2000
          });
          return;
        }
        console.info(`正在跳转到: ${this.tabs[index].path}`);
        router.replaceUrl({
          url: this.tabs[index].path,
          params: {}
        }).then(() => {
          console.info(`成功跳转到: ${this.tabs[index].path}`);
        }).catch((err: Error) => {
          console.error(`导航失败: ${err.message}`);
          promptAction.showToast({ 
            message: `页面跳转失败: ${err.message}`,
            duration: 2000
          });
        });
      }
    })
  }

  async aboutToAppear() {
    // 注册主题变化监听器
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    // 加载当前主题
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('TabBar加载主题失败:', error);
    }
  }

  aboutToDisappear() {
    // 注销主题变化监听器
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  build() {
    Row() {
      ForEach(this.tabs, (item: TabItem, index: number) => {
        this.TabBuilder(index, item.icon, item.text)
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor(this.currentTheme.cardBackgroundColor)
    .justifyContent(FlexAlign.SpaceEvenly)
    .border({ width: { top: 0.5 }, color: this.currentTheme.borderColor })
    .shadow({ radius: 4, color: this.currentTheme.shadowColor, offsetY: -2 })
    .zIndex(1)
  }
}