import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TabBar } from '../components/TabBar';

@Entry
@Component
struct Profile {
  @Builder
  MenuItem(icon: string, title: string, onClick: () => void) {
    Row() {
      Row() {
        Text(icon)
          .fontSize(20)
          .margin({ right: 12 })
        Text(title)
          .fontSize(16)
      }
      Text('>')
        .fontSize(16)
        .opacity(0.6)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(onClick)
  }

  build() {
    Stack() {
      Column() {
        // 用户信息区域
        Column() {
          Text('👤')
            .fontSize(48)
            .fontColor(Color.White)
            .margin({ bottom: 16 })
          Text('用户名')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
            .fontColor(Color.White)
          Text('加入时间：2024-01-01')
            .fontSize(14)
            .opacity(0.8)
            .fontColor(Color.White)
        }
        .width('100%')
        .padding({ top: 40, bottom: 24 })
        .backgroundColor('#8A2BE2')
        .alignItems(HorizontalAlign.Center)

        // 菜单列表
        Column() {
          this.MenuItem('⚙️', '设置', () => {
            promptAction.showToast({ message: '设置功能开发中...' });
          })
          Divider().color('#F5F5F5').height(1)

          this.MenuItem('🔔', '通知设置', () => {
            promptAction.showToast({ message: '通知设置功能开发中...' });
          })
          Divider().color('#F5F5F5').height(1)

          this.MenuItem('🎨', '主题设置', () => {
            promptAction.showToast({ message: '主题设置功能开发中...' });
          })
          Divider().color('#F5F5F5').height(1)

          this.MenuItem('🔒', '隐私设置', () => {
            promptAction.showToast({ message: '隐私设置功能开发中...' });
          })
          Divider().color('#F5F5F5').height(1)

          this.MenuItem('❓', '帮助与反馈', () => {
            promptAction.showToast({ message: '帮助与反馈功能开发中...' });
          })
          Divider().color('#F5F5F5').height(1)

          this.MenuItem('ℹ️', '关于', () => {
            promptAction.showToast({ message: '关于功能开发中...' });
          })
        }
        .margin({ top: 16 })
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .padding({ top: 8, bottom: 8 })

        // 底部导航栏
        TabBar({ currentIndex: 4 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 