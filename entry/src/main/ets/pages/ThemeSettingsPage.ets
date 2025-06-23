import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ThemeService, ThemeConfig, PREMIUM_THEME_CONFIGS } from '../services/ThemeService';
import { ThemeAwareGlassCard, ThemeAwareGradientBackground, GlassmorphismStyles } from '../utils/GlassmorphismStyles';

// 主题预览样式接口
interface ThemePreviewStyle {
  backgroundColor: string;
  borderColor: string;
  shadowColor: string;
}

@Entry
@Component
struct ThemeSettingsPage {
  private themeService: ThemeService = ThemeService.getInstance();
  @State private availableThemes: ThemeConfig[] = [];
  @State private currentThemeId: string = '';

  async aboutToAppear() {
    // 首先加载保存的主题偏好设置
    await this.themeService.loadThemePreference();
    // 加载可用主题
    this.availableThemes = await this.themeService.getAllThemes();
    this.currentThemeId = await this.themeService.getCurrentThemeId();
  }

  // 切换主题
  private async switchToTheme(themeId: string): Promise<void> {
    try {
      await this.themeService.setTheme(themeId);
      this.currentThemeId = themeId;
    } catch (error) {
      console.error('切换主题失败:', error);
    }
  }

  // 获取主题预览样式
  private getThemePreviewStyle(theme: ThemeConfig): ThemePreviewStyle {
    return {
      backgroundColor: theme.backgroundColor,
      borderColor: theme.glassmorphism.accentPrimary,
      shadowColor: theme.glassmorphism.shadowMedium
    };
  }

  @Builder
  buildThemePreviewCard(theme: ThemeConfig) {
    Column({ space: 8 }) {
      // 主题预览区域
      Stack() {
        // 背景渐变
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 135,
            colors: [
              [theme.glassmorphism.gradientPrimary[0], 0],
              [theme.glassmorphism.gradientPrimary[1], 1]
            ]
          })
          .borderRadius(12)

        // 玻璃卡片预览
        Column({ space: 6 }) {
          Row({ space: 8 }) {
            // 小圆点 - 展示强调色
            Circle({ width: 8, height: 8 })
              .fill(theme.glassmorphism.accentPrimary)
            Circle({ width: 8, height: 8 })
              .fill(theme.glassmorphism.accentSecondary)
            Circle({ width: 8, height: 8 })
              .fill(theme.glassmorphism.accentTertiary)
          }

          // 模拟卡片
          Column()
            .width(60)
            .height(20)
            .backgroundColor(theme.glassmorphism.surfaceMedium)
            .borderRadius(6)
            .border({ width: 1, color: theme.glassmorphism.borderMedium })

          Column()
            .width(40)
            .height(12)
            .backgroundColor(theme.glassmorphism.surfaceLight)
            .borderRadius(4)
            .border({ width: 1, color: theme.glassmorphism.borderLight })
        }
        .padding(16)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height(120)

      // 主题信息
      Column({ space: 4 }) {
        Text(theme.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(theme.textColor)
          .textAlign(TextAlign.Center)

        Text(theme.description)
          .fontSize(12)
          .fontColor(theme.textColor)
          .opacity(0.7)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 选中状态指示
        if (this.currentThemeId === theme.id) {
          Row() {
            Text('✓')
              .fontSize(14)
              .fontColor(theme.glassmorphism.accentPrimary)
              .margin({ right: 4 })
            Text('当前主题')
              .fontSize(12)
              .fontColor(theme.glassmorphism.accentPrimary)
              .fontWeight(FontWeight.Medium)
          }
          .padding({ top: 4 })
        }
      }
      .width('100%')
      .padding({ left: 8, right: 8, bottom: 8 })
    }
    .width('100%')
    .backgroundColor(theme.glassmorphism.surfaceLight)
    .borderRadius(16)
    .border({ 
      width: this.currentThemeId === theme.id ? 2 : 1, 
      color: this.currentThemeId === theme.id ? 
        theme.glassmorphism.accentPrimary : 
        theme.glassmorphism.borderMedium 
    })
    .shadow({
      radius: this.currentThemeId === theme.id ? 20 : 12,
      color: this.currentThemeId === theme.id ? 
        theme.glassmorphism.accentPrimary + '30' : 
        theme.glassmorphism.shadowMedium,
      offsetX: 0,
      offsetY: this.currentThemeId === theme.id ? 8 : 6
    })
    .padding(12)
    .onClick(() => {
      this.switchToTheme(theme.id);
    })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  build() {
    Column() {
      ThemeAwareGradientBackground({ gradientType: 'primary' }) {
        Column() {
          // 顶部导航栏
          Row() {
            Button() {
              Text('←')
                .fontSize(20)
                .fontColor('#FFFFFF')
            }
            .type(ButtonType.Circle)
            .backgroundColor('rgba(255, 255, 255, 0.1)')
            .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
            .width(40)
            .height(40)
            .onClick(() => {
              router.back();
            })

            Text('主题设置')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .textShadow({
                radius: 8,
                color: 'rgba(255, 255, 255, 0.5)',
                offsetX: 0,
                offsetY: 0
              })
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            // 占位符保持对称
            Column()
              .width(40)
              .height(40)
          }
          .width('100%')
          .height(60)
          .padding({ left: 20, right: 20 })
          .backgroundColor('rgba(0, 0, 0, 0.2)')
          .border({ width: { bottom: 1 }, color: 'rgba(255, 255, 255, 0.1)' })

          // 主题说明
          Column() {
            Text('🎨 玻璃拟态主题')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .textShadow({
                radius: 12,
                color: 'rgba(255, 255, 255, 0.6)',
                offsetX: 0,
                offsetY: 0
              })
              .margin({ bottom: 8 })

            Text('每个主题都经过精心调配，提供独特的视觉体验')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .opacity(0.8)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 16 })

            Text('点击任意主题卡片即可切换')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.6)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding(20)

          // 主题网格
          Scroll() {
            Grid() {
              ForEach(this.availableThemes, (theme: ThemeConfig) => {
                GridItem() {
                  this.buildThemePreviewCard(theme)
                }
              }, (theme: ThemeConfig) => theme.id)
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(16)
            .columnsGap(16)
            .width('100%')
            .padding(20)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)

          // 底部说明
          Column() {
            Text('💡 提示')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ bottom: 8 })

            Text('主题将立即应用到整个应用，包括所有页面的玻璃拟态效果、颜色搭配和视觉风格。')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.7)
              .textAlign(TextAlign.Center)
              .lineHeight(18)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('rgba(0, 0, 0, 0.1)')
          .border({ width: { top: 1 }, color: 'rgba(255, 255, 255, 0.1)' })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}