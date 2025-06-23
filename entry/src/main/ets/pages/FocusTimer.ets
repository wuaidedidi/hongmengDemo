import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { FocusTimerParams } from '../models/FocusTimerParams';
import { ApiService } from '../services/ApiService';
import AudioPlayer from '../common/AudioPlayer';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';
import { NextTaskDialog } from '../components/dialogs/NextTaskDialog';
import { 
  FocusCompletionParams, 
  TaskLogInfo, 
  SoundOption, 
  NextTaskItem,
  FocusTimerRouterParams
} from '../types/CommonTypes';

// 类型用于实际传递给router的参数
type RouterParamsObject = Record<string, string | number | boolean>;



@Entry
@Component
struct FocusTimer {
  @State timerDuration: number = 25 * 60; // 默认25分钟
  @State remainingTime: number = 25 * 60;
  @State isRunning: boolean = false;
  @State isPaused: boolean = false;
  @State currentTask: string = '';
  @State showTaskDialog: boolean = false;
  @State showSoundSelector: boolean = false;
  @State selectedSound: string = 'forest';
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  @State showNextTaskDialog: boolean = false;
  @State showEarlyCompleteDialog: boolean = false;
  @State nextTaskName: string = '';
  @State isSequence: boolean = false;
  @State collectionId: string = '';
  @State subTaskId: string = '';
  @State currentSubTaskIndex: number = 0;
  @State totalSubTasksInCollection: number = 0;
  @State nextTaskItem: NextTaskItem = {
    id: 0,
    title: '',
    isCompleted: false,
    orderIndex: 0,
    collectionId: 0,
    createTime: ''
  };
  private intervalId: number = -1;
  private apiService = ApiService.getInstance();
  private audioPlayer = AudioPlayer;
  private themeService = ThemeService.getInstance();
  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('FocusTimer主题更新失败:', error);
    }
  };

  async aboutToAppear() {
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    // 首先加载保存的主题偏好设置
    await this.themeService.loadThemePreference();
    this.currentTheme = await this.themeService.getCurrentTheme();

    const params = router.getParams() as FocusTimerRouterParams;
    if (params) {
      this.timerDuration = params.time || 25 * 60;
      this.remainingTime = params.time || 25 * 60;
      this.currentTask = params.taskTitle || params.title || '专注任务';
      this.isSequence = params.isSequence || false;
      this.collectionId = String(params.collectionId || '');
      this.subTaskId = String(params.subTaskId || '');
      this.currentSubTaskIndex = params.currentSubTaskIndex || 0;
      this.totalSubTasksInCollection = params.totalSubTasksInCollection || 0;
    }
  }

  aboutToDisappear() {
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
    this.stopTimer();
    this.audioPlayer.stopBackgroundSound();
  }

  startTimer() {
    if (!this.isRunning && !this.isPaused) {
      this.isRunning = true;
      this.intervalId = setInterval(() => {
        if (this.remainingTime > 0) {
          this.remainingTime--;
        } else {
          this.completeTimer();
        }
      }, 1000);
    } else if (this.isPaused) {
      this.isPaused = false;
      this.isRunning = true;
      this.intervalId = setInterval(() => {
        if (this.remainingTime > 0) {
          this.remainingTime--;
        } else {
          this.completeTimer();
        }
      }, 1000);
    }
  }

  pauseTimer() {
    this.isPaused = true;
    this.isRunning = false;
    clearInterval(this.intervalId);
  }

  stopTimer() {
    this.isRunning = false;
    this.isPaused = false;
    clearInterval(this.intervalId);
    this.remainingTime = this.timerDuration;
  }

  // 提前完成功能
  showEarlyCompleteConfirm() {
    this.showEarlyCompleteDialog = true;
  }

  async earlyComplete() {
    this.showEarlyCompleteDialog = false;
    await this.completeTimer(true);
  }

  async completeTimer(isEarlyComplete: boolean = false) {
    this.stopTimer();

    // 播放完成音效
    try {
      this.audioPlayer.playCompletionSound();
    } catch (error) {
      console.error('播放完成音效失败:', error);
    }

    // 记录专注会话
    try {
      const actualDuration = isEarlyComplete ?
      Math.floor((this.timerDuration - this.remainingTime) / 60) :
      Math.floor(this.timerDuration / 60);

      await this.apiService.createFocusSession({
        durationMinutes: actualDuration,
        startTime: new Date(Date.now() - (this.timerDuration - this.remainingTime) * 1000).toISOString(),
        endTime: new Date().toISOString(),
        taskDescription: this.currentTask
      });

      // 如果是合集中的任务，更新任务状态
      if (this.isSequence && this.collectionId && this.subTaskId) {
        const collectionIdNum = parseInt(this.collectionId);
        const subTaskIdNum = parseInt(this.subTaskId);
        await this.apiService.toggleCollectionItemStatus(collectionIdNum, subTaskIdNum);

        // 检查是否还有下一个任务
        if (this.currentSubTaskIndex < this.totalSubTasksInCollection - 1) {
          this.showNextTaskDialog = true;
          return;
        }
      }
    } catch (error) {
      console.error('完成计时器时出错:', error);
    }

    const message = isEarlyComplete ? '提前完成专注！🎉' : '专注完成！';
    promptAction.showToast({ message: message });
    setTimeout(() => {
      router.back();
    }, 2000);
  }

  formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString()
        .padStart(2, '0')}`;
    } else {
      return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
  }

  getProgress(): number {
    return ((this.timerDuration - this.remainingTime) / this.timerDuration) * 100;
  }

  // 音效选项数据
  private getSoundOptions(): SoundOption[] {
    return [
      { name: '森林', file: 'forest', icon: '🌲' },
      { name: '雨声', file: 'rain', icon: '🌧️' },
      { name: '海浪', file: 'waves', icon: '🌊' },
      { name: '冥想', file: 'meditation', icon: '🧘' },
      { name: '钢琴', file: 'piano', icon: '🎹' },
      { name: '白噪音', file: 'whitenoise', icon: '🔊' }
    ];
  }

  async selectSound(soundFile: string) {
    this.selectedSound = soundFile;
    this.showSoundSelector = false;

    const soundName = this.getSoundOptions().find(s => s.file === soundFile)?.name || '未知音效';

    try {
      // 立即播放选中的音效 - 使用鸿蒙音频播放
      console.info(`用户选择音效: ${soundName} (${soundFile})`);

      // 异步播放，不阻塞UI
      this.audioPlayer.playBackgroundSound(soundFile).then(() => {
        console.info(`音效播放成功: ${soundName}`);
      }).catch((error: Error) => {
        console.warn(`音效播放失败: ${soundName}`, error);
      });

      // 立即显示切换成功的提示
      promptAction.showToast({ message: `已切换到${soundName}音效` });
      console.info(`音效切换完成: ${soundName} (${soundFile})`);
    } catch (error) {
      console.error('切换音效失败:', error);
      promptAction.showToast({ message: `已选择${soundName}音效` });
    }
  }

  // 开始下一个任务
  startNextTask() {
    console.info('开始下一个任务');
    // 重置计时器状态，开始下一个任务
    this.currentSubTaskIndex++;
    this.remainingTime = this.timerDuration;
    
    // 模拟从API获取下一个任务（这里简化处理）
    router.back({
      url: 'pages/TodoDetail',
      params: {
        action: 'taskCompleted',
        collectionId: this.collectionId,
        subTaskId: this.subTaskId,
        currentSubTaskIndex: this.currentSubTaskIndex
      }
    });
  }

  // 取消序列
  cancelSequence() {
    console.info('取消序列');
    router.back({
      url: 'pages/TodoDetail',
      params: {
        action: 'sequenceAborted',
        collectionId: this.collectionId,
        subTaskId: this.subTaskId
      }
    });
  }

  // 苹果风格的音效选择器
  @Builder
  SoundSelector() {
    Column() {
      Text('选择专注音效')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentTheme.textColor)
        .margin({ bottom: 24 })

      Grid() {
        ForEach(this.getSoundOptions(), (sound: SoundOption) => {
          GridItem() {
            Column() {
              Text(sound.icon)
                .fontSize(32)
                .margin({ bottom: 8 })
              Text(sound.name)
                .fontSize(14)
                .fontColor(this.selectedSound === sound.file ? '#FFFFFF' : this.currentTheme.textColor)
                .fontWeight(this.selectedSound === sound.file ? FontWeight.Bold : FontWeight.Medium)
                .textShadow(this.selectedSound === sound.file ? {
                  radius: 4,
                  color: '#00000040',
                  offsetX: 0,
                  offsetY: 1
                } : undefined)
            }
            .width('100%')
            .height(80)
            .linearGradient(this.selectedSound === sound.file ? {
              angle: 135,
              colors: [
                [this.currentTheme.glassmorphism.accentPrimary, 0.0],
                [this.currentTheme.glassmorphism.accentSecondary, 0.5],
                [this.currentTheme.glassmorphism.accentTertiary, 1.0]
              ]
            } : {
              angle: 135,
              colors: [
                [this.currentTheme.glassmorphism.surfaceLight, 0.0],
                [this.currentTheme.glassmorphism.surfaceMedium, 1.0]
              ]
            })
            .borderRadius(16)
            .border({
              width: this.selectedSound === sound.file ? 2 : 1,
              color: this.selectedSound === sound.file ?
              this.currentTheme.glassmorphism.accentPrimary :
              this.currentTheme.glassmorphism.borderLight
            })
            .shadow({
              radius: this.selectedSound === sound.file ? 12 : 6,
              color: this.selectedSound === sound.file ?
                this.currentTheme.glassmorphism.accentPrimary + '40' :
              this.currentTheme.glassmorphism.shadowSoft,
              offsetX: 0,
              offsetY: this.selectedSound === sound.file ? 4 : 2
            })
            .blur(this.selectedSound === sound.file ? 0.4 : 0.2) // 哑光效果
            .justifyContent(FlexAlign.Center)
            .onClick(async () => {
              // 添加触觉反馈
              try {
                await this.selectSound(sound.file);
              } catch (error) {
                console.error('选择音效失败:', error);
              }
            })
          }
        }, (sound: SoundOption) => sound.file)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .height(200)

      Button('取消')
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor(this.currentTheme.textColor)
        .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
        .borderRadius(22)
        .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
        .margin({ top: 24 })
        .onClick(() => {
          this.showSoundSelector = false;
        })
    }
    .width(320)
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



  // 提前完成确认对话框
  @Builder
  EarlyCompleteDialog() {
    Column() {
      Text('🏆')
        .fontSize(48)
        .margin({ bottom: 20 })

      Text('提前完成专注？')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentTheme.textColor)
        .margin({ bottom: 8 })

      Text(`已专注 ${this.formatTime(this.timerDuration - this.remainingTime)}`)
        .fontSize(16)
        .fontColor(this.currentTheme.glassmorphism.accentPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })

      Text('确认要结束当前专注吗？')
        .fontSize(14)
        .fontColor(this.currentTheme.textColor)
        .opacity(0.6)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 32 })

      Row({ space: 12 }) {
        Button('继续专注')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor(this.currentTheme.textColor)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
          .borderRadius(22)
          .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
          .onClick(() => {
            this.showEarlyCompleteDialog = false;
          })

        Button('完成')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor(this.currentTheme.glassmorphism.accentPrimary)
          .borderRadius(22)
          .onClick(() => {
            this.earlyComplete();
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
            if (this.isRunning) {
              // 如果正在运行，显示提前完成对话框
              this.showEarlyCompleteConfirm();
            } else {
              router.back();
            }
          })

          Text('专注计时')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.currentTheme.textColor)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button() {
            Text('🔊')
              .fontSize(20)
          }
          .width(44)
          .height(44)
          .backgroundColor('transparent')
          .onClick(() => {
            this.showSoundSelector = true;
          })
        }
        .width('100%')
        .height(60)
        .padding({ left: 20, right: 20 })

        // 主要内容区域
        Column() {
          // 任务名称
          Text(this.currentTask)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.currentTheme.textColor)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 40 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 圆形进度环
          Stack() {
            // 背景圆环
            Circle({ width: 280, height: 280 })
              .fill('transparent')
              .stroke(this.currentTheme.glassmorphism.borderLight)
              .strokeWidth(8)

            // 进度圆环
            Circle({ width: 280, height: 280 })
              .fill('transparent')
              .stroke(this.currentTheme.glassmorphism.accentPrimary)
              .strokeWidth(8)
              .strokeDashArray([this.getProgress() * 8.8, 880])
              .rotate({ angle: -90 })

            // 中心时间显示
            Column() {
              Text(this.formatTime(this.remainingTime))
                .fontSize(48)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.currentTheme.textColor)
                .margin({ bottom: 8 })

              Text(this.isRunning ? '专注中...' : (this.isPaused ? '已暂停' : '准备开始'))
                .fontSize(16)
                .fontColor(this.currentTheme.textColor)
                .opacity(0.6)
            }
            .justifyContent(FlexAlign.Center)
          }
          .margin({ bottom: 60 })
          .onClick(() => {
            // 点击圆形区域也可以显示提前完成
            if (this.isRunning) {
              this.showEarlyCompleteConfirm();
            }
          })

          // 控制按钮
          Row({ space: 20 }) {
            if (!this.isRunning && !this.isPaused) {
              // 开始按钮
              Button() {
                Row() {
                  Text('▶️')
                    .fontSize(20)
                    .margin({ right: 8 })
                  Text('开始专注')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                }
              }
              .width(160)
              .height(56)
              .backgroundColor(this.currentTheme.glassmorphism.accentPrimary)
              .borderRadius(28)
              .fontColor('#FFFFFF')
              .shadow({
                radius: 12,
                color: this.currentTheme.glassmorphism.accentPrimary + '40',
                offsetX: 0,
                offsetY: 6
              })
              .onClick(() => {
                this.startTimer();
                this.audioPlayer.playBackgroundSound(this.selectedSound);
              })
            } else {
              // 暂停/继续按钮
              Button() {
                Row() {
                  Text(this.isRunning ? '⏸️' : '▶️')
                    .fontSize(20)
                    .margin({ right: 8 })
                  Text(this.isRunning ? '暂停' : '继续')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                }
              }
              .width(120)
              .height(56)
              .backgroundColor(this.currentTheme.glassmorphism.accentSecondary)
              .borderRadius(28)
              .fontColor('#FFFFFF')
              .onClick(() => {
                if (this.isRunning) {
                  this.pauseTimer();
                  this.audioPlayer.stopBackgroundSound();
                } else {
                  this.startTimer();
                  this.audioPlayer.playBackgroundSound(this.selectedSound);
                }
              })

              // 提前完成按钮
              Button() {
                Row() {
                  Text('🏆')
                    .fontSize(20)
                    .margin({ right: 8 })
                  Text('完成')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                }
              }
              .width(120)
              .height(56)
              .backgroundColor(this.currentTheme.glassmorphism.accentTertiary)
              .borderRadius(28)
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.showEarlyCompleteConfirm();
              })
            }
          }
          .justifyContent(FlexAlign.Center)

          // 当前音效显示
          Row() {
            Text('🎵')
              .fontSize(16)
              .margin({ right: 8 })
            Text(`当前音效: ${this.getSoundOptions().find(s => s.file === this.selectedSound)?.name || '森林'}`)
              .fontSize(14)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.6)
          }
          .margin({ top: 40 })
          .onClick(() => {
            this.showSoundSelector = true;
          })
        }
        .layoutWeight(1)
        .padding({ left: 20, right: 20 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.currentTheme.backgroundColor)

      // 音效选择器对话框
      if (this.showSoundSelector) {
        Column() {
          this.SoundSelector()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.showSoundSelector = false;
        })
      }

      // 下一个任务对话框
      if (this.showNextTaskDialog) {
        NextTaskDialog({
          nextItem: this.nextTaskItem,
          nextIndex: this.currentSubTaskIndex + 1,
          actualTotalTasks: this.totalSubTasksInCollection,
          onStart: () => {
            this.showNextTaskDialog = false;
            this.startNextTask();
          },
          onCancel: () => {
            this.showNextTaskDialog = false;
            this.cancelSequence();
          }
        })
      }

      // 提前完成确认对话框
      if (this.showEarlyCompleteDialog) {
        Column() {
          this.EarlyCompleteDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.showEarlyCompleteDialog = false;
        })
      }
    }
  }
}

