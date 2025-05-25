import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface TodoOperationResult {
  id: string | number;
  title: string;
  duration: number;
}

@CustomDialog
struct DeleteConfirmDialog {
  controller: CustomDialogController;
  onConfirm: () => void = () => {};

  build() {
    Column() {
      Text('删除待办')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 10 })
      
      Text('确定要删除这个待办吗？')
        .fontSize(16)
        .margin({ top: 10, bottom: 20 })
      
      Row() {
        Button('取消')
          .onClick(() => {
            this.controller.close();
          })
          .margin({ right: 10 })
        
        Button('删除')
          .fontColor('#FF3B30')
          .onClick(() => {
            this.onConfirm();
            this.controller.close();
          })
      }
      .margin({ top: 10, bottom: 10 })
    }
    .width('80%')
    .padding(20)
  }
}

@Entry
@Component
struct TodoOperation {
  @State todoId: string | number = '';
  @State todoTitle: string = '';
  @State todoDuration: number = 25;
  @State isEditMode: boolean = false;
  @State showDeleteConfirm: boolean = false;
  private deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: DeleteConfirmDialog({
      onConfirm: () => {
        this.deleteTodo();
      }
    })
  });

  aboutToAppear() {
    const params = router.getParams() as Record<string, string | number>;
    if (params) {
      this.todoId = params.todoId || '';
      this.todoTitle = params.todoTitle as string || '';
      this.isEditMode = true;
    }
  }

  // 保存待办
  saveTodo() {
    if (this.todoTitle.trim() === '') {
      promptAction.showToast({ message: '请输入待办标题' });
      return;
    }

    const result: TodoOperationResult = {
      id: this.todoId,
      title: this.todoTitle,
      duration: this.todoDuration
    };

    router.back({
      url: 'pages/Index',
      params: {
        action: this.isEditMode ? 'edit' : 'add',
        id: result.id,
        title: result.title,
        duration: result.duration
      }
    });
  }

  // 删除待办
  deleteTodo() {
    router.back({
      url: 'pages/Index',
      params: {
        action: 'delete',
        todoId: this.todoId
      }
    });
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

        Text(this.isEditMode ? '编辑待办' : '新建待办')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16 })

        Blank()

        if (this.isEditMode) {
          Text('删除')
            .fontSize(16)
            .fontColor('#FF3B30')
            .margin({ right: 16 })
            .onClick(() => {
              this.deleteDialogController.open();
            })
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      // 表单内容
      Column() {
        // 标题输入
        Column() {
          Text('标题')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入待办标题', text: this.todoTitle })
            .width('100%')
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.todoTitle = value;
            })
        }
        .width('100%')
        .padding(16)

        // 时长设置
        Column() {
          Text('时长（分钟）')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          Row() {
            Button('-')
              .width(48)
              .height(48)
              .fontSize(20)
              .fontColor('#333333')
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onClick(() => {
                if (this.todoDuration > 5) {
                  this.todoDuration -= 5;
                }
              })

            Text(this.todoDuration.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ left: 16, right: 16 })

            Button('+')
              .width(48)
              .height(48)
              .fontSize(20)
              .fontColor('#333333')
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onClick(() => {
                this.todoDuration += 5;
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding(16)

        // 保存按钮
        Button('保存')
          .width('90%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#8A2BE2')
          .borderRadius(24)
          .margin({ top: 32 })
          .onClick(() => {
            this.saveTodo();
          })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
} 