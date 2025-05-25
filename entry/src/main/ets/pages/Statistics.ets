import { TabBar } from '../components/TabBar';
import { mockStatistics } from '../model/MockData';

@Entry
@Component
struct Statistics {
  @State statistics = mockStatistics;

  formatTime(minutes: number): string {
    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    return hours > 0 ? `${hours}小时${remainingMinutes}分钟` : `${remainingMinutes}分钟`;
  }

  @Builder
  StatCard(title: string, value: string | number, subtitle?: string) {
    Column() {
      Text(title)
        .fontSize(14)
        .opacity(0.6)
        .margin({ bottom: 8 })
      Text(value.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8A2BE2')
      if (subtitle) {
        Text(subtitle)
          .fontSize(12)
          .opacity(0.4)
          .margin({ top: 4 })
      }
    }
    .width('45%')
    .height(120)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(16)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Stack() {
      Column() {
        // 标题
        Text('统计数据')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 40, bottom: 20 })

        // 待办统计
        Column() {
          Text('待办完成情况')
            .fontSize(16)
            .opacity(0.6)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 16 })

          Row() {
            this.StatCard('总待办数', this.statistics.totalTodos)
            this.StatCard('已完成', this.statistics.completedTodos, 
              `完成率 ${Math.round(this.statistics.completedTodos / this.statistics.totalTodos * 100)}%`)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 })

        // 专注时间统计
        Column() {
          Text('专注时间统计')
            .fontSize(16)
            .opacity(0.6)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 16 })

          Row() {
            this.StatCard('今日专注', this.formatTime(this.statistics.todayFocusTime))
            this.StatCard('本周专注', this.formatTime(this.statistics.weeklyFocusTime))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 16 })

          Row() {
            this.StatCard('本月专注', this.formatTime(this.statistics.monthlyFocusTime))
            this.StatCard('总专注时间', this.formatTime(this.statistics.totalFocusTime))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)

        // 底部导航栏
        TabBar({ currentIndex: 3 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 