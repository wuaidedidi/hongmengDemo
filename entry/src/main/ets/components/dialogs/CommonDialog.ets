// 通用对话框组件

import { DialogOffset } from '../../types/CommonTypes';
import { UI_SIZES, FONT_SIZES, SHADOW_CONSTANTS, OPACITY_CONSTANTS } from '../../constants/AppConstants';

/**
 * 对话框按钮配置接口
 */
export interface DialogButton {
  text: string;
  action: () => void;
  type?: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
}

/**
 * 对话框配置接口
 */
export interface DialogConfig {
  title: string;
  content?: string;
  contentBuilder?: () => void;
  buttons: DialogButton[];
  showCancel?: boolean;
  cancelText?: string;
  backgroundColor?: string;
  titleColor?: string;
  contentColor?: string;
  borderRadius?: number;
  width?: number;
  showCloseButton?: boolean;
}

/**
 * 通用对话框组件
 */
@CustomDialog
export struct CommonDialog {
  controller: CustomDialogController;
  config: DialogConfig;
  @State offset: DialogOffset = { dx: 0, dy: 0 };

  /**
   * 构建对话框内容
   */
  build() {
    Column() {
      // 对话框标题和关闭按钮
      Row() {
        Text(this.config.title)
          .fontSize(FONT_SIZES.TITLE_MEDIUM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.config.titleColor || '#000000')
          .layoutWeight(1)

        if (this.config.showCloseButton) {
          Text('×')
            .fontSize(FONT_SIZES.TITLE_LARGE)
            .fontColor('#666666')
            .onClick(() => {
              this.controller.close();
            })
        }
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 对话框内容
      Column() {
        if (this.config.content) {
          Text(this.config.content)
            .fontSize(FONT_SIZES.BODY_LARGE)
            .fontColor(this.config.contentColor || '#666666')
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ bottom: 16 })
        }

        if (this.config.contentBuilder) {
          this.config.contentBuilder();
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 对话框按钮
      Row() {
        if (this.config.showCancel) {
          Button(this.config.cancelText || '取消')
            .fontSize(FONT_SIZES.BODY_LARGE)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .fontColor('#666666')
            .borderRadius(UI_SIZES.BUTTON_BORDER_RADIUS)
            .layoutWeight(1)
            .height(UI_SIZES.BUTTON_HEIGHT)
            .margin({ right: 8 })
            .onClick(() => {
              this.controller.close();
            })
        }

        ForEach(this.config.buttons, (button: DialogButton, index: number) => {
          Button(button.text)
            .fontSize(FONT_SIZES.BODY_LARGE)
            .backgroundColor(this.getButtonColor(button.type))
            .fontColor(this.getButtonTextColor(button.type))
            .borderRadius(UI_SIZES.BUTTON_BORDER_RADIUS)
            .layoutWeight(1)
            .height(UI_SIZES.BUTTON_HEIGHT)
            .margin({ 
              left: index > 0 || this.config.showCancel ? 8 : 0 
            })
            .enabled(!button.disabled)
            .opacity(button.disabled ? OPACITY_CONSTANTS.TEXT_DISABLED : OPACITY_CONSTANTS.FULLY_OPAQUE)
            .onClick(() => {
              button.action();
              this.controller.close();
            })
        })
      }
      .width('100%')
      .margin({ top: 24 })
    }
    .padding(UI_SIZES.DIALOG_PADDING)
    .backgroundColor(this.config.backgroundColor || '#FFFFFF')
    .borderRadius(this.config.borderRadius || UI_SIZES.DIALOG_BORDER_RADIUS)
    .width(this.config.width || UI_SIZES.DIALOG_WIDTH)
    .shadow({
      radius: SHADOW_CONSTANTS.RADIUS_LARGE,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: SHADOW_CONSTANTS.OFFSET_Y_MEDIUM
    })
    .offset({ x: this.offset.dx, y: this.offset.dy })
    .gesture(
      PanGesture()
        .onActionStart((event: GestureEvent) => {
          // 可拖拽
        })
        .onActionUpdate((event: GestureEvent) => {
          this.offset = {
            dx: this.offset.dx + event.offsetX,
            dy: this.offset.dy + event.offsetY
          };
        })
        .onActionEnd(() => {
          // 可以添加边界检查和回弹动画
        })
    )
  }

  /**
   * 获取按钮背景颜色
   */
  private getButtonColor(type?: string): string {
    switch (type) {
      case 'primary':
        return '#007AFF';
      case 'danger':
        return '#FF3B30';
      case 'secondary':
      default:
        return 'rgba(0, 122, 255, 0.1)';
    }
  }

  /**
   * 获取按钮文字颜色
   */
  private getButtonTextColor(type?: string): string {
    switch (type) {
      case 'primary':
      case 'danger':
        return '#FFFFFF';
      case 'secondary':
      default:
        return '#007AFF';
    }
  }
}

/**
 * 确认对话框
 */
@CustomDialog
export struct ConfirmDialog {
  controller: CustomDialogController;
  title: string;
  message: string;
  confirmText?: string = '确定';
  cancelText?: string = '取消';
  onConfirm: () => void;
  onCancel?: () => void;
  dangerAction?: boolean = false;

  build() {
    Column() {
      Text(this.title)
        .fontSize(FONT_SIZES.TITLE_MEDIUM)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Text(this.message)
        .fontSize(FONT_SIZES.BODY_LARGE)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 24 })

      Row() {
        Button(this.cancelText)
          .fontSize(FONT_SIZES.BODY_LARGE)
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .fontColor('#666666')
          .borderRadius(UI_SIZES.BUTTON_BORDER_RADIUS)
          .layoutWeight(1)
          .height(UI_SIZES.BUTTON_HEIGHT)
          .margin({ right: 8 })
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
            this.controller.close();
          })

        Button(this.confirmText)
          .fontSize(FONT_SIZES.BODY_LARGE)
          .backgroundColor(this.dangerAction ? '#FF3B30' : '#007AFF')
          .fontColor('#FFFFFF')
          .borderRadius(UI_SIZES.BUTTON_BORDER_RADIUS)
          .layoutWeight(1)
          .height(UI_SIZES.BUTTON_HEIGHT)
          .margin({ left: 8 })
          .onClick(() => {
            this.onConfirm();
            this.controller.close();
          })
      }
      .width('100%')
    }
    .padding(UI_SIZES.DIALOG_PADDING)
    .backgroundColor('#FFFFFF')
    .borderRadius(UI_SIZES.DIALOG_BORDER_RADIUS)
    .width(300)
    .shadow({
      radius: SHADOW_CONSTANTS.RADIUS_LARGE,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: SHADOW_CONSTANTS.OFFSET_Y_MEDIUM
    })
  }
}

/**
 * 输入对话框
 */
@CustomDialog
export struct InputDialog {
  controller: CustomDialogController;
  title: string;
  placeholder?: string = '请输入内容';
  initialValue?: string = '';
  maxLength?: number = 100;
  confirmText?: string = '确定';
  cancelText?: string = '取消';
  onConfirm: (value: string) => void;
  onCancel?: () => void;
  @State inputValue: string = '';

  aboutToAppear() {
    this.inputValue = this.initialValue || '';
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(FONT_SIZES.TITLE_MEDIUM)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      TextInput({
        placeholder: this.placeholder,
        text: this.inputValue
      })
        .fontSize(FONT_SIZES.BODY_LARGE)
        .height(48)
        .borderRadius(8)
        .backgroundColor('#F5F5F5')
        .margin({ bottom: 24 })
        .maxLength(this.maxLength)
        .onChange((value: string) => {
          this.inputValue = value;
        })

      Row() {
        Button(this.cancelText)
          .fontSize(FONT_SIZES.BODY_LARGE)
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .fontColor('#666666')
          .borderRadius(UI_SIZES.BUTTON_BORDER_RADIUS)
          .layoutWeight(1)
          .height(UI_SIZES.BUTTON_HEIGHT)
          .margin({ right: 8 })
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
            this.controller.close();
          })

        Button(this.confirmText)
          .fontSize(FONT_SIZES.BODY_LARGE)
          .backgroundColor('#007AFF')
          .fontColor('#FFFFFF')
          .borderRadius(UI_SIZES.BUTTON_BORDER_RADIUS)
          .layoutWeight(1)
          .height(UI_SIZES.BUTTON_HEIGHT)
          .margin({ left: 8 })
          .enabled(this.inputValue.trim().length > 0)
          .opacity(this.inputValue.trim().length > 0 ? 1.0 : 0.5)
          .onClick(() => {
            if (this.inputValue.trim().length > 0) {
              this.onConfirm(this.inputValue.trim());
              this.controller.close();
            }
          })
      }
      .width('100%')
    }
    .padding(UI_SIZES.DIALOG_PADDING)
    .backgroundColor('#FFFFFF')
    .borderRadius(UI_SIZES.DIALOG_BORDER_RADIUS)
    .width(320)
    .shadow({
      radius: SHADOW_CONSTANTS.RADIUS_LARGE,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: SHADOW_CONSTANTS.OFFSET_Y_MEDIUM
    })
  }
}

/**
 * 选择对话框
 */
export interface SelectOption {
  label: string;
  value: any;
  disabled?: boolean;
}

@CustomDialog
export struct SelectDialog {
  controller: CustomDialogController;
  title: string;
  options: SelectOption[];
  onSelect: (option: SelectOption) => void;
  onCancel?: () => void;
  showCancel?: boolean = true;

  build() {
    Column() {
      Text(this.title)
        .fontSize(FONT_SIZES.TITLE_MEDIUM)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      List() {
        ForEach(this.options, (option: SelectOption) => {
          ListItem() {
            Text(option.label)
              .fontSize(FONT_SIZES.BODY_LARGE)
              .fontColor(option.disabled ? '#CCCCCC' : '#000000')
              .width('100%')
              .height(48)
              .textAlign(TextAlign.Center)
              .backgroundColor(option.disabled ? 'rgba(0, 0, 0, 0.02)' : 'transparent')
              .borderRadius(8)
              .onClick(() => {
                if (!option.disabled) {
                  this.onSelect(option);
                  this.controller.close();
                }
              })
          }
          .margin({ bottom: 4 })
        })
      }
      .width('100%')
      .maxHeight(300)
      .margin({ bottom: 16 })

      if (this.showCancel) {
        Button('取消')
          .fontSize(FONT_SIZES.BODY_LARGE)
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .fontColor('#666666')
          .borderRadius(UI_SIZES.BUTTON_BORDER_RADIUS)
          .width('100%')
          .height(UI_SIZES.BUTTON_HEIGHT)
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
            this.controller.close();
          })
      }
    }
    .padding(UI_SIZES.DIALOG_PADDING)
    .backgroundColor('#FFFFFF')
    .borderRadius(UI_SIZES.DIALOG_BORDER_RADIUS)
    .width(280)
    .shadow({
      radius: SHADOW_CONSTANTS.RADIUS_LARGE,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: SHADOW_CONSTANTS.OFFSET_Y_MEDIUM
    })
  }
} 