import router from '@ohos.router';

@Entry
@Component
export default struct Second {
  build() {
    Column() {
      // 顶部蓝色栏
      Column() {
        Row() {
          Text('待办集')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Blank()
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#22B6F7')
        // 必开 权限等按钮
        Row() {
          Text('必开')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .margin({ right: 16 })
          Text('权限')
            .fontSize(16)
            .fontColor('#FFFFFF')
          Blank()
          Text('⏱️').fontSize(24).fontColor('#FFFFFF').margin({ right: 8 })
          Text('➕').fontSize(24).fontColor('#FFFFFF').margin({ right: 8 })
          Text('≡').fontSize(24).fontColor('#FFFFFF')
        }
        .width('100%')
        .height(40)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#22B6F7')
      }
      // 列表内容
      Column() {
        Row() {
          Text('大白猪')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#222222')
          Blank()
          Text('📊').fontSize(24).margin({ right: 8 })
          Text('⚙️').fontSize(24).margin({ right: 8 })
          Text('➕').fontSize(24)
        }
        .width('100%')
        .height(60)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 8, left: 8, right: 8 })
        Row() {
          Text('劳逸结合')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#222222')
          Blank()
          Text('📊').fontSize(24).margin({ right: 8 })
          Text('⚙️').fontSize(24).margin({ right: 8 })
          Text('➕').fontSize(24)
        }
        .width('100%')
        .height(60)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 8, left: 8, right: 8 })
      }
      .width('100%')
      .margin({ top: 8 })
      // 底部导航栏
      Row() {
        Column() {
          Text('📅').fontSize(24)
          Text('待办').fontSize(12).margin({ top: 4 }).fontColor('#22B6F7')
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
        Column() {
          Text('📝').fontSize(24)
          Text('待办集').fontSize(12).margin({ top: 4 })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
        Column() {
          Text('🔒').fontSize(24)
          Text('锁机').fontSize(12).margin({ top: 4 })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.push({ url: 'pages/LockPage' });
        })
        Column() {
          Text('📊').fontSize(24)
          Text('统计数据').fontSize(12).margin({ top: 4 })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.push({ url: 'pages/StatisticsPage' });
        })
        Column() {
          Text('👤').fontSize(24)
          Text('我的').fontSize(12).margin({ top: 4 })
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.push({ url: 'pages/ProfilePage' });
        })
      }
      .height(56)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: { top: '#E0E0E0' } })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
}