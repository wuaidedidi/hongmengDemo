interface TodoCollectionData {
  title: string;
  description?: string;
}

@CustomDialog
export struct AddTodoCollectionDialog {
  @State title: string = '';
  @State description: string = '';
  
  onConfirm: (data: TodoCollectionData) => void = () => {};
  controller: CustomDialogController;

  build() {
    Column({ space: 16 }) {
      Text('添加待办合集')
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
          
          TextInput({ placeholder: '请输入合集标题' })
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
          
          TextArea({ placeholder: '请输入合集描述（可选）' })
            .height(80)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
            .onChange((value: string) => {
              this.description = value;
            })
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
              this.onConfirm({
                title: this.title.trim(),
                description: this.description.trim()
              });
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