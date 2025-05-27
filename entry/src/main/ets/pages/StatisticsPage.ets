import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TabBar } from '../components/TabBar';

@Entry
@Component
struct StatisticsPage {
  @State currentTab: number = 0;
  @State totalFocusTime: number = 0;
  @State totalFocusCount: number = 0;
  @State continuousDays: number = 0;
  @State totalDays: number = 0;
  @State weeklyData: number[] = [120, 180, 90, 150, 200, 160, 140];
  @State monthlyData: number[] = Array(30).fill(0).map(() => Math.floor(Math.random() * 200));
  @State dailyData: number[] = Array(24).fill(0).map(() => Math.floor(Math.random() * 60));

  // 计算周数据百分比
  calculateWeeklyPercentages(): number[] {
    const total = this.weeklyData.reduce((a, b) => a + b, 0);
    return this.weeklyData.map(value => (value / total) * 100);
  }

  // 计算月数据百分比
  calculateMonthlyPercentages(): number[] {
    const total = this.monthlyData.reduce((a, b) => a + b, 0);
    return this.monthlyData.map(value => (value / total) * 100);
  }

  // 计算日数据百分比
  calculateDailyPercentages(): number[] {
    const total = this.dailyData.reduce((a, b) => a + b, 0);
    return this.dailyData.map(value => (value / total) * 100);
  }

  aboutToAppear() {
    this.loadStatisticsData();
  }

  loadStatisticsData() {
    this.totalFocusTime = 3600;
    this.totalFocusCount = 24;
    this.continuousDays = 7;
    this.totalDays = 30;
  }

  formatTime(minutes: number): string {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours}小时${mins}分钟`;
  }

  build() {
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

        Text('专注统计')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16 })

        Blank()

        Text('📊')
          .fontSize(24)
          .fontColor('#333333')
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      // 统计卡片
      Scroll() {
        Column() {
          // 总览数据
          Row() {
            Column() {
              Text(this.totalFocusTime.toString())
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#8A2BE2')
              Text('总专注时长（分钟）')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(this.totalFocusCount.toString())
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#8A2BE2')
              Text('专注次数')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(this.continuousDays.toString())
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#8A2BE2')
              Text('连续天数')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.1)',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ top: 16 })

          // 时间范围选择
          Column() {
            // 时间范围选择器
            Row() {
              ForEach(['日', '周', '月'], (item: string, index: number) => {
                Text(item)
                  .fontSize(16)
                  .fontColor(this.currentTab === index ? '#FFFFFF' : '#8A2BE2')
                  .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
                  .padding({ left: 24, right: 24, top: 12, bottom: 12 })
                  .backgroundColor(this.currentTab === index ? '#8A2BE2' : '#F0E6FF')
                  .borderRadius(24)
                  .onClick(() => {
                    this.currentTab = index;
                  })
                  .margin({ left: index === 0 ? 0 : 12 })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 24, bottom: 16 })

            // 图表区域
            Column() {
              if (this.currentTab === 0) {
                // 日视图 - 使用柱状图
                Column() {
                  Text('今日专注时间')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ bottom: 16 })
                  
                  Column() {
                    // 柱状图
                    Row() {
                      ForEach(this.dailyData, (value: number, index: number) => {
                        Column() {
                          Text(value.toString())
                            .fontSize(12)
                            .fontColor('#666666')
                            .margin({ bottom: 4 })
                          Column()
                            .width(12)
                            .height(value * 2)
                            .backgroundColor('#8A2BE2')
                            .opacity(0.1 + (index * 0.02))
                            .borderRadius(6)
                            .animation({
                              duration: 1000,
                              curve: Curve.EaseInOut,
                              iterations: 1,
                              playMode: PlayMode.Normal
                            })
                          Text(index.toString() + '时')
                            .fontSize(12)
                            .fontColor('#666666')
                            .margin({ top: 4 })
                        }
                        .margin({ right: 8 })
                        .alignItems(HorizontalAlign.Center)
                      })
                    }
                    .width('100%')
                    .height(200)
                    .justifyContent(FlexAlign.SpaceBetween)
                    .padding({ left: 16, right: 16 })
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(16)
                  .padding(16)
                }
                .width('100%')
                .margin({ bottom: 24 })
              } else if (this.currentTab === 1) {
                // 周视图 - 使用折线图
                Column() {
                  Text('本周专注时间')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ bottom: 16 })
                  
                  Column() {
                    // 折线图
                    Stack() {
                      // 背景网格
                      Column() {
                        ForEach([0, 1, 2, 3, 4], (item: number) => {
                          Divider()
                            .color('#EEEEEE')
                            .width('100%')
                            .margin({ top: 40 })
                        })
                      }
                      .width('100%')
                      .height(200)

                      // 折线
                      Path()
                        .commands(this.generateLinePath(this.weeklyData))
                        .stroke('#8A2BE2')
                        .strokeWidth(3)
                        .fill('transparent')
                        .animation({
                          duration: 1000,
                          curve: Curve.EaseInOut,
                          iterations: 1,
                          playMode: PlayMode.Normal
                        })

                      // 数据点
                      ForEach(this.weeklyData, (value: number, index: number) => {
                        Circle()
                          .width(8)
                          .height(8)
                          .fill('#8A2BE2')
                          .position({
                            x: 16 + (index * (100 / 6)),
                            y: 200 - (value * 0.8)
                          })
                          .animation({
                            duration: 1000,
                            curve: Curve.EaseInOut,
                            iterations: 1,
                            playMode: PlayMode.Normal
                          })
                      })
                    }
                    .width('100%')
                    .height(200)
                    .padding({ left: 16, right: 16 })

                    // X轴标签
                    Row() {
                      ForEach(['一', '二', '三', '四', '五', '六', '日'], (item: string) => {
                        Text(item)
                          .fontSize(12)
                          .fontColor('#666666')
                          .layoutWeight(1)
                          .textAlign(TextAlign.Center)
                      })
                    }
                    .width('100%')
                    .padding({ left: 16, right: 16 })
                    .margin({ top: 8 })
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(16)
                  .padding(16)
                }
                .width('100%')
                .margin({ bottom: 24 })
              } else {
                // 月视图 - 使用环形图
                Column() {
                  Text('本月专注时间')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ bottom: 16 })
                  
                  Column() {
                    // 环形图
                    Stack() {
                      Circle()
                        .width(200)
                        .height(200)
                        .fill('#F0E6FF')
                      
                      ForEach(this.calculateMonthlyPercentages(), (percentage: number, index: number) => {
                        if (index % 5 === 0) {
                          Path()
                            .commands(this.generateArcPath(index * (360 / 30), (index + 5) * (360 / 30), 100))
                            .fill('#8A2BE2')
                            .opacity(0.1 + (index * 0.02))
                            .animation({
                              duration: 1000,
                              curve: Curve.EaseInOut,
                              iterations: 1,
                              playMode: PlayMode.Normal
                            })
                        }
                      })

                      // 中心圆
                      Circle()
                        .width(120)
                        .height(120)
                        .fill('#FFFFFF')
                      
                      // 中心文字
                      Column() {
                        Text('本月')
                          .fontSize(16)
                          .fontColor('#666666')
                        Text(this.totalFocusTime.toString())
                          .fontSize(24)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#8A2BE2')
                          .margin({ top: 4 })
                        Text('分钟')
                          .fontSize(14)
                          .fontColor('#666666')
                      }
                    }
                    .width(200)
                    .height(200)
                    .margin({ top: 16, bottom: 16 })

                    // 图例
                    Column() {
                      Row() {
                        ForEach(this.calculateMonthlyPercentages(), (percentage: number, index: number) => {
                          if (index % 5 === 0) {
                            Column() {
                              Row() {
                                Circle()
                                  .width(12)
                                  .height(12)
                                  .fill('#8A2BE2')
                                  .opacity(0.1 + (index * 0.02))
                                  .margin({ right: 8 })
                                Text((index + 1).toString() + '-' + (index + 5).toString() + '日')
                                  .fontSize(14)
                                  .fontColor('#666666')
                              }
                              Text(percentage.toFixed(1) + '%')
                                .fontSize(14)
                                .fontColor('#666666')
                                .margin({ top: 4 })
                            }
                            .margin({ right: 16, bottom: 16 })
                          }
                        })
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.Center)
                      .padding(16)
                    }
                    .width('100%')
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(16)
                  .padding(16)
                }
                .width('100%')
                .margin({ bottom: 24 })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({
              radius: 8,
              color: 'rgba(0,0,0,0.1)',
              offsetX: 0,
              offsetY: 2
            })
          }

          // 成就展示
          Column() {
            Text('我的成就')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 16 })

            Row() {
              Column() {
                Text('🎯')
                  .fontSize(32)
                  .fontColor('#8A2BE2')
                Text('连续专注7天')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text('⏰')
                  .fontSize(32)
                  .fontColor('#8A2BE2')
                Text('累计专注60小时')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text('📅')
                  .fontSize(32)
                  .fontColor('#8A2BE2')
                Text('坚持30天')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.1)',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ top: 16, bottom: 16 })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F8F8F8')

      // 底部导航栏
      TabBar({ currentIndex: 3 })
    }
    .width('100%')
    .height('100%')
  }

  // 生成折线图路径
  generateLinePath(data: number[]): string {
    const maxValue = Math.max(...data);
    const points = data.map((value, index) => {
      const x = 16 + (index * (100 / 6));
      const y = 200 - (value * (200 / maxValue));
      return `${x},${y}`;
    });
    return `M ${points.join(' L ')}`;
  }

  // 生成环形图路径
  generateArcPath(startAngle: number, endAngle: number, radius: number): string {
    const startX = radius + radius * Math.cos(startAngle * Math.PI / 180);
    const startY = radius + radius * Math.sin(startAngle * Math.PI / 180);
    const endX = radius + radius * Math.cos(endAngle * Math.PI / 180);
    const endY = radius + radius * Math.sin(endAngle * Math.PI / 180);
    const largeArcFlag = endAngle - startAngle <= 180 ? 0 : 1;
    return `M ${radius} ${radius} L ${startX} ${startY} A ${radius} ${radius} 0 ${largeArcFlag} 1 ${endX} ${endY} Z`;
  }
} 