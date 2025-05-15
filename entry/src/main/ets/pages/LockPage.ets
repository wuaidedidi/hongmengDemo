import router from '@ohos.router';

@Entry
@Component
export default struct LockPage {
  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F8F8F8')
      
      Column() {
        // 顶部栏
        Row() {
          Text('锁机')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#222222')
          
          Blank()
          
          Row({ space: 20 }) {
            Column() {
              Text('必开')
                .fontSize(16)
                .fontColor('#333333')
            }
            .backgroundColor('#F0F0F0')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            
            Column() {
              Text('权限')
                .fontSize(16)
                .fontColor('#333333')
            }
            .backgroundColor('#F0F0F0')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            
            Text('≡').fontSize(24)
          }
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16 })
        
        // 主体内容
        Column({ space: 16 }) {
          // 小憩卡片
          Row() {
            Row() {
              Text('🍃').fontSize(28)
              
              Column() {
                Text('小憩')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ left: 16 })
                
                Text('放松身心的深呼吸，感受禅修般的宁静')
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.8)')
                  .margin({ left: 16, top: 4 })
              }
            }
          }
          .width('100%')
          .height(100)
          .padding(16)
          .backgroundColor('#00C78C')
          .borderRadius(16)
          
          // 快速锁机卡片
          Row() {
            Row() {
              Text('🔒').fontSize(28)
              
              Column() {
                Text('立刻开始快速锁机')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ left: 16 })
                
                Text('选择锁机时长，并立刻开始锁机')
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.8)')
                  .margin({ left: 16, top: 4 })
              }
              .layoutWeight(1)
              
              Text('📱').fontSize(32)
            }
          }
          .width('100%')
          .height(100)
          .padding(16)
          .backgroundColor('#FF7F6D')
          .borderRadius(16)
          
          // 自定义锁机时间段卡片
          Row() {
            Row() {
              Text('➕').fontSize(28)
              
              Column() {
                Text('添加自定义锁机时间段')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ left: 16 })
                
                Text('在指定时间范围内锁住手机，不做熬夜手机党')
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.8)')
                  .margin({ left: 16, top: 4 })
              }
            }
          }
          .width('100%')
          .height(100)
          .padding(16)
          .backgroundColor('#3D95F9')
          .borderRadius(16)
          
          // 锁机设置按钮
          Button() {
            Row() {
              Text('⚙️').fontSize(20)
              Text('提升强制性选项 | 锁机设置')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .margin({ left: 8 })
            }
          }
          .width('80%')
          .height(46)
          .backgroundColor('#FF7F6D')
          .borderRadius(23)
          
          // 提示图片
          Column() {
            // 空状态图标
            Text('📦').fontSize(80)
            
            Text('当前没有设置定时锁机')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 16 })
            
            Text('锁机是比学霸模式更严格的自控功能')
              .fontSize(14)
              .fontColor('#FF7F6D')
              .margin({ top: 8 })
          }
          .width('100%')
          .margin({ top: 40 })
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(16)
        .layoutWeight(1)
        
        // 底部导航栏
        Row() {
          Column() {
            Text('📅').fontSize(24)
            Text('待办').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.push({ url: 'pages/Index' });
          })
          
          Column() {
            Text('📝').fontSize(24)
            Text('待办集').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.push({ url: 'pages/Second' });
          })
          
          Column() {
            Text('🔒').fontSize(24)
            Text('锁机').fontSize(12).margin({ top: 4 }).fontColor('#3D95F9')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          
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
    }
    .width('100%')
    .height('100%')
  }
} 