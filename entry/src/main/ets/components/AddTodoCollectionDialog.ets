import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';

interface TodoCollectionData {
  title: string;
  description?: string;
}

@CustomDialog
export struct AddTodoCollectionDialog {
  @State title: string = '';
  @State description: string = '';
  @Prop currentTheme: ThemeConfig; // 改为Prop，由父组件传递
  
  onConfirm: (data: TodoCollectionData) => void = () => {};
  controller: CustomDialogController;

  aboutToAppear() {
    console.info('AddTodoCollectionDialog接收到主题:', this.currentTheme.name);
    console.info('主题颜色:', {
      backgroundColor: this.currentTheme.backgroundColor,
      accentPrimary: this.currentTheme.glassmorphism.accentPrimary,
      surfaceLight: this.currentTheme.glassmorphism.surfaceLight
    });
  }

  build() {
    Column({ space: 20 }) {
      // 标题区域
      Column({ space: 8 }) {
        Text('📝')
          .fontSize(32)
        Text('添加待办合集')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.textColor)
      }
      .alignItems(HorizontalAlign.Center)

      Column({ space: 16 }) {
        // 标题输入
        Column({ space: 8 }) {
          Text('标题 *')
            .fontSize(14)
            .fontColor(this.currentTheme.glassmorphism.accentPrimary)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
          
          TextInput({ placeholder: '请输入合集标题' })
            .borderRadius(16)
            .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'D0')
            .border({ 
              width: 0.5, 
              color: this.currentTheme.glassmorphism.accentSecondary + '50' 
            })
            .placeholderColor(this.currentTheme.textColor + '80')
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
              this.title = value;
            })
        }
        .alignItems(HorizontalAlign.Start)

        // 描述输入
        Column({ space: 8 }) {
          Text('描述')
            .fontSize(14)
            .fontColor(this.currentTheme.glassmorphism.accentSecondary)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
          
          TextArea({ placeholder: '请输入合集描述（可选）' })
            .height(80)
            .borderRadius(16)
            .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'D0')
            .border({ 
              width: 0.5, 
              color: this.currentTheme.glassmorphism.accentSecondary + '50' 
            })
            .placeholderColor(this.currentTheme.textColor + '80')
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
              this.description = value;
            })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 按钮区域 - 苹果风格渐变设计
      Row({ space:12 }) {
        Button('取消')
          .fontSize(16)
          .fontColor(this.currentTheme.glassmorphism.accentSecondary)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'B0')
          .border({ 
            width: 0.5, 
            color: this.currentTheme.glassmorphism.accentSecondary + '60' 
          })
          .borderRadius(16)
          .layoutWeight(1)
          .height(48)
          .backdropBlur(8)
          .shadow({
            radius: 8,
            color: this.currentTheme.glassmorphism.accentSecondary + '20',
            offsetX: 0,
            offsetY: 2
          })
          .onClick(() => {
            this.controller.close();
          })

        Button('确认')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .linearGradient({
            angle: 135,
            colors: [
              [this.currentTheme.glassmorphism.accentPrimary, 0.0],
              [this.currentTheme.glassmorphism.accentSecondary, 1.0]
            ]
          })
          .borderRadius(16)
          .border({ 
            width: 0.5, 
            color: this.currentTheme.glassmorphism.accentPrimary + '60' 
          })
          .layoutWeight(1)
          .height(48)
          .backdropBlur(8)
          .shadow({
            radius: 12,
            color: this.currentTheme.glassmorphism.accentPrimary + '50',
            offsetX: 0,
            offsetY: 3
          })
          .blur(0.2) // 哑光效果
          .enabled(this.title.trim().length > 0)
          .opacity(this.title.trim().length > 0 ? 1.0 : 0.5)
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
    .width(320)
    .padding(24)
    .backgroundColor(Color.Transparent) // 完全透明的外层背景
    .borderRadius(24)
    .backdropBlur(20)
    .linearGradient({
      angle: 135,
      colors: [
        [this.currentTheme.backgroundColor + 'E8', 0.0],
        [this.currentTheme.glassmorphism.surfaceLight + 'F0', 1.0]
      ]
    })
    .shadow({
      radius: 30,
      color: this.currentTheme.glassmorphism.accentPrimary + '25',
      offsetX: 0,
      offsetY: 12
    })
  }
} 