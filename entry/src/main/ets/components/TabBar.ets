import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface TabItem {
  icon: string;
  text: string;
  path: string;
}

@Component
export struct TabBar {
  @Prop currentIndex: number = 0;
  @Prop isLocked?: boolean = false;  // 添加锁机状态属性

  private tabs: TabItem[] = [
    { icon: '📅', text: '待办', path: 'pages/Index' },
    { icon: '📝', text: '待办事项', path: 'pages/TodoDetail' },
    { icon: '🔒', text: '锁机', path: 'pages/LockPage' },
    { icon: '📊', text: '统计数据', path: 'pages/StatisticsPage' },
    { icon: '👤', text: '我的', path: 'pages/Profile' }
  ];

  @Builder
  TabBuilder(index: number, icon: string, text: string) {
    Column() {
      Text(icon)
        .fontSize(24)
        .fontColor(this.currentIndex === index ? '#8A2BE2' : '#666666')
      Text(text)
        .fontSize(12)
        .margin({ top: 4 })
        .fontColor(this.currentIndex === index ? '#8A2BE2' : '#666666')
    }
    .width('20%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.currentIndex !== index) {
        // 检查是否在锁机状态
        if (this.isLocked && this.currentIndex === 2) {
          promptAction.showToast({ 
            message: '请先解除锁机状态再切换页面',
            duration: 2000
          });
          return;
        }
        console.info(`正在跳转到: ${this.tabs[index].path}`);
        router.pushUrl({
          url: this.tabs[index].path,
          params: {}
        }).then(() => {
          console.info(`成功跳转到: ${this.tabs[index].path}`);
        }).catch((err: Error) => {
          console.error(`导航失败: ${err.message}`);
          promptAction.showToast({ 
            message: `页面跳转失败: ${err.message}`,
            duration: 2000
          });
        });
      }
    })
  }

  build() {
    Row() {
      ForEach(this.tabs, (item: TabItem, index: number) => {
        this.TabBuilder(index, item.icon, item.text)
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceEvenly)
    .border({ width: { top: 0.5 }, color: '#E0E0E0' })
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: -2 })
    .zIndex(1)
  }
} 