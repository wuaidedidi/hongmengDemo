import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TabBar } from '../components/TabBar';

@Entry
@Component
struct LockPage {
  @State selectedDuration: number = 30; // 默认30分钟
  @State isLocked: boolean = false;
  @State remainingTime: number = 0;
  @State timer: number = -1;
  @State showDurationPicker: boolean = false;
  @State showUnlockConfirm: boolean = false;

  aboutToAppear() {
    // 初始化页面
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  startLock() {
    this.isLocked = true;
    this.remainingTime = this.selectedDuration * 60;
    
    // 启动定时器
    this.timer = setInterval(() => {
      if (this.remainingTime > 0) {
        this.remainingTime--;
      } else {
        this.unlock();
      }
    }, 1000);
  }

  unlock() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    this.isLocked = false;
    this.remainingTime = 0;
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(remainingSeconds).padStart(2, '0')}`;
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        Row() {
          Image('/common/images/back.png')
            .width(24)
            .height(24)
            .margin({ left: 16 })
            .onClick(() => {
              if (this.isLocked) {
                promptAction.showToast({ 
                  message: '请先解除锁机状态',
                  duration: 2000
                });
                return;
              }
              router.back();
            })

          Text('锁机')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ left: 16 })

          Blank()

          Text('🔒')
            .fontSize(24)
            .fontColor('#333333')
            .margin({ right: 16 })
        }
        .width('100%')
        .height(56)
        .backgroundColor('#FFFFFF')

        // 主要内容区域
        Column() {
          if (this.isLocked) {
            Column() {
              Text('锁机中...')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 32 })

              Text(this.formatTime(this.remainingTime))
                .fontSize(72)
                .fontWeight(FontWeight.Bold)
                .fontColor('#8A2BE2')
                .margin({ bottom: 48 })

              Text('请专注完成当前任务')
                .fontSize(18)
                .fontColor('#666666')
                .margin({ bottom: 32 })

              Button('解锁')
                .width('80%')
                .height(48)
                .fontSize(18)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF4D4F')
                .borderRadius(24)
                .onClick(() => {
                  this.showUnlockConfirm = true;
                })
            }
            .width('100%')
          } else {
            Column() {
              Button('30分钟')
                .width('80%')
                .height(48)
                .fontSize(18)
                .fontColor('#FFFFFF')
                .backgroundColor('#8A2BE2')
                .borderRadius(24)
                .margin({ bottom: 16 })
                .onClick(() => {
                  this.selectedDuration = 30;
                  this.startLock();
                })

              Button('1小时')
                .width('80%')
                .height(48)
                .fontSize(18)
                .fontColor('#FFFFFF')
                .backgroundColor('#8A2BE2')
                .borderRadius(24)
                .margin({ bottom: 16 })
                .onClick(() => {
                  this.selectedDuration = 60;
                  this.startLock();
                })

              Button('2小时')
                .width('80%')
                .height(48)
                .fontSize(18)
                .fontColor('#FFFFFF')
                .backgroundColor('#8A2BE2')
                .borderRadius(24)
                .onClick(() => {
                  this.selectedDuration = 120;
                  this.startLock();
                })
            }
            .width('100%')
            .margin({ top: 40 })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F8F8F8')
        .padding(16)

        // 底部导航栏
        TabBar({ 
          currentIndex: 2,
          isLocked: this.isLocked
        })
      }
      .width('100%')
      .height('100%')

      if (this.showUnlockConfirm) {
        Column() {
          Text('确认解锁？')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 16 })

          Text('提前解锁将中断锁机')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 24 })

          Row() {
            Button('取消')
              .width(120)
              .height(40)
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .fontColor('#333333')
              .margin({ right: 16 })
              .onClick(() => {
                this.showUnlockConfirm = false;
              })

            Button('确认')
              .width(120)
              .height(40)
              .fontSize(16)
              .backgroundColor('#FF4D4F')
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.unlock();
                this.showUnlockConfirm = false;
              })
          }
        }
        .width('80%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .position({ x: '10%', y: '40%' })
      }
    }
    .width('100%')
    .height('100%')
  }
} 