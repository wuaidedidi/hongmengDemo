// Index.ets
@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  // 使用一个半透明的粉色背景色
  @State bgColor: string = 'rgba(255, 192, 203, 0.15)';
  @State isDialogShow: boolean = false;
  @State todoName: string = '';

  build() {
    Stack() {
      // 整页背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.bgColor)
      
      Column() {
        // 顶部标题栏
        Row() {
          Text('待办')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          
          Blank()
          
          Row({ space: 16 }) {
            Text('✓').fontSize(24).fontColor('#FFFFFF')
            Text('+')
              .fontSize(24)
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.isDialogShow = true;
              })
            Text('≡').fontSize(24).fontColor('#FFFFFF')
          }
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .linearGradient({
          angle: 90,
          colors: [['#8A2BE2', 0.0], ['#FF1493', 1.0]]
        })
        
        // 任务列表部分
        Column() {
          // 列表卡片
          Column({ space: 16 }) {
            // 卡片1
            Row() {
              Column() {
                Text('行1: 用户信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              Text('⭐')
                .fontSize(24)
                .margin({ right: 8 })
            }
            .height(56)
            .width('100%')
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({ radius: 6, color: 'rgba(138, 43, 226, 0.15)', offsetX: 0, offsetY: 4 })
            
            // 卡片2
            Row() {
              Column() {
                Text('行2: 订单管理')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              Text('🛒')
                .fontSize(24)
                .margin({ right: 8 })
            }
            .height(56)
            .width('100%')
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({ radius: 6, color: 'rgba(138, 43, 226, 0.15)', offsetX: 0, offsetY: 4 })
            
            // 卡片3
            Row() {
              Column() {
                Text('行3: 联系方式')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              Text('📞')
                .fontSize(24)
                .margin({ right: 8 })
            }
            .height(56)
            .width('100%')
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({ radius: 6, color: 'rgba(138, 43, 226, 0.15)', offsetX: 0, offsetY: 4 })
            
            // 卡片4
            Row() {
              Column() {
                Text('行4: 账户信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              Text('💰')
                .fontSize(24)
                .margin({ right: 8 })
            }
            .height(56)
            .width('100%')
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({ radius: 6, color: 'rgba(138, 43, 226, 0.15)', offsetX: 0, offsetY: 4 })
          }
          .width('100%')
          
          // 浮动按钮提示
          Row() {
            Text('双击编辑 AI 组件')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
          .backgroundColor('rgba(138, 43, 226, 0.8)')
          .borderRadius(24)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .position({ x: '30%', y: '50%' })
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
        
        // 底部导航栏
        Row() {
          Column() {
            Text('📅').fontSize(24)
            Text('待办').fontSize(12).margin({ top: 4 }).fontColor('#8A2BE2')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          
          Column() {
            Text('📝').fontSize(24)
            Text('待办事项').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          
          Column() {
            Text('🔒').fontSize(24)
            Text('锁机').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          
          Column() {
            Text('📊').fontSize(24)
            Text('统计数据').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          
          Column() {
            Text('👤').fontSize(24)
            Text('我的').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        }
        .height(56)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 1 }, color: { top: '#E0E0E0' } })
      }
      .width('100%')
      .height('100%')
      
      // 添加待办弹窗
      if (this.isDialogShow) {
        Column() {
          Column() {
            // 弹窗标题
            Text('添加待办')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 16, bottom: 20 })
            
            // 输入框
            TextInput({ placeholder: '请输入待办名称' })
              .width('90%')
              .height(50)
              .fontSize(16)
              .placeholderFont({ size: 16 })
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .margin({ bottom: 20 })
              .onChange((value: string) => {
                this.todoName = value;
              })
            
            // 第一行按钮
            Row({ space: 12 }) {
              Button('白兔钟')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('定目标')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('养习惯')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
            }
            .width('90%')
            .margin({ bottom: 12 })
            
            // 第二行按钮
            Row({ space: 12 }) {
              Button('倒计时')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('正向计时')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('不计时')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
            }
            .width('90%')
            .margin({ bottom: 12 })
            
            // 第三行按钮
            Row({ space: 12 }) {
              Button('25分钟')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('35分钟')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('自定义')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
            }
            .width('90%')
            .margin({ bottom: 16 })
            
            // 确认和取消按钮
            Row({ space: 16 }) {
              Button('取消')
                .width('40%')
                .height(45)
                .borderRadius(22)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
                .onClick(() => {
                  this.isDialogShow = false;
                })
              
              Button('确认')
                .width('40%')
                .height(45)
                .borderRadius(22)
                .backgroundColor('#8A2BE2')
                .fontColor('#FFFFFF')
                .onClick(() => {
                  this.isDialogShow = false;
                  // 可以添加保存待办的逻辑
                })
            }
            .margin({ bottom: 16 })
          }
          .width('85%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding({ top: 10, bottom: 10 })
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.isDialogShow = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}