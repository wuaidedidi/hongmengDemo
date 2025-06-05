import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TabBar } from '../components/TabBar';
import { ApiService } from '../services/ApiService';
import { ThemeService, ThemeConfig } from '../services/ThemeService';

@Entry
@Component
struct Profile {
  @State showLogoutConfirm: boolean = false;
  @State currentTheme: ThemeConfig = {
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
  private apiService = ApiService.getInstance();
  private themeService = ThemeService.getInstance();

  private themeChangeListener = (theme: ThemeConfig) => {
    this.currentTheme = theme;
  };

  async aboutToAppear() {
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    this.currentTheme = await this.themeService.getCurrentTheme();
  }

  aboutToDisappear() {
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  handleLogout() {
    this.showLogoutConfirm = true;
  }

  async confirmLogout() {
    // 执行登出操作
    this.showLogoutConfirm = false;
    await this.apiService.clearAuth();
    promptAction.showToast({ message: '已退出登录' });
    router.pushUrl({ url: 'pages/Index' });
  }
  @Builder
  MenuItem(icon: string, title: string, onClick: () => void) {
    Row() {
      Row() {
        Text(icon)
          .fontSize(20)
          .margin({ right: 12 })
        Text(title)
          .fontSize(16)
          .fontColor(this.currentTheme.textColor)
      }
      Text('>')
        .fontSize(16)
        .fontColor(this.currentTheme.textColor)
        .opacity(0.6)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.currentTheme.cardBackgroundColor)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(onClick)
  }

  build() {
    Stack() {
      Column() {
        // 用户信息区域
        Column() {
          Text('👤')
            .fontSize(48)
            .fontColor(Color.White)
            .margin({ bottom: 16 })
          Text('用户名')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
            .fontColor(Color.White)
          Text('加入时间：2024-01-01')
            .fontSize(14)
            .opacity(0.8)
            .fontColor(Color.White)
        }
        .width('100%')
        .padding({ top: 40, bottom: 24 })
        .backgroundColor(this.currentTheme.primaryColor)
        .alignItems(HorizontalAlign.Center)

        // 菜单列表
        Column() {
          this.MenuItem('⚙️', '设置', () => {
            promptAction.showToast({ message: '设置功能开发中...' });
          })
          Divider().color(this.currentTheme.borderColor).height(1)

          this.MenuItem('🔔', '通知设置', () => {
            promptAction.showToast({ message: '通知设置功能开发中...' });
          })
          Divider().color(this.currentTheme.borderColor).height(1)

          this.MenuItem('🎨', '主题设置', () => {
            router.pushUrl({ url: 'pages/ThemeSettingsPage' });
          })
          Divider().color(this.currentTheme.borderColor).height(1)

          this.MenuItem('🔒', '隐私设置', () => {
            promptAction.showToast({ message: '隐私设置功能开发中...' });
          })
          Divider().color(this.currentTheme.borderColor).height(1)

          this.MenuItem('❓', '帮助与反馈', () => {
            promptAction.showToast({ message: '帮助与反馈功能开发中...' });
          })
          Divider().color(this.currentTheme.borderColor).height(1)

          this.MenuItem('ℹ️', '关于', () => {
            promptAction.showToast({ message: '关于功能开发中...' });
          })
          Divider().color(this.currentTheme.borderColor).height(1)

          // 退出登录选项
          Row() {
            Row() {
              Text('⚠️')
                .fontSize(20)
                .margin({ right: 12 })
              Text('退出登录')
                .fontSize(16)
                .fontColor(this.currentTheme.errorColor)
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)

            Text('🚪')
              .fontSize(18)
              .fontColor(this.currentTheme.errorColor)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.currentTheme.cardBackgroundColor)
          .border({ width: 1, color: this.currentTheme.errorColor, radius: 8 })
          .margin({ top: 8, left: 16, right: 16 })
          .onClick(() => {
            this.handleLogout();
          })
        }
        .margin({ top: 16 })
        .layoutWeight(1)
        .backgroundColor(this.currentTheme.cardBackgroundColor)
        .padding({ top: 8, bottom: 8 })

        // 底部导航栏
        TabBar({ currentIndex: 4 })
      }
      .width('100%')
      .height('100%')

      // 退出登录确认对话框
      if (this.showLogoutConfirm) {
        Column() {
          Column() {
            Text('确认退出')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentTheme.textColor)
              .margin({ bottom: 16 })

            Text('确定要退出登录吗？')
              .fontSize(14)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.7)
              .margin({ bottom: 24 })

            Row() {
              Button('取消')
                .backgroundColor(this.currentTheme.backgroundColor)
                .fontColor(this.currentTheme.textColor)
                .layoutWeight(1)
                .onClick(() => {
                  this.showLogoutConfirm = false;
                })

              Blank().width(12)

              Button('确定')
                .backgroundColor(this.currentTheme.errorColor)
                .fontColor(Color.White)
                .layoutWeight(1)
                .onClick(() => {
                  this.confirmLogout();
                })
            }
            .width('100%')
          }
          .width(280)
          .padding(24)
          .backgroundColor(this.currentTheme.cardBackgroundColor)
          .borderRadius(12)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.currentTheme.shadowColor)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.backgroundColor)
  }
}