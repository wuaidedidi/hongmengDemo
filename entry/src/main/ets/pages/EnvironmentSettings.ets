import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import { getAllEnvironments, EnvironmentConfig, DEFAULT_ENVIRONMENT } from '../config/Environment';
import { ThemeService, ThemeConfig } from '../services/ThemeService';

@Entry
@Component
struct EnvironmentSettings {
  @State currentEnvironment: string = DEFAULT_ENVIRONMENT;
  @State environments: EnvironmentConfig[] = getAllEnvironments();
  @State currentTheme: ThemeConfig = {
    id: 'light',
    name: '浅色主题',
    primaryColor: '#007AFF',
    backgroundColor: '#F2F2F7',
    textColor: '#000000',
    cardBackgroundColor: '#FFFFFF',
    borderColor: '#E5E5EA',
    shadowColor: '#00000010',
    errorColor: '#FF3B30'
  };
  private themeService = ThemeService.getInstance();
  private preferencesStore: preferences.Preferences | null = null;

  private themeChangeListener = (theme: ThemeConfig) => {
    this.currentTheme = theme;
  };

  async aboutToAppear() {
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    this.currentTheme = await this.themeService.getCurrentTheme();
    
    // 初始化偏好设置
    try {
      this.preferencesStore = await preferences.getPreferences(getContext(), 'environment_settings');
      // 读取当前环境设置
      this.currentEnvironment = await this.preferencesStore.get('current_environment', DEFAULT_ENVIRONMENT) as string;
    } catch (error) {
      console.error('Failed to initialize preferences:', error);
    }
  }

  aboutToDisappear() {
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  async switchEnvironment(envName: string) {
    try {
      if (this.preferencesStore) {
        await this.preferencesStore.put('current_environment', envName);
        await this.preferencesStore.flush();
        this.currentEnvironment = envName;
        
        promptAction.showToast({
          message: `已切换到${ENVIRONMENTS[envName].description}`,
          duration: 2000
        });
        
        // 提示用户重启应用以生效
        setTimeout(() => {
          promptAction.showDialog({
            title: '环境切换成功',
            message: '请重启应用以使新环境配置生效',
            buttons: [
              {
                text: '确定',
                color: this.currentTheme.primaryColor
              }
            ]
          });
        }, 500);
      }
    } catch (error) {
      console.error('Failed to switch environment:', error);
      promptAction.showToast({
        message: '环境切换失败',
        duration: 2000
      });
    }
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

        Text('环境设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.textColor)
          .margin({ left: 16 })

        Blank()

        Text('🌐')
          .fontSize(24)
          .fontColor(this.currentTheme.textColor)
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(this.currentTheme.cardBackgroundColor)

      // 主要内容区域
      Column() {
        Text('选择服务器环境')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.textColor)
          .margin({ bottom: 16 })
          .alignSelf(ItemAlign.Start)

        // 环境选择列表
        ForEach(this.environments, (env: EnvironmentConfig) => {
          Row() {
            Column() {
              Text(env.description)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.currentTheme.textColor)
                .alignSelf(ItemAlign.Start)

              Text(env.baseUrl)
                .fontSize(14)
                .fontColor(this.currentTheme.textColor)
                .opacity(0.7)
                .margin({ top: 4 })
                .alignSelf(ItemAlign.Start)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Radio({ value: env.name, group: 'environment' })
              .checked(this.currentEnvironment === env.name)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.switchEnvironment(env.name);
                }
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.currentTheme.cardBackgroundColor)
          .borderRadius(12)
          .margin({ bottom: 12 })
          .border({
            width: this.currentEnvironment === env.name ? 2 : 1,
            color: this.currentEnvironment === env.name ? this.currentTheme.primaryColor : this.currentTheme.borderColor
          })
          .onClick(() => {
            this.switchEnvironment(env.name);
          })
        })

        // 说明文字
        Text('💡 提示：切换环境后需要重启应用才能生效')
          .fontSize(14)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.7)
          .margin({ top: 24 })
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(this.currentTheme.backgroundColor)
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}