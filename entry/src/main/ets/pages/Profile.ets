import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TabBar } from '../components/TabBar';
import { ApiService } from '../services/ApiService';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';

// 菜单项接口
interface MenuItem {
  icon: string;
  title: string;
  onClick: () => void;
}

@Entry
@Component
struct Profile {
  @State showLogoutConfirm: boolean = false;
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  @State username: string = '';
  private apiService = ApiService.getInstance();
  private themeService = ThemeService.getInstance();

  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('Profile主题更新失败:', error);
    }
  };

  async aboutToAppear() {
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    // 首先加载保存的主题偏好设置
    await this.themeService.loadThemePreference();
    this.currentTheme = await this.themeService.getCurrentTheme();
    // 获取用户名
    this.username = await this.apiService.getUsername() || '用户';
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

  // 苹果风格的菜单项组件
  @Builder
  MenuCard(title: string, items: MenuItem[]) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentTheme.textColor)
        .opacity(0.6)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 12 })

      Column() {
        ForEach(items, (item: MenuItem, index: number) => {
          Row() {
            Text(item.icon)
              .fontSize(20)
              .width(32)
              .textAlign(TextAlign.Center)
            
            Text(item.title)
              .fontSize(16)
              .fontColor(this.currentTheme.textColor)
              .layoutWeight(1)
              .margin({ left: 12 })
            
            Text('›')
              .fontSize(18)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.3)
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .onClick(item.onClick)

          if (index < items.length - 1) {
            Divider()
              .color(this.currentTheme.glassmorphism.borderLight)
              .strokeWidth(0.5)
              .margin({ left: 60, right: 16 })
          }
        }, (item: MenuItem, index: number) => `${item.title}_${index}`)
      }
      .width('100%')
      .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
      .borderRadius(16)
      .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
      .shadow({
        radius: 8,
        color: this.currentTheme.glassmorphism.shadowSoft,
        offsetX: 0,
        offsetY: 4
      })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 苹果风格的统计卡片
  @Builder
  StatCard(icon: string, title: string, value: string, subtitle: string) {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 8 })
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentTheme.glassmorphism.accentPrimary)
        .margin({ bottom: 4 })
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentTheme.textColor)
        .margin({ bottom: 2 })
      Text(subtitle)
        .fontSize(12)
        .fontColor(this.currentTheme.textColor)
        .opacity(0.6)
    }
    .width('100%')
    .height(120)
    .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
    .borderRadius(16)
    .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
    .shadow({
      radius: 8,
      color: this.currentTheme.glassmorphism.shadowSoft,
      offsetX: 0,
      offsetY: 4
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Stack() {
      Column() {
        // 苹果风格的用户信息区域
        Column() {
          // 用户头像和基本信息
          Column() {
            // 头像
            Stack() {
              Circle({ width: 80, height: 80 })
                .fill(this.currentTheme.glassmorphism.accentPrimary)
                .shadow({
                  radius: 16,
                  color: this.currentTheme.glassmorphism.accentPrimary + '40',
                  offsetX: 0,
                  offsetY: 8
                })
              
              Text('👤')
                .fontSize(40)
                .fontColor('#FFFFFF')
            }
            .margin({ bottom: 16 })

            // 用户名
            Text(this.username)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentTheme.textColor)
              .margin({ bottom: 8 })

            // 加入时间
            Text('专注达人 · 2024年加入')
              .fontSize(14)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.6)
              .margin({ bottom: 24 })

            // 统计数据
            Row({ space: 16 }) {
              this.StatCard('🎯', '专注次数', '42', '本周 +8')
              this.StatCard('⏰', '专注时长', '18h', '本周 +3h')
              this.StatCard('🔥', '连续天数', '7', '最长 15天')
            }
            .width('100%')
          }
          .width('100%')
          .padding(24)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
          .borderRadius(20)
          .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
          .shadow({
            radius: 16,
            color: this.currentTheme.glassmorphism.shadowMedium,
            offsetX: 0,
            offsetY: 8
          })
          .margin({ bottom: 32 })
        }

        // 主要内容区域
        Scroll() {
          Column() {
            // 个性化设置
            this.MenuCard('个性化', [
              {
                icon: '🎨',
                title: '主题设置',
                onClick: (): void => {
                  router.pushUrl({ url: 'pages/ThemeSettingsPage' });
                }
              } as MenuItem,
              {
                icon: '🔔',
                title: '通知设置',
                onClick: (): void => {
                  promptAction.showToast({ message: '通知设置功能开发中...' });
                }
              } as MenuItem,
              {
                icon: '🌙',
                title: '夜间模式',
                onClick: (): void => {
                  promptAction.showToast({ message: '夜间模式功能开发中...' });
                }
              } as MenuItem
            ])

            // 应用设置
            this.MenuCard('应用设置', [
              {
                icon: '⚙️',
                title: '通用设置',
                onClick: (): void => {
                  promptAction.showToast({ message: '通用设置功能开发中...' });
                }
              } as MenuItem,
              {
                icon: '🔒',
                title: '隐私与安全',
                onClick: (): void => {
                  promptAction.showToast({ message: '隐私设置功能开发中...' });
                }
              } as MenuItem,
              {
                icon: '📊',
                title: '数据统计',
                onClick: (): void => {
                  router.pushUrl({ url: 'pages/StatisticsPage' });
                }
              } as MenuItem
            ])

            // 支持与帮助
            this.MenuCard('支持', [
              {
                icon: '❓',
                title: '帮助中心',
                onClick: (): void => {
                  promptAction.showToast({ message: '帮助中心功能开发中...' });
                }
              } as MenuItem,
              {
                icon: '💬',
                title: '意见反馈',
                onClick: (): void => {
                  promptAction.showToast({ message: '意见反馈功能开发中...' });
                }
              } as MenuItem,
              {
                icon: 'ℹ️',
                title: '关于应用',
                onClick: (): void => {
                  promptAction.showToast({ message: '专注待办 v1.0.0' });
                }
              } as MenuItem
            ])

            // 退出登录按钮
            Button() {
              Row() {
                Text('⚠️')
                  .fontSize(20)
                  .margin({ right: 12 })
                Text('退出登录')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.currentTheme.glassmorphism.accentSecondary)
              }
            }
            .width('100%')
            .height(52)
            .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
            .borderRadius(16)
            .border({ 
              width: 2, 
              color: this.currentTheme.glassmorphism.accentSecondary 
            })
            .shadow({
              radius: 8,
              color: this.currentTheme.glassmorphism.accentSecondary + '30',
              offsetX: 0,
              offsetY: 4
            })
            .onClick(() => {
              this.handleLogout();
            })
            .margin({ bottom: 120 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // 底部导航栏
        TabBar({ currentIndex: 4 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.currentTheme.backgroundColor)
      .padding({ top: 20 })

      // 苹果风格的退出登录确认对话框
      if (this.showLogoutConfirm) {
        Column() {
          Column() {
            Text('⚠️')
              .fontSize(48)
              .margin({ bottom: 20 })
            
            Text('确认退出登录？')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentTheme.textColor)
              .margin({ bottom: 8 })
            
            Text('退出后需要重新登录才能使用')
              .fontSize(14)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.6)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 32 })

            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .height(44)
                .fontSize(16)
                .fontColor(this.currentTheme.textColor)
                .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
                .borderRadius(22)
                .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
                .onClick(() => {
                  this.showLogoutConfirm = false;
                })

              Button('确认退出')
                .layoutWeight(1)
                .height(44)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .backgroundColor(this.currentTheme.glassmorphism.accentSecondary)
                .borderRadius(22)
                .onClick(() => {
                  this.confirmLogout();
                })
            }
            .width('100%')
          }
          .width(300)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
          .borderRadius(20)
          .padding(24)
          .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
          .shadow({
            radius: 24,
            color: this.currentTheme.glassmorphism.shadowStrong,
            offsetX: 0,
            offsetY: 12
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.showLogoutConfirm = false;
        })
      }
    }
  }
}