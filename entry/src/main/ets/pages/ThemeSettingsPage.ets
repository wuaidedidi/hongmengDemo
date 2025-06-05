import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ThemeService, ThemeConfig, THEME_CONFIGS } from '../services/ThemeService';

// 主题选项接口
interface ThemeOption {
  id: string;
  name: string;
  description: string;
  icon: string;
}

@Entry
@Component
struct ThemeSettingsPage {
  @State currentTheme: string = 'light';
  @State isLoading: boolean = false;
  private themeService = ThemeService.getInstance();

  // 主题选项
  private themeOptions: ThemeOption[] = [
    {
      id: 'light',
      name: '浅色主题',
      description: '适合白天使用，护眼舒适',
      icon: '☀️'
    },
    {
      id: 'dark',
      name: '深色主题',
      description: '适合夜间使用，减少眼部疲劳',
      icon: '🌙'
    },
    {
      id: 'auto',
      name: '跟随系统',
      description: '根据系统设置自动切换主题',
      icon: '🔄'
    },
    {
      id: 'blue',
      name: '海洋蓝',
      description: '清新的蓝色主题',
      icon: '🌊'
    },
    {
      id: 'green',
      name: '森林绿',
      description: '自然的绿色主题',
      icon: '🌲'
    },
    {
      id: 'purple',
      name: '梦幻紫',
      description: '优雅的紫色主题',
      icon: '💜'
    }
    ];

  async aboutToAppear() {
    await this.loadCurrentTheme();
  }

  private async loadCurrentTheme() {
    try {
      this.currentTheme = await this.themeService.getCurrentThemeId();
      console.info('当前主题:', this.currentTheme);
    } catch (error) {
      console.error('加载主题失败:', error);
      this.currentTheme = 'light';
    }
  }



  async selectTheme(themeId: string) {
    if (this.isLoading) return;
    
    this.isLoading = true;
    
    try {
      const success = await this.themeService.setTheme(themeId);
      if (success) {
        this.currentTheme = themeId;
        
        const themeName = this.themeOptions.find(theme => theme.id === themeId)?.name || '未知主题';
        promptAction.showToast({
          message: `已切换到${themeName}`,
          duration: 2000
        });
        
        console.info('主题切换成功:', themeName);
      } else {
        throw new Error('主题切换失败');
      }
    } catch (error) {
      console.error('保存主题失败:', error);
      promptAction.showToast({
        message: '主题切换失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  ThemeOption(theme: ThemeOption) {
    Row() {
      // 主题图标
      Text(theme.icon)
        .fontSize(24)
        .margin({ right: 16 })

      // 主题信息
      Column() {
        Row() {
          Text(theme.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Blank()
          
          // 选中状态指示器
          if (this.currentTheme === theme.id) {
            Text('✓')
              .fontSize(18)
              .fontColor(ThemeService.getThemeConfig(theme.id)?.primaryColor || '#007AFF')
              .fontWeight(FontWeight.Bold)
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(theme.description)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 4 })
          .textAlign(TextAlign.Start)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 主题颜色预览
      Row({ space: 8 }) {
        Circle({ width: 16, height: 16 })
          .fill(ThemeService.getThemeConfig(theme.id)?.primaryColor || '#007AFF')
         Circle({ width: 16, height: 16 })
           .fill(ThemeService.getThemeConfig(theme.id)?.backgroundColor || '#FFFFFF')
           .stroke(ThemeService.getThemeConfig(theme.id)?.textColor || '#000000')
           .strokeWidth(1)
         Circle({ width: 16, height: 16 })
           .fill(ThemeService.getThemeConfig(theme.id)?.textColor || '#000000')
      }
      .margin({ top: 8 })
    }
    .width('100%')
    .height(80)
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.currentTheme === theme.id ? '#F0F8FF' : '#FFFFFF')
    .border({
      width: this.currentTheme === theme.id ? 2 : 1,
      color: this.currentTheme === theme.id ? (ThemeService.getThemeConfig(theme.id)?.primaryColor || '#007AFF') : '#E0E0E0',
      radius: 12
    })
    .margin({ left: 16, right: 16, bottom: 8 })
    .onClick(() => {
      if (!this.isLoading) {
        this.selectTheme(theme.id);
      }
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text('主题设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Text('')
          .width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Divider()
        .color('#E0E0E0')
        .height(1)

      // 主题选项列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#007AFF')
          
          Text('正在切换主题...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 说明文字
            Text('选择您喜欢的主题风格')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 16, bottom: 16, left: 16, right: 16 })
              .textAlign(TextAlign.Start)
              .width('100%')

            // 主题选项
            ForEach(this.themeOptions, (theme: ThemeOption) => {
              this.ThemeOption(theme)
            })

            // 底部说明
            Text('主题设置将在下次启动应用时完全生效')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 24, bottom: 32, left: 16, right: 16 })
              .textAlign(TextAlign.Center)
              .width('100%')
          }
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}