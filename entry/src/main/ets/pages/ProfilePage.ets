import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ProfilePage {
  @State username: string = '用户名';
  @State avatar: string = '/common/images/default_avatar.png';
  @State showLogoutConfirm: boolean = false;

  aboutToAppear() {
    // 初始化页面
  }

  handleLogout() {
    this.showLogoutConfirm = true;
  }

  confirmLogout() {
    // 执行登出操作
    this.showLogoutConfirm = false;
    router.pushUrl({ url: 'pages/Login' });
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
              router.back();
            })

          Text('我的')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ left: 16 })

          Blank()

          Text('⚙️')
            .fontSize(24)
            .fontColor('#333333')
            .margin({ right: 16 })
        }
        .width('100%')
        .height(56)
        .backgroundColor('#FFFFFF')

        // 个人信息卡片
        Column() {
          Row() {
            Image(this.avatar)
              .width(80)
              .height(80)
              .borderRadius(40)
              .margin({ right: 16 })

            Column() {
              Text(this.username)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              Text('点击编辑个人信息')
                .fontSize(14)
                .fontColor('#666666')
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .margin({ top: 16 })

        // 功能列表
        Column() {
          // 数据统计
          Row() {
            Text('📊')
              .fontSize(24)
              .fontColor('#333333')
              .margin({ right: 16 })

            Text('数据统计')
              .fontSize(16)
              .fontColor('#333333')

            Blank()

            Image('/common/images/arrow_right.png')
              .width(20)
              .height(20)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/StatisticsPage' });
          })

          Divider()
            .color('#F5F5F5')
            .width('100%')

          // 主题设置
          Row() {
            Text('🎨')
              .fontSize(24)
              .fontColor('#333333')
              .margin({ right: 16 })

            Text('主题设置')
              .fontSize(16)
              .fontColor('#333333')

            Blank()

            Image('/common/images/arrow_right.png')
              .width(20)
              .height(20)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/BackgroundSettingsPage' });
          })

          Divider()
            .color('#F5F5F5')
            .width('100%')

          // 通知设置
          Row() {
            Text('🔔')
              .fontSize(24)
              .fontColor('#333333')
              .margin({ right: 16 })

            Text('通知设置')
              .fontSize(16)
              .fontColor('#333333')

            Blank()

            Image('/common/images/arrow_right.png')
              .width(20)
              .height(20)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')

          Divider()
            .color('#F5F5F5')
            .width('100%')

          // 关于我们
          Row() {
            Text('ℹ️')
              .fontSize(24)
              .fontColor('#333333')
              .margin({ right: 16 })

            Text('关于我们')
              .fontSize(16)
              .fontColor('#333333')

            Blank()

            Image('/common/images/arrow_right.png')
              .width(20)
              .height(20)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
        }
        .width('100%')
        .margin({ top: 16 })

        // 退出登录按钮
        Button('退出登录')
          .width('90%')
          .height(48)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF4D4F')
          .borderRadius(24)
          .margin({ top: 32 })
          .onClick(() => {
            this.handleLogout();
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F8F8')

      // 退出确认对话框
      if (this.showLogoutConfirm) {
        Column() {
          Column() {
            Text('确认退出？')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ top: 24, bottom: 16 })

            Text('退出后将清除登录状态')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 24 })

            Row() {
              Button('取消')
                .width('40%')
                .height(44)
                .fontSize(16)
                .fontColor('#333333')
                .backgroundColor('#F5F5F5')
                .borderRadius(22)
                .onClick(() => {
                  this.showLogoutConfirm = false;
                })

              Button('确认退出')
                .width('40%')
                .height(44)
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF4D4F')
                .borderRadius(22)
                .margin({ left: 16 })
                .onClick(() => {
                  this.confirmLogout();
                })
            }
            .margin({ bottom: 16 })
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showLogoutConfirm = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
} 