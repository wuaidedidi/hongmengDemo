import router from '@ohos.router';

@Entry
@Component
export default struct ProfilePage {
  @State userName: string = '毛猪佩奇';
  @State userMotto: string = '千里之行，始于足下';
  @State totalFocusDays: number = 99;
  @State consecutiveFocusDays: number = 1;
  
  build() {
    Column() {
      // 顶部蓝色栏
      Row() {
        Text('我的')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        
        Blank()
        
        Row({ space: 16 }) {
          Text('❓').fontSize(24).fontColor('#FFFFFF')
          Text('⚙️').fontSize(24).fontColor('#FFFFFF')
          Text('≡').fontSize(24).fontColor('#FFFFFF')
        }
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#22B6F7')
      
      // 个人信息头部区域 - 深蓝色带有飞机图案背景
      Stack() {
        // 背景色和装饰
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#152F5E')
        
        Column({ space: 8 }) {
          // 头像和用户信息
          Row() {
            // 头像
            Stack() {
              Circle()
                .width(80)
                .height(80)
                .fill('#FFFFFF')
              
              Text('👶')
                .fontSize(50)
            }
            
            Column({ space: 4 }) {
              // 用户徽章和专注天数
              Row() {
                Text(this.userName)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
              .margin({ top: 8, bottom: 8 })
              
              // 专注天数标签
              Row({ space: 8 }) {
                Text(`共专注${this.totalFocusDays}天`)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('rgba(255, 255, 255, 0.2)')
                  .borderRadius(16)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                
                Text(`连续专注${this.consecutiveFocusDays}天`)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('rgba(255, 255, 255, 0.2)')
                  .borderRadius(16)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              }
            }
            .padding({ left: 16 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ left: 20 })
          
          // 个人座右铭
          Text(this.userMotto)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .width('100%')
            .padding({ left: 20, bottom: 16 })
            .textAlign(TextAlign.Start)
        }
        .width('100%')
      }
      .width('100%')
      .height(200)
      
      // 三个功能按钮
      Row() {
        // 未来倒计时
        Column() {
          Text('🎯').fontSize(30)
          Text('未来倒计时')
            .fontSize(16)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .height(80)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 未来倒计时功能
        })
        
        // 专注历史记录
        Column() {
          Text('📊').fontSize(30)
          Text('专注历史记录')
            .fontSize(16)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .height(80)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.push({ url: 'pages/StatisticsPage' });
        })
        
        // 自习室｜许愿墙
        Column() {
          Text('📈').fontSize(30)
          Text('自习室|许愿墙')
            .fontSize(16)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .height(80)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 自习室功能
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      
      // 功能列表
      List() {
        // 季度卡
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Text('VIP')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#8A6D3B')
                .borderRadius(4)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              
              Column() {
                Text('季度卡')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                
                Text('众多新颖高级功能，助你养成专注好习惯')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
            }
            
            Blank()
            
            Text('>')
              .fontSize(20)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(70)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
        }
        .onClick(() => {
          // 季度卡功能
        })
        
        // 备份｜恢复｜云同步
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Text('☁️')
                .fontSize(24)
              
              Column() {
                Text('备份｜恢复｜云同步')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
              }
            }
            
            Blank()
            
            Text('>')
              .fontSize(20)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(70)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
        }
        .onClick(() => {
          // 备份功能
        })
        
        // 专注计时核心设置
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Text('⏱️')
                .fontSize(24)
              
              Column() {
                Text('专注计时核心设置')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                
                Text('铃声震动｜专注格言｜休息时长')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
            }
            
            Blank()
            
            Text('>')
              .fontSize(20)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(70)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
        }
        .onClick(() => {
          // 专注设置
        })
        
        // 海报背景和外观
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Text('🖼️')
                .fontSize(24)
              
              Column() {
                Text('海报背景和外观')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                
                Text('主界面和计时页面海报｜待办卡片背景')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
            }
            
            Blank()
            
            Text('>')
              .fontSize(20)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(70)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
        }
        .onClick(() => {
          // 背景设置
        })
        
        // 自定义底栏模块
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Text('🔠')
                .fontSize(24)
              
              Column() {
                Text('自定义底栏模块')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                
                Text('选择要在主界面展示的功能')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
            }
            
            Blank()
            
            Text('>')
              .fontSize(20)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(70)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
        }
        .onClick(() => {
          // 底栏设置
        })
        
        // 主题颜色搭配
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Text('🎨')
                .fontSize(24)
              
              Column() {
                Text('主题颜色搭配')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                
                Text('主题色｜专注分布图配色')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
            }
            
            Blank()
            
            Circle()
              .width(24)
              .height(24)
              .fill('#22B6F7')
          }
          .width('100%')
          .height(70)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
        }
        .onClick(() => {
          // 主题设置
        })
        
        // 桌面小组件选项
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Text('📱')
                .fontSize(24)
              
              Column() {
                Text('桌面小组件选项')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                
                Text('小组件功能｜背景图等')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
            }
            
            Blank()
            
            Text('>')
              .fontSize(20)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(70)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
        }
        .onClick(() => {
          // 小组件设置
        })
        
        // 其他设置
        ListItem() {
          Row() {
            Row({ space: 12 }) {
              Text('⚙️')
                .fontSize(24)
              
              Column() {
                Text('其他设置')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                
                Text('语言设置等')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
            }
            
            Blank()
            
            Text('>')
              .fontSize(20)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(70)
          .backgroundColor('#FFFFFF')
          .padding({ left: 16, right: 16 })
          .borderRadius(8)
        }
        .onClick(() => {
          // 其他设置
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F0F0F0')
      .padding({ left: 16, right: 16 })
      .divider({
        strokeWidth: 1,
        color: '#F0F0F0',
        startMargin: 16,
        endMargin: 16
      })
      
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
          Text('我的').fontSize(12).margin({ top: 4 }).fontColor('#22B6F7')
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      }
      .height(60)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: { top: '#E0E0E0' } })
    }
    .width('100%')
    .height('100%')
  }
} 