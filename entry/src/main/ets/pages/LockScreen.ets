import { TabBar } from '../components/TabBar';

@Entry
@Component
struct LockScreen {
  @State isLocked: boolean = false;
  @State remainingTime: number = 0;
  @State targetTime: number | null = null;

  aboutToAppear() {
    // 检查是否有未完成的锁机时间
    const savedTargetTime = AppStorage.Get<number>('lockTargetTime');
    if (savedTargetTime && savedTargetTime > Date.now()) {
      this.targetTime = savedTargetTime;
      this.isLocked = true;
      this.updateRemainingTime();
    }
  }

  updateRemainingTime() {
    if (this.targetTime && this.isLocked) {
      this.remainingTime = Math.max(0, Math.floor((this.targetTime - Date.now()) / 1000));
      if (this.remainingTime > 0) {
        setTimeout(() => this.updateRemainingTime(), 1000);
      } else {
        this.isLocked = false;
        this.targetTime = null;
        AppStorage.Delete('lockTargetTime');
      }
    }
  }

  formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  build() {
    Stack() {
      Column() {
        // 主要内容区域
        Column() {
          Text(this.isLocked ? '专注锁机中' : '锁机设置')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 40, bottom: 20 })

          if (this.isLocked) {
            Column() {
              Text('剩余时间')
                .fontSize(16)
                .opacity(0.6)
                .margin({ bottom: 10 })

              Text(this.formatTime(this.remainingTime))
                .fontSize(40)
                .fontWeight(FontWeight.Bold)
                .fontColor('#8A2BE2')
            }
            .margin({ top: 40 })
          } else {
            Column() {
              Button('锁机 30 分钟')
                .width('80%')
                .height(50)
                .margin({ bottom: 20 })
                .onClick(() => {
                  this.targetTime = Date.now() + 30 * 60 * 1000;
                  AppStorage.Set('lockTargetTime', this.targetTime);
                  this.isLocked = true;
                  this.updateRemainingTime();
                })

              Button('锁机 1 小时')
                .width('80%')
                .height(50)
                .margin({ bottom: 20 })
                .onClick(() => {
                  this.targetTime = Date.now() + 60 * 60 * 1000;
                  AppStorage.Set('lockTargetTime', this.targetTime);
                  this.isLocked = true;
                  this.updateRemainingTime();
                })

              Button('锁机 2 小时')
                .width('80%')
                .height(50)
                .onClick(() => {
                  this.targetTime = Date.now() + 2 * 60 * 60 * 1000;
                  AppStorage.Set('lockTargetTime', this.targetTime);
                  this.isLocked = true;
                  this.updateRemainingTime();
                })
            }
            .width('100%')
            .margin({ top: 40 })
          }
        }
        .width('100%')
        .layoutWeight(1)

        // 底部导航栏
        TabBar()
      }
      .width('100%')
      .height('100%')

      if (this.isLocked) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.5)
          .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 