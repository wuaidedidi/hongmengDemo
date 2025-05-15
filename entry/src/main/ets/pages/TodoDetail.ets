import router from '@ohos.router';

@Entry
@Component
export default struct TodoDetail {
  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F8F8F8')
      
      Column() {
        // 顶部渐变色栏
        Column() {
          Row() {
            Text('待办事项')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Blank()
            Text('≡').fontSize(24).fontColor('#FFFFFF')
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          
          // 状态栏按钮
          Row() {
            Text('进行中')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .margin({ right: 16 })
              .fontWeight(FontWeight.Medium)
              .backgroundColor('rgba(255, 255, 255, 0.2)')
              .borderRadius(16)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            Text('状态')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .backgroundColor('rgba(255, 255, 255, 0.2)')
              .borderRadius(16)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            Blank()
            Text('⏱️').fontSize(24).fontColor('#FFFFFF').margin({ right: 12 })
            Text('➕').fontSize(24).fontColor('#FFFFFF').margin({ right: 12 })
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .linearGradient({
          angle: 90,
          colors: [['#8A2BE2', 0.0], ['#FF1493', 1.0]]
        })
        
        // 列表内容
        Column() {
          // 分类标签
          Row() {
            Text('学习').fontColor('#8A2BE2').fontWeight(FontWeight.Medium)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .borderRadius(18)
              .backgroundColor('#F0E6FF')
              .margin({ right: 12 })
            
            Text('工作').fontColor('#666666').fontWeight(FontWeight.Medium)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .borderRadius(18)
              .backgroundColor('#F0F0F0')
              .margin({ right: 12 })
            
            Text('生活').fontColor('#666666').fontWeight(FontWeight.Medium)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .borderRadius(18)
              .backgroundColor('#F0F0F0')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .justifyContent(FlexAlign.Start)
          
          // 待办事项卡片
          Column({ space: 12 }) {
            // 卡片1
            Row() {
              Row() {
                Text('✅')
                  .fontSize(22)
                  .margin({ right: 12 })
                Column() {
                  Text('学习英语')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#222222')
                  Text('09:00-10:30 · 今天')
                    .fontSize(14)
                    .fontColor('#888888')
                    .margin({ top: 4 })
                }
              }
              
              Blank()
              
              Row() {
                Text('⏱️').fontSize(22).margin({ right: 12 })
                Text('✏️').fontSize(22)
              }
            }
            .width('100%')
            .height(76)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: 2 })
            
            // 卡片2
            Row() {
              Row() {
                Text('⭕')
                  .fontSize(22)
                  .margin({ right: 12 })
                Column() {
                  Text('复习数学')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#222222')
                  Text('13:30-15:00 · 今天')
                    .fontSize(14)
                    .fontColor('#888888')
                    .margin({ top: 4 })
                }
              }
              
              Blank()
              
              Row() {
                Text('⏱️').fontSize(22).margin({ right: 12 })
                Text('✏️').fontSize(22)
              }
            }
            .width('100%')
            .height(76)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: 2 })
            
            // 卡片3
            Row() {
              Row() {
                Text('⭕')
                  .fontSize(22)
                  .margin({ right: 12 })
                Column() {
                  Text('预习物理')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#222222')
                  Text('16:00-17:30 · 今天')
                    .fontSize(14)
                    .fontColor('#888888')
                    .margin({ top: 4 })
                }
              }
              
              Blank()
              
              Row() {
                Text('⏱️').fontSize(22).margin({ right: 12 })
                Text('✏️').fontSize(22)
              }
            }
            .width('100%')
            .height(76)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: 2 })
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .layoutWeight(1)
        
        // 底部导航栏
        Row() {
          Column() {
            Text('📅').fontSize(24)
            Text('待办').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          
          Column() {
            Text('📝').fontSize(24)
            Text('待办事项').fontSize(12).margin({ top: 4 }).fontColor('#8A2BE2')
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
        .height(60)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 1 }, color: { top: '#E0E0E0' } })
      }
      .width('100%')
      .height('100%')
      
      // 悬浮按钮
      Button('+')
        .width(56)
        .height(56)
        .fontSize(30)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#8A2BE2')
        .borderRadius(28)
        .shadow({ radius: 10, color: 'rgba(138, 43, 226, 0.3)', offsetX: 0, offsetY: 4 })
        .position({ x: '85%', y: '85%' })
    }
    .width('100%')
    .height('100%')
  }
} 