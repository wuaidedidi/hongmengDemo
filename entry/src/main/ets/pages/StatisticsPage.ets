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
  @State yearlyData: number[] = Array(12).fill(0).map(() => Math.floor(Math.random() * 1000));

  aboutToAppear() {
    // 模拟加载数据
    this.loadStatisticsData();
  }

  loadStatisticsData() {
    // 模拟从后端获取数据
    this.totalFocusTime = 3600; // 60小时
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
        .borderRadius(8)
        .margin({ top: 16 })

        // 时间范围选择
        Row() {
          Text('周')
            .fontSize(16)
            .fontColor(this.currentTab === 0 ? '#8A2BE2' : '#666666')
            .fontWeight(this.currentTab === 0 ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.currentTab === 0 ? '#F0E6FF' : 'transparent')
            .borderRadius(16)
            .onClick(() => {
              this.currentTab = 0;
            })

          Text('月')
            .fontSize(16)
            .fontColor(this.currentTab === 1 ? '#8A2BE2' : '#666666')
            .fontWeight(this.currentTab === 1 ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.currentTab === 1 ? '#F0E6FF' : 'transparent')
            .borderRadius(16)
            .onClick(() => {
              this.currentTab = 1;
            })

          Text('年')
            .fontSize(16)
            .fontColor(this.currentTab === 2 ? '#8A2BE2' : '#666666')
            .fontWeight(this.currentTab === 2 ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.currentTab === 2 ? '#F0E6FF' : 'transparent')
            .borderRadius(16)
            .onClick(() => {
              this.currentTab = 2;
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 24, bottom: 16 })

        // 图表区域
        Column() {
          if (this.currentTab === 0) {
            // 周视图
            Row() {
              ForEach(this.weeklyData, (value: number, index: number) => {
                Column() {
                  Text(value.toString())
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ bottom: 4 })
                  Column()
                    .width(30)
                    .height(value)
                    .backgroundColor('#8A2BE2')
                    .borderRadius(4)
                  Text(['一', '二', '三', '四', '五', '六', '日'][index])
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              })
            }
            .width('100%')
            .height(200)
            .padding(16)
          } else if (this.currentTab === 1) {
            // 月视图
            Grid() {
              ForEach(this.monthlyData, (value: number, index: number) => {
                GridItem() {
                  Column() {
                    Text(value.toString())
                      .fontSize(12)
                      .fontColor('#666666')
                      .margin({ bottom: 4 })
                    Column()
                      .width(20)
                      .height(value / 2)
                      .backgroundColor('#8A2BE2')
                      .borderRadius(4)
                    Text((index + 1).toString())
                      .fontSize(12)
                      .fontColor('#666666')
                      .margin({ top: 4 })
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Center)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
            .width('100%')
            .height(300)
            .padding(16)
          } else {
            // 年视图
            Row() {
              ForEach(this.yearlyData, (value: number, index: number) => {
                Column() {
                  Text(value.toString())
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ bottom: 4 })
                  Column()
                    .width(30)
                    .height(value / 5)
                    .backgroundColor('#8A2BE2')
                    .borderRadius(4)
                  Text((index + 1).toString() + '月')
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              })
            }
            .width('100%')
            .height(200)
            .padding(16)
          }
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 16 })

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
        .borderRadius(8)
        .margin({ top: 16, bottom: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
      .backgroundColor('#F8F8F8')

      // 底部导航栏
      TabBar({ currentIndex: 3 })
    }
    .width('100%')
    .height('100%')
  }
} 