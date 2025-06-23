// 统一的待办相关对话框组件

import promptAction from '@ohos.promptAction';
import { ThemeConfig } from '../../services/ThemeService';
import { CommonButton, ButtonPresets } from '../common/CommonButton';
import { UI_SIZES, FONT_SIZES, STRINGS } from '../../constants/AppConstants';

/**
 * 添加待办对话框
 */
@CustomDialog
export struct AddTodoDialog {
  @State todoName: string = '';
  @State todoType: string = '';
  @State todoDuration: number = 25;
  @Prop currentTheme: ThemeConfig;
  
  onConfirm: (name: string, type: string, duration: number) => void = () => {};
  controller?: CustomDialogController;

  build() {
    Column({ space: 20 }) {
      Text('添加新待办')
        .fontSize(FONT_SIZES.TITLE_MEDIUM)
        .fontColor(this.currentTheme.textColor)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: "待办名称", text: this.todoName })
        .onChange(val => this.todoName = val)
        .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
        .borderRadius(12)
        .fontColor(this.currentTheme.textColor)
        .height(48)

      TextInput({ placeholder: "待办类型", text: this.todoType })
        .onChange(val => this.todoType = val)
        .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
        .borderRadius(12)
        .fontColor(this.currentTheme.textColor)
        .height(48)

      Row() {
        Text('专注时长:')
          .fontSize(FONT_SIZES.BODY_MEDIUM)
          .fontColor(this.currentTheme.textColor)
        
        Slider({
          value: this.todoDuration,
          min: 5,
          max: 120,
          step: 5
        })
          .width(120)
          .trackColor(this.currentTheme.glassmorphism.surfaceLight)
          .selectedColor(this.currentTheme.glassmorphism.accentPrimary)
          .onChange((value: number) => this.todoDuration = value)
        
        Text(`${this.todoDuration}分钟`)
          .fontSize(FONT_SIZES.BODY_MEDIUM)
          .fontColor(this.currentTheme.textColor)
      }
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        CommonButton({
          config: ButtonPresets.secondary(STRINGS.CANCEL, () => {
            this.controller?.close();
          })
        })
        .layoutWeight(1)
        .margin({ right: 8 })

        CommonButton({
          config: ButtonPresets.primary(STRINGS.CONFIRM, () => {
            if (!this.todoName.trim()) {
              promptAction.showToast({ message: '请输入待办名称' });
              return;
            }
            this.onConfirm(this.todoName, this.todoType, this.todoDuration);
            this.controller?.close();
          })
        })
        .layoutWeight(1)
        .margin({ left: 8 })
      }
    }
    .padding(24)
    .width(320)
    .backgroundColor(this.currentTheme.backgroundColor)
    .borderRadius(16)
    .border({ 
      width: 0.5, 
      color: this.currentTheme.glassmorphism.accentPrimary + '40' 
    })
    .shadow({
      radius: 25,
      color: this.currentTheme.glassmorphism.accentPrimary + '30',
      offsetX: 0,
      offsetY: 10
    })
  }
}

/**
 * 添加待办合集对话框 - 精美版本，兼容旧接口
 */
@CustomDialog
export struct AddCollectionDialog {
  @State collectionTitle: string = '';
  @State collectionDescription: string = '';
  @Prop currentTheme: ThemeConfig;
  controller?: CustomDialogController;
  onConfirm: (title: string, description?: string) => void = () => {};

  build() {
    Column({ space: 20 }) {
      // 标题区域
      Column({ space: 8 }) {
        Text('📝')
          .fontSize(28)
        Text('添加待办合集')
          .fontSize(FONT_SIZES.TITLE_MEDIUM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.textColor)
      }
      .alignItems(HorizontalAlign.Center)

      Column({ space: 16 }) {
        // 合集名称输入
        Column({ space: 8 }) {
          Text('合集名称 *')
            .fontSize(FONT_SIZES.BODY_SMALL)
            .fontColor(this.currentTheme.glassmorphism.accentPrimary)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
          
          TextInput({ placeholder: '请输入合集名称', text: this.collectionTitle })
            .borderRadius(12)
            .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'D0')
            .border({ 
              width: 0.5, 
              color: this.currentTheme.glassmorphism.accentSecondary + '50' 
            })
            .placeholderColor(this.currentTheme.textColor + '60')
            .fontColor(this.currentTheme.textColor)
            .padding(16)
            .height(48)
            .backdropBlur(8)
            .shadow({
              radius: 6,
              color: this.currentTheme.glassmorphism.accentPrimary + '20',
              offsetX: 0,
              offsetY: 2
            })
            .onChange((value: string) => {
              this.collectionTitle = value;
            })
        }
        .alignItems(HorizontalAlign.Start)

        // 描述输入（可选）
        Column({ space: 8 }) {
          Text('描述')
            .fontSize(FONT_SIZES.BODY_SMALL)
            .fontColor(this.currentTheme.glassmorphism.accentSecondary)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
          
          TextArea({ placeholder: '请输入合集描述（可选）', text: this.collectionDescription })
            .height(70)
            .borderRadius(12)
            .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'D0')
            .border({ 
              width: 0.5, 
              color: this.currentTheme.glassmorphism.accentSecondary + '50' 
            })
            .placeholderColor(this.currentTheme.textColor + '60')
            .fontColor(this.currentTheme.textColor)
            .padding(16)
            .backdropBlur(8)
            .shadow({
              radius: 6,
              color: this.currentTheme.glassmorphism.accentPrimary + '20',
              offsetX: 0,
              offsetY: 2
            })
            .onChange((value: string) => {
              this.collectionDescription = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 按钮区域
      Row({ space: 12 }) {
        CommonButton({
          config: ButtonPresets.secondary(STRINGS.CANCEL, () => {
            this.controller?.close();
          })
        })
        .layoutWeight(1)

        CommonButton({
          config: ButtonPresets.primary(STRINGS.CONFIRM, () => {
            if (!this.collectionTitle.trim()) {
              promptAction.showToast({ message: '合集名称不能为空' });
              return;
            }
            // 向后兼容，只传递标题参数
            this.onConfirm(this.collectionTitle.trim(), this.collectionDescription.trim() || undefined);
            this.controller?.close();
          })
        })
        .layoutWeight(1)
        .enabled(this.collectionTitle.trim().length > 0)
        .opacity(this.collectionTitle.trim().length > 0 ? 1.0 : 0.5)
      }
    }
    .width(340)
    .padding(24)
    .backgroundColor(this.currentTheme.backgroundColor)
    .borderRadius(20)
    .border({ 
      width: 0.5, 
      color: this.currentTheme.glassmorphism.accentPrimary + '40' 
    })
    .shadow({
      radius: 25,
      color: this.currentTheme.glassmorphism.accentPrimary + '30',
      offsetX: 0,
      offsetY: 10
    })
    .backdropBlur(15)
  }
}

/**
 * 权限设置对话框
 */
@CustomDialog
export struct PermissionDialog {
  @Prop currentTheme: ThemeConfig;
  controller?: CustomDialogController;
  onConfirm: () => void = () => {};

  build() {
    Column({ space: 20 }) {
      Column() {
        Text('⚙️')
          .fontSize(32)
          .margin({ bottom: 8 })
        Text('权限设置')
          .fontSize(FONT_SIZES.TITLE_MEDIUM)
          .fontColor(this.currentTheme.textColor)
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(HorizontalAlign.Center)

      Column({ space: 12 }) {
        Text('请确保以下权限已开启：')
          .fontSize(FONT_SIZES.BODY_MEDIUM)
          .fontColor(this.currentTheme.textColor)
          .textAlign(TextAlign.Center)

        Column({ space: 8 }) {
          Text('• 通知权限')
            .fontSize(FONT_SIZES.BODY_SMALL)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.8)
          
          Text('• 后台运行权限')
            .fontSize(FONT_SIZES.BODY_SMALL)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.8)
          
          Text('• 自启动权限')
            .fontSize(FONT_SIZES.BODY_SMALL)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.8)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }

      Row() {
        CommonButton({
          config: ButtonPresets.secondary(STRINGS.CANCEL, () => {
            this.controller?.close();
          })
        })
        .layoutWeight(1)
        .margin({ right: 8 })

        CommonButton({
          config: ButtonPresets.primary('去设置', () => {
            this.onConfirm();
            this.controller?.close();
          })
        })
        .layoutWeight(1)
        .margin({ left: 8 })
      }
    }
    .padding(24)
    .width(320)
    .backgroundColor(this.currentTheme.backgroundColor)
    .borderRadius(16)
    .border({ 
      width: 0.5, 
      color: this.currentTheme.glassmorphism.accentPrimary + '40' 
    })
    .shadow({
      radius: 25,
      color: this.currentTheme.glassmorphism.accentPrimary + '30',
      offsetX: 0,
      offsetY: 10
    })
  }
}

/**
 * 添加子任务对话框
 */
@CustomDialog
export struct AddSubTaskDialog {
  @State taskTitle: string = '';
  @State taskDuration: number = 25;
  @Prop currentTheme: ThemeConfig;
  controller?: CustomDialogController;
  onConfirm: (title: string, duration: number) => void = () => {};

  build() {
    Column({ space: 20 }) {
      Text('添加子任务')
        .fontSize(FONT_SIZES.TITLE_MEDIUM)
        .fontColor(this.currentTheme.textColor)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: "请输入任务标题", text: this.taskTitle })
        .onChange(val => this.taskTitle = val)
        .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
        .borderRadius(12)
        .fontColor(this.currentTheme.textColor)
        .height(48)

      TextInput({ placeholder: "请输入时长（分钟）", text: this.taskDuration.toString() })
        .type(InputType.Number)
        .onChange(val => this.taskDuration = parseInt(val) || 25)
        .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
        .borderRadius(12)
        .fontColor(this.currentTheme.textColor)
        .height(48)

      Row() {
        CommonButton({
          config: ButtonPresets.secondary(STRINGS.CANCEL, () => {
            this.controller?.close();
          })
        })
        .layoutWeight(1)
        .margin({ right: 8 })

        CommonButton({
          config: ButtonPresets.primary(STRINGS.CONFIRM, () => {
            if (!this.taskTitle.trim()) {
              promptAction.showToast({ message: '标题不能为空' });
              return;
            }
            this.onConfirm(this.taskTitle, this.taskDuration);
            this.controller?.close();
          })
        })
        .layoutWeight(1)
        .margin({ left: 8 })
      }
    }
    .padding(24)
    .width(320)
    .backgroundColor(this.currentTheme.backgroundColor)
    .borderRadius(16)
    .border({ 
      width: 0.5, 
      color: this.currentTheme.glassmorphism.accentPrimary + '40' 
    })
    .shadow({
      radius: 25,
      color: this.currentTheme.glassmorphism.accentPrimary + '30',
      offsetX: 0,
      offsetY: 10
    })
  }
} 