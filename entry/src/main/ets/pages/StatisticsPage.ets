import router from '@ohos.router';

@Entry
@Component
export default struct StatisticsPage {
  @State currentDate: string = '2025-05-12';
  @State currentMonth: string = '2025年05月';
  @State currentTabIndex: number = 0; // 0:日, 1:周, 2:月, 3:自定义
  @State showShareMenu: boolean = false;
  
  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F8F8F8')
      
      Column() {
        // 顶部栏 - 蓝色渐变背景
        Row() {
          Text('统计数据')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          
          Blank()
          
          Row({ space: 16 }) {
            Text('⏱️').fontSize(24).fontColor('#FFFFFF')
            Text('🏆').fontSize(24).fontColor('#FFFFFF')
            Text('≡').fontSize(24).fontColor('#FFFFFF')
          }
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#22B6F7')
        
        // 主体内容 - 滚动区域
        Scroll() {
          Column({ space: 12 }) {
            // 累计专注卡片
            Column() {
              Row() {
                Text('累计专注 ')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#22B6F7')
                
                Text('🔍')
                  .fontSize(20)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 8 })
              
              // 统计数据
              Row() {
                // 次数
                Column() {
                  Text('次数')
                    .fontSize(16)
                    .fontColor('#666666')
                  
                  Text('685')
                    .fontSize(40)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#22B6F7')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
                
                // 时长
                Column() {
                  Text('时长')
                    .fontSize(16)
                    .fontColor('#666666')
                  
                  Row({ space: 4 }) {
                    Text('527')
                      .fontSize(40)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#22B6F7')
                    
                    Column() {
                      Text('小时')
                        .fontSize(14)
                        .fontColor('#666666')
                      
                      Text('42')
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#22B6F7')
                      
                      Text('分钟')
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Center)
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
                
                // 日均时长
                Column() {
                  Text('日均时长')
                    .fontSize(16)
                    .fontColor('#666666')
                  
                  Row({ space: 4 }) {
                    Text('5')
                      .fontSize(40)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#22B6F7')
                    
                    Column() {
                      Text('小时')
                        .fontSize(14)
                        .fontColor('#666666')
                      
                      Text('19')
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#22B6F7')
                      
                      Text('分钟')
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Center)
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }
              .padding({ bottom: 16 })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            
            // 当日专注卡片
            Column() {
              Row() {
                Text('当日专注 ')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#22B6F7')
                
                Text(this.currentDate)
                  .fontSize(16)
                  .fontColor('#666666')
                
                Blank()
                
                Text('◀')
                  .fontSize(20)
                  .fontColor('#22B6F7')
                  .onClick(() => {
                    // 日期前移一天
                    const date = new Date(this.currentDate);
                    date.setDate(date.getDate() - 1);
                    this.currentDate = this.formatDate(date);
                  })
                
                Text('▶')
                  .fontSize(20)
                  .fontColor('#22B6F7')
                  .margin({ left: 16 })
                  .onClick(() => {
                    // 日期后移一天
                    const date = new Date(this.currentDate);
                    date.setDate(date.getDate() + 1);
                    this.currentDate = this.formatDate(date);
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 8 })
              
              // 统计数据
              Row() {
                // 次数
                Column() {
                  Text('次数')
                    .fontSize(16)
                    .fontColor('#666666')
                  
                  Text('0')
                    .fontSize(40)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#22B6F7')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
                
                // 时长
                Column() {
                  Text('时长')
                    .fontSize(16)
                    .fontColor('#666666')
                  
                  Row({ space: 4 }) {
                    Text('0')
                      .fontSize(40)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#22B6F7')
                    
                    Column() {
                      Text('分钟')
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Center)
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }
              .padding({ bottom: 16 })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            
            // 专注时长分布卡片
            Column() {
              Row() {
                Text('专注时长分布 ')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#22B6F7')
                
                Text(this.currentDate)
                  .fontSize(16)
                  .fontColor('#666666')
                
                Blank()
                
                Text('分享')
                  .fontSize(16)
                  .fontColor('#22B6F7')
                  .onClick(() => {
                    this.showShareMenu = true;
                  })
                
                Text('◀')
                  .fontSize(20)
                  .fontColor('#22B6F7')
                  .margin({ left: 16 })
                  .onClick(() => {
                    // 日期前移一天
                    const date = new Date(this.currentDate);
                    date.setDate(date.getDate() - 1);
                    this.currentDate = this.formatDate(date);
                  })
                
                Text('▶')
                  .fontSize(20)
                  .fontColor('#22B6F7')
                  .margin({ left: 16 })
                  .onClick(() => {
                    // 日期后移一天
                    const date = new Date(this.currentDate);
                    date.setDate(date.getDate() + 1);
                    this.currentDate = this.formatDate(date);
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 8 })
              
              // 时间分布选项卡
              Tabs() {
                TabContent() {
                  Column() {
                    // 空状态提示
                    Column() {
                      Text('暂无专注数据，点击待办上的开始按钮来专注计时吧')
                        .fontSize(16)
                        .fontColor('#999999')
                        .textAlign(TextAlign.Center)
                        .margin({ top: 80, bottom: 80 })
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Center)
                    
                    // 查看专注记录按钮
                    Button('查看专注记录')
                      .width('60%')
                      .height(40)
                      .fontSize(16)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#22B6F7')
                      .borderRadius(20)
                      .margin({ bottom: 16 })
                  }
                }.tabBar('日')
                
                TabContent() {
                  Column() {
                    // 周视图
                    Text('周视图显示区域')
                      .fontSize(16)
                      .fontColor('#999999')
                      .margin({ top: 80, bottom: 80 })
                  }
                }.tabBar('周')
                
                TabContent() {
                  Column() {
                    // 月视图
                    Text('月视图显示区域')
                      .fontSize(16)
                      .fontColor('#999999')
                      .margin({ top: 80, bottom: 80 })
                  }
                }.tabBar('月')
                
                TabContent() {
                  Column() {
                    // 自定义视图
                    Text('自定义视图显示区域')
                      .fontSize(16)
                      .fontColor('#999999')
                      .margin({ top: 80, bottom: 80 })
                  }
                }.tabBar('自定义')
              }
              .barMode(BarMode.Fixed)
              .barWidth('100%')
              .backgroundColor('#F5F5F5')
              .onChange((index: number) => {
                this.currentTabIndex = index;
              })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            
            // 本月专注时段分布卡片
            Column() {
              Row() {
                Text('本月专注时段分布 ')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#22B6F7')
                
                Text(this.currentMonth)
                  .fontSize(16)
                  .fontColor('#666666')
                
                Blank()
                
                Text('◀')
                  .fontSize(20)
                  .fontColor('#22B6F7')
                  .onClick(() => {
                    // 月份前移一月
                    const date = new Date(this.currentDate);
                    date.setMonth(date.getMonth() - 1);
                    this.currentMonth = this.formatMonth(date);
                  })
                
                Text('▶')
                  .fontSize(20)
                  .fontColor('#22B6F7')
                  .margin({ left: 16 })
                  .onClick(() => {
                    // 月份后移一月
                    const date = new Date(this.currentDate);
                    date.setMonth(date.getMonth() + 1);
                    this.currentMonth = this.formatMonth(date);
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 8 })
              
              // 月度专注时段分布内容
              Column() {
                // 空状态提示
                Text('暂无专注数据，点击待办上的开始按钮来专注计时吧')
                  .fontSize(16)
                  .fontColor('#999999')
                  .textAlign(TextAlign.Center)
                  .margin({ top: 80, bottom: 80 })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .padding({ bottom: 16 })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 16 })
          }
          .width('100%')
          .padding(12)
        }
        .width('100%')
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
            Text('锁机').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.push({ url: 'pages/LockPage' });
          })
          
          Column() {
            Text('📊').fontSize(24)
            Text('统计数据').fontSize(12).margin({ top: 4 }).fontColor('#22B6F7')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          
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
      
      // 分享菜单 - 条件渲染
      if (this.showShareMenu) {
        Column() {
          Column() {
            Text('分享到')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 16, bottom: 20 })
            
            Row({ space: 24 }) {
              Column() {
                Text('💬').fontSize(36)
                Text('微信').fontSize(14).margin({ top: 8 })
              }.alignItems(HorizontalAlign.Center)
              
              Column() {
                Text('👥').fontSize(36)
                Text('朋友圈').fontSize(14).margin({ top: 8 })
              }.alignItems(HorizontalAlign.Center)
              
              Column() {
                Text('🔗').fontSize(36)
                Text('复制链接').fontSize(14).margin({ top: 8 })
              }.alignItems(HorizontalAlign.Center)
            }
            .padding({ bottom: 20 })
            
            Button('取消')
              .width('80%')
              .height(44)
              .fontSize(16)
              .fontColor('#333333')
              .backgroundColor('#F5F5F5')
              .borderRadius(22)
              .margin({ bottom: 16 })
              .onClick(() => {
                this.showShareMenu = false;
              })
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.showShareMenu = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 格式化日期为 YYYY-MM-DD
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
  
  // 格式化月份为 YYYY年MM月
  private formatMonth(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    return `${year}年${month}月`;
  }
} 