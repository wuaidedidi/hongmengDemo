@CustomDialog
export struct AddSubTodoDialog {
  @State title: string = '';
  @State description: string = '';
  @State durationMinutes: number = 25;
  
  onConfirm: (title: string, description: string, duration: number) => void = () => {};
  controller: CustomDialogController;

  build() {
    Column({ space: 16 }) {
      Text('添加子待办')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      Column({ space: 12 }) {
        // 标题输入
        Column({ space: 4 }) {
          Text('标题 *')
            .fontSize(14)
            .fontColor('#333333')
            .alignSelf(ItemAlign.Start)
          
          TextInput({ placeholder: '请输入子待办标题' })
            .height(40)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
            .onChange((value: string) => {
              this.title = value;
            })
        }
        .alignItems(HorizontalAlign.Start)

        // 描述输入
        Column({ space: 4 }) {
          Text('描述')
            .fontSize(14)
            .fontColor('#333333')
            .alignSelf(ItemAlign.Start)
          
          TextArea({ placeholder: '请输入子待办描述（可选）' })
            .height(80)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
            .onChange((value: string) => {
              this.description = value;
            })
        }
        .alignItems(HorizontalAlign.Start)

        // 专注时长设置
        Column({ space: 4 }) {
          Text('专注时长')
            .fontSize(14)
            .fontColor('#333333')
            .alignSelf(ItemAlign.Start)
          
          Row({ space: 8 }) {
            TextInput({ text: this.durationMinutes.toString() })
              .width(80)
              .height(40)
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .type(InputType.Number)
              .onChange((value: string) => {
                const num = parseInt(value);
                if (!isNaN(num) && num > 0) {
                  this.durationMinutes = num;
                }
              })
            
            Text('分钟')
              .fontSize(14)
              .fontColor('#666666')
          }
          .alignItems(VerticalAlign.Center)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 按钮区域
      Row({ space: 12 }) {
        Button('取消')
          .fontSize(16)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
          .layoutWeight(1)
          .height(44)
          .onClick(() => {
            this.controller.close();
          })

        Button('确认')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .borderRadius(8)
          .layoutWeight(1)
          .height(44)
          .enabled(this.title.trim().length > 0)
          .onClick(() => {
            if (this.title.trim().length > 0) {
              this.onConfirm(this.title.trim(), this.description.trim(), this.durationMinutes);
              this.controller.close();
            }
          })
      }
      .width('100%')
    }
    .width(300)
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
} 