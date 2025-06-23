import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';

// 时长选项接口
interface DurationOption {
  label: string;
  minutes: number;
  icon: string;
  description: string;
}

@Entry
@Component
struct LockPage {
  @State selectedDuration: number = 25; // 默认25分钟
  @State isLocked: boolean = false;
  @State remainingTime: number = 0;
  @State showConfirmDialog: boolean = false;
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  private intervalId: number = -1;
  private themeService = ThemeService.getInstance();

  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('LockPage主题更新失败:', error);
    }
  };

  async aboutToAppear() {
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    // 首先加载保存的主题偏好设置
    await this.themeService.loadThemePreference();
    this.currentTheme = await this.themeService.getCurrentTheme();
  }

  aboutToDisappear() {
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
    this.stopLock();
  }

  // 时长选项数据
  private getDurationOptions(): DurationOption[] {
    return [
      { label: '番茄时间', minutes: 25, icon: '🍅', description: '经典专注法' },
      { label: '短暂专注', minutes: 15, icon: '⚡', description: '快速集中' },
      { label: '深度专注', minutes: 45, icon: '🧠', description: '深入思考' },
      { label: '长时专注', minutes: 60, icon: '🎯', description: '持久专注' },
      { label: '超长专注', minutes: 90, icon: '🚀', description: '极限挑战' },
      { label: '自定义', minutes: 30, icon: '⚙️', description: '个性化时长' }
    ];
  }

  startLock() {
    this.showConfirmDialog = true;
  }

  confirmLock() {
    this.showConfirmDialog = false;
    this.isLocked = true;
    this.remainingTime = this.selectedDuration * 60;
    
    this.intervalId = setInterval(() => {
      if (this.remainingTime > 0) {
        this.remainingTime--;
      } else {
        this.completeLock();
      }
    }, 1000);

    promptAction.showToast({ message: `开始${this.selectedDuration}分钟锁机` });
  }

  stopLock() {
    this.isLocked = false;
    clearInterval(this.intervalId);
    this.remainingTime = 0;
  }

  completeLock() {
    this.stopLock();
    promptAction.showToast({ message: '锁机时间结束！' });
  }

  formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    } else {
      return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
  }

  getProgress(): number {
    const totalSeconds = this.selectedDuration * 60;
    return ((totalSeconds - this.remainingTime) / totalSeconds) * 100;
  }

  // 苹果风格的时长选择按钮
  @Builder
  DurationButton(option: DurationOption) {
    Column() {
      Text(option.icon)
        .fontSize(32)
        .margin({ bottom: 8 })
      
      Text(option.label)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentTheme.textColor)
        .margin({ bottom: 4 })
      
      Text(`${option.minutes}分钟`)
        .fontSize(14)
        .fontColor(this.selectedDuration === option.minutes ? '#FFFFFF' : this.currentTheme.glassmorphism.accentPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 4 })
      
      Text(option.description)
        .fontSize(12)
        .fontColor(this.selectedDuration === option.minutes ? '#FFFFFF' : this.currentTheme.textColor)
        .opacity(0.7)
    }
    .width('100%')
    .height(120)
    .backgroundColor(this.selectedDuration === option.minutes ? 
      this.currentTheme.glassmorphism.accentPrimary : 
      this.currentTheme.glassmorphism.surfaceLight)
    .borderRadius(16)
    .border({ 
      width: this.selectedDuration === option.minutes ? 2 : 1, 
      color: this.selectedDuration === option.minutes ? 
        this.currentTheme.glassmorphism.accentPrimary : 
        this.currentTheme.glassmorphism.borderLight 
    })
    .shadow({
      radius: this.selectedDuration === option.minutes ? 16 : 8,
      color: this.selectedDuration === option.minutes ? 
        this.currentTheme.glassmorphism.accentPrimary + '40' : 
        this.currentTheme.glassmorphism.shadowSoft,
      offsetX: 0,
      offsetY: this.selectedDuration === option.minutes ? 8 : 4
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.selectedDuration = option.minutes;
    })
  }

  // 确认对话框
  @Builder
  ConfirmDialog() {
    Column() {
      Text('🔒')
        .fontSize(48)
        .margin({ bottom: 20 })
      
      Text('确认开始锁机？')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentTheme.textColor)
        .margin({ bottom: 8 })
      
      Text(`将锁机 ${this.selectedDuration} 分钟`)
        .fontSize(16)
        .fontColor(this.currentTheme.glassmorphism.accentPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })
      
      Text('锁机期间无法使用手机')
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
            this.showConfirmDialog = false;
          })

        Button('开始锁机')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor(this.currentTheme.glassmorphism.accentPrimary)
          .borderRadius(22)
          .onClick(() => {
            this.confirmLock();
          })
      }
      .width('100%')
    }
    .width('300vp')
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

  build() {
    Stack() {
      if (!this.isLocked) {
        // 时长选择界面
        Column() {
          // 顶部导航栏
          Row() {
            Button() {
              Text('←')
                .fontSize(24)
                .fontColor(this.currentTheme.textColor)
            }
            .width(44)
            .height(44)
            .backgroundColor('transparent')
            .onClick(() => {
              router.replaceUrl({ url: 'pages/Index' });
            })

            Text('锁机专注')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentTheme.textColor)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            // 占位符保持居中
            Text('')
              .width(44)
              .height(44)
          }
          .width('100%')
          .height(60)
          .padding({ left: 20, right: 20 })

          // 主要内容区域
          Scroll() {
            Column() {
              // 标题区域
              Column() {
                Text('🔒')
                  .fontSize(64)
                  .margin({ bottom: 16 })
                
                Text('选择锁机时长')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.currentTheme.textColor)
                  .margin({ bottom: 8 })
                
                Text('选择专注时长，开始高效学习')
                  .fontSize(16)
                  .fontColor(this.currentTheme.textColor)
                  .opacity(0.6)
                  .textAlign(TextAlign.Center)
              }
              .alignItems(HorizontalAlign.Center)
              .margin({ bottom: 40 })

              // 时长选项 - 改为单列垂直布局
              Column({ space: 16 }) {
                ForEach(this.getDurationOptions(), (option: DurationOption) => {
                  this.DurationButton(option);
                }, (option: DurationOption) => option.label)
              }
              .width('100%')
              .margin({ bottom: 40 })

              // 开始按钮
              Button() {
                Row() {
                  Text('🚀')
                    .fontSize(20)
                    .margin({ right: 8 })
                  Text(`开始 ${this.selectedDuration} 分钟锁机`)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                }
              }
              .width('100%')
              .height(56)
              .backgroundColor(this.currentTheme.glassmorphism.accentPrimary)
              .borderRadius(28)
              .fontColor('#FFFFFF')
              .shadow({
                radius: 16,
                color: this.currentTheme.glassmorphism.accentPrimary + '40',
                offsetX: 0,
                offsetY: 8
              })
              .onClick(() => {
                this.startLock();
              })
              .margin({ bottom: 40 })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.currentTheme.backgroundColor)
      } else {
        // 锁机状态界面
        Column() {
          // 锁机状态显示
          Column() {
            Text('🔒')
              .fontSize(80)
              .margin({ bottom: 24 })
            
            Text('锁机中...')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentTheme.textColor)
              .margin({ bottom: 16 })

            // 圆形进度环
            Stack() {
              // 背景圆环
              Circle({ width: 200, height: 200 })
                .fill('transparent')
                .stroke(this.currentTheme.glassmorphism.borderLight)
                .strokeWidth(6)

              // 进度圆环
              Circle({ width: 200, height: 200 })
                .fill('transparent')
                .stroke(this.currentTheme.glassmorphism.accentPrimary)
                .strokeWidth(6)
                .strokeDashArray([this.getProgress() * 6.28, 628])
                .rotate({ angle: -90 })

              // 中心时间显示
              Column() {
                Text(this.formatTime(this.remainingTime))
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.currentTheme.textColor)
                  .margin({ bottom: 4 })

                Text('剩余时间')
                  .fontSize(14)
                  .fontColor(this.currentTheme.textColor)
                  .opacity(0.6)
              }
              .justifyContent(FlexAlign.Center)
            }
            .margin({ bottom: 40 })

            Text('专注学习中，请勿打扰')
              .fontSize(16)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.6)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 40 })

            Button('强制解锁')
              .width(200)
              .height(44)
              .fontSize(16)
              .fontColor(this.currentTheme.glassmorphism.accentSecondary)
              .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
              .borderRadius(22)
              .border({ width: 2, color: this.currentTheme.glassmorphism.accentSecondary })
              .onClick(() => {
                this.stopLock();
                promptAction.showToast({ message: '已强制解锁' });
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .padding(40)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.currentTheme.backgroundColor)
      }

      // 确认对话框
      if (this.showConfirmDialog) {
        Column() {
          this.ConfirmDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.showConfirmDialog = false;
        })
      }
    }
  }
}