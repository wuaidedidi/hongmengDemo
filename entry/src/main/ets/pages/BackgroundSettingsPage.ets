import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import promptAction from '@ohos.promptAction';
import bundleManager from '@ohos.bundle.bundleManager';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import { BackgroundManager } from '../common/BackgroundManager';
import backgroundManagerFactory from '../common/BackgroundManager';

@Entry
@Component
struct BackgroundSettingsPage {
  @State currentSetting: string = '智能限制后台运行（推荐）';
  @State isLoading: boolean = true;
  private context: common.UIAbilityContext | undefined = undefined;
  private bundleName: string = '';
  private backgroundManager: BackgroundManager | null = null;
  // SVG图标路径
  private checkIcon: string = 'common/images/ic_check.svg';
  private backIcon: string = 'common/images/ic_back.svg';

  aboutToAppear() {
    // 初始化后台管理器
    this.context = this.getAppAbilityContext();
    if (!this.context) {
      console.error("BackgroundSettingsPage: Failed to get UIAbilityContext in aboutToAppear.");
      promptAction.showToast({ message: '无法初始化页面，缺少应用上下文' });
      this.isLoading = false;
      return;
    }

    this.backgroundManager = backgroundManagerFactory.getInstance(this.context);
    
    // 获取应用包名
    try {
      this.bundleName = this.context.applicationInfo?.name || '';
      console.info(`获取到应用包名: ${this.bundleName}`);
    } catch (error) {
      let errorMessage = '获取应用包名异常';
      if (error instanceof Error) {
        errorMessage = `${errorMessage}: ${error.message}`;
      } else {
        errorMessage = `${errorMessage}: ${String(error)}`;
      }
      console.error(errorMessage);
    }

    // 获取当前后台运行模式
    this.getCurrentMode();
  }

  // 获取当前后台运行模式
  async getCurrentMode() {
    if (!this.backgroundManager) {
      this.isLoading = false;
      return;
    }
    
    try {
      this.isLoading = true;
      const mode = await this.backgroundManager.getCurrentBackgroundMode();
      this.currentSetting = mode;
      this.isLoading = false;
    } catch (error) {
      let errorMessage = '获取当前后台模式失败';
      if (error instanceof Error) {
        errorMessage = `${errorMessage}: ${error.message}`;
      } else {
        errorMessage = `${errorMessage}: ${String(error)}`;
      }
      console.error(errorMessage);
      this.isLoading = false;
    }
  }

  // 设置后台运行模式
  async setBackgroundMode(mode: string) {
    if (!this.backgroundManager) {
      promptAction.showToast({
        message: '系统错误，请重试',
        duration: 2000
      });
      this.isLoading = false;
      return;
    }
    
    try {
      this.isLoading = true;
      const result = await this.backgroundManager.setBackgroundMode(mode);
      
      if (result) {
        this.currentSetting = mode;
        promptAction.showToast({
          message: `已设置为${mode}`,
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '设置失败，请重试',
          duration: 2000
        });
      }
      this.isLoading = false;
    } catch (error) {
      let errorMessage = '设置后台模式异常';
      if (error instanceof Error) {
        errorMessage = `${errorMessage}: ${error.message}`;
      } else {
        errorMessage = `${errorMessage}: ${String(error)}`;
      }
      console.error(errorMessage);
      promptAction.showToast({
        message: '设置失败，请重试',
        duration: 2000
      });
      this.isLoading = false;
    }
  }

  // 获取UIAbilityContext的辅助方法，避免使用as转换
  getAppAbilityContext(): common.UIAbilityContext | undefined {
    const context = getContext(this);
    
    // 检查context是否为对象
    if (context && typeof context === 'object') {
      try {
        // 尝试将context转为UIAbilityContext类型
        // 不使用特性检测，直接进行尝试，如果失败会抛出异常
        const uiContext = context as common.UIAbilityContext;
        // 如果能访问这些属性且不报错，说明转换成功
        if (uiContext.applicationInfo !== undefined) {
          return uiContext;
        }
      } catch (e) {
        console.error("Failed to convert context to UIAbilityContext");
      }
    }
    
    console.error('Failed to get valid UIAbilityContext or context is not of expected type in BackgroundSettingsPage.');
    return undefined;
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        // 使用Text替代Image作为返回按钮
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
        
        Text('番茄TODO')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      
      // 后台配置标题
      Text('后台配置')
        .fontSize(16)
        .fontColor('#666666')
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 8 })
        .backgroundColor('#F5F5F5')
      
      // 加载状态显示
      if (this.isLoading) {
        Row() {
          LoadingProgress().width(24).height(24)
          Text('正在加载...').fontSize(16).fontColor('#666666').margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 20, bottom: 20 })
        .backgroundColor('#FFFFFF')
      } else {
        // 无限制选项
        Column() {
          Row() {
            Column() {
              Text('无限制')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              Text('不采取任何限制措施')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            
            Blank()
            
            if (this.currentSetting === '无限制') {
              // 使用Text替代Image作为勾选图标
              Text('✓')
                .fontSize(20)
                .fontColor('#0080FF')
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .backgroundColor('#FFFFFF')
        .margin({ bottom: 1 })
        .onClick(() => {
          this.setBackgroundMode('无限制');
        })
        
        // 智能限制选项
        Column() {
          Row() {
            Column() {
              Text('智能限制后台运行（推荐）')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#0080FF')
              
              Text('智能识别应用及状态，并采取相应的限制措施，包括对后台联网、定位、传感器使用或CPU占用的限制，不影响即时消息')
                .fontSize(14)
                .fontColor('#0080FF')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            
            Blank()
            
            if (this.currentSetting === '智能限制后台运行（推荐）') {
              // 使用Text替代Image作为勾选图标
              Text('✓')
                .fontSize(20)
                .fontColor('#0080FF')
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .backgroundColor('#E6F2FF')
        .margin({ bottom: 1 })
        .onClick(() => {
          this.setBackgroundMode('智能限制后台运行（推荐）');
        })
        
        // 10分钟后关闭选项
        Column() {
          Row() {
            Column() {
              Text('后台运行超过10分钟后关闭')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              Text('在后台运行超过10分钟后，自动关闭')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            
            Blank()
            
            if (this.currentSetting === '后台运行超过10分钟后关闭') {
              // 使用Text替代Image作为勾选图标
              Text('✓')
                .fontSize(20)
                .fontColor('#0080FF')
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .backgroundColor('#FFFFFF')
        .margin({ bottom: 1 })
        .onClick(() => {
          this.setBackgroundMode('后台运行超过10分钟后关闭');
        })
        
        // 禁止后台运行选项
        Column() {
          Row() {
            Column() {
              Text('禁止后台运行')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              Text('完全禁止该应用在后台运行')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            
            Blank()
            
            if (this.currentSetting === '禁止后台运行') {
              // 使用Text替代Image作为勾选图标
              Text('✓')
                .fontSize(20)
                .fontColor('#0080FF')
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .backgroundColor('#FFFFFF')
        .margin({ bottom: 16 })
        .onClick(() => {
          this.setBackgroundMode('禁止后台运行');
        })
      }
      
      // 底部说明文字
      Text('系统可以智能地识别出处于即时通讯、导航、媒体播放等状态的后台应用，使用针对性的（包括但不限于已有通用选项）省电措施以保障其重要后台功能不受影响')
        .fontSize(14)
        .fontColor('#999999')
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 