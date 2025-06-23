import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../../services/ThemeService';
import { NextTaskItem } from '../../types/CommonTypes';

// 苹果风格的下一个任务对话框组件
@CustomDialog
export struct NextTaskDialog {
  @State countdown: number = 5;
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  private countdownTimer: number = -1;
  private themeService: ThemeService = ThemeService.getInstance();
  controller?: CustomDialogController;
  nextItem: NextTaskItem = {
    id: 0,
    title: '',
    isCompleted: false,
    orderIndex: 0,
    collectionId: 0,
    createTime: ''
  } as NextTaskItem;
  nextIndex: number = 0;
  actualTotalTasks: number = 0;
  onStart: () => void = () => {
  };
  onCancel: () => void = () => {
  };

  async aboutToAppear() {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('NextTaskDialog加载主题失败:', error);
    }
    this.startCountdown();
  }

  aboutToDisappear() {
    this.clearCountdown();
  }

  startCountdown() {
    console.info('NextTaskDialog: 开始5秒倒计时');
    this.countdownTimer = setInterval(() => {
      this.countdown--;
      console.info(`NextTaskDialog: 倒计时剩余 ${this.countdown} 秒`);
      if (this.countdown <= 0) {
        console.info('NextTaskDialog: 倒计时结束，准备开始下一个任务');
        this.clearCountdown();
        this.onStart();
      }
    }, 1000);
  }

  clearCountdown() {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }
  }

  build() {
    Column() {
      // 标题区域
      Column() {
        Text('🎯')
          .fontSize(64)
          .margin({ bottom: 20 })
        Text('准备下一个任务')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.textColor)
          .margin({ bottom: 8 })
        Text('即将开始新的专注时间')
          .fontSize(16)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.6)
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 32 })

      // 任务信息区域 - 苹果风格玻璃卡片
      Column({ space: 16 }) {
        Row() {
          Text('⚡ 即将开始：')
            .fontSize(16)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.7)
          Text(this.nextItem.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTheme.textColor)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')

        Row() {
          Text('⏱️ 专注时长：')
            .fontSize(16)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.7)
          Text('25分钟')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTheme.glassmorphism.accentPrimary)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('📊 进度：')
            .fontSize(16)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.7)
          Text(`${this.nextIndex + 1}/${this.actualTotalTasks}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTheme.glassmorphism.accentSecondary)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(24)
      .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
      .borderRadius(20)
      .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
      .shadow({
        radius: 16,
        color: this.currentTheme.glassmorphism.shadowSoft,
        offsetX: 0,
        offsetY: 8
      })

      // 倒计时区域
      Column() {
        Text(`${this.countdown}`)
          .fontSize(80)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.glassmorphism.accentPrimary)
          .textShadow({
            radius: 24,
            color: this.currentTheme.glassmorphism.accentPrimary + '40',
            offsetX: 0,
            offsetY: 0
          })
        Text('秒后自动开始下一个任务')
          .fontSize(14)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.6)
          .margin({ top: 8 })
      }
      .margin({ top: 32, bottom: 32 })
      .alignItems(HorizontalAlign.Center)

      // 操作按钮区域
      Row({ space: 16 }) {
        Button('🚫 结束序列')
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTheme.glassmorphism.accentSecondary)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
          .border({ width: 2, color: this.currentTheme.glassmorphism.accentSecondary })
          .borderRadius(25)
          .shadow({
            radius: 12,
            color: this.currentTheme.glassmorphism.accentSecondary + '30',
            offsetX: 0,
            offsetY: 4
          })
          .onClick(() => {
            this.clearCountdown();
            this.onCancel();
          })

        Button('🚀 立即开始')
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor(this.currentTheme.glassmorphism.accentPrimary)
          .borderRadius(25)
          .shadow({
            radius: 12,
            color: this.currentTheme.glassmorphism.accentPrimary + '40',
            offsetX: 0,
            offsetY: 4
          })
          .onClick(() => {
            this.clearCountdown();
            this.onStart();
          })
      }
      .width('100%')
    }
    .width(320)
    .backgroundColor(this.currentTheme.backgroundColor + 'F8')
    .borderRadius(24)
    .padding(32)
    .backdropBlur(15)
    .border({ 
      width: 0.5, 
      color: this.currentTheme.glassmorphism.accentPrimary + '40' 
    })
    .shadow({
      radius: 25,
      color: this.currentTheme.glassmorphism.accentPrimary + '30',
      offsetX: 0,
      offsetY: 10
    })
    .linearGradient({
      angle: 135,
      colors: [
        [this.currentTheme.backgroundColor + 'F5', 0.0],
        [this.currentTheme.glassmorphism.surfaceLight + 'F8', 1.0]
      ]
    })
  }
} 