import promptAction from '@ohos.promptAction';
import { ApiService } from '../../services/ApiService';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../../services/ThemeService';
import { ThemeAwareGradientBackground, ThemeAwareGlassCard } from '../../utils/GlassmorphismStyles';
import { CommonButton, ButtonPresets, ButtonType, ButtonSize } from '../common/CommonButton';
import { safeExecute } from '../../utils/ErrorHandler';
import { ErrorInfo } from '../../types/CommonTypes';
import { STRINGS, UI_SIZES, FONT_SIZES } from '../../constants/AppConstants';

export interface LoginState {
  isLoggedIn: boolean;
  username: string;
  userId: number | null;
  token: string | null;
}

export interface LoginCallbacks {
  onLoginSuccess: (loginState: LoginState) => void;
  onLoginError: (error: string) => void;
  onRegisterSuccess: () => void;
  onRegisterError: (error: string) => void;
}

@Component
export struct LoginComponent {
  @Prop callbacks: LoginCallbacks;
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  
  private apiService: ApiService = ApiService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();
  
  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
      console.info('登录组件主题已更新:', this.currentTheme.name);
    } catch (error) {
      console.error('登录组件主题更新失败:', error);
    }
  };

  async aboutToAppear() {
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    
    await safeExecute(
      async () => {
        await this.themeService.loadThemePreference();
        this.currentTheme = await this.themeService.getCurrentTheme();
        console.info('登录组件加载主题成功:', this.currentTheme.name);
      },
      (error: ErrorInfo) => {
        console.error('登录组件加载主题失败:', error.message);
      }
    );

    await this.checkAutoLogin();
  }

  aboutToDisappear() {
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  private async checkAutoLogin(): Promise<void> {
    await safeExecute(
      async () => {
        const savedUsername = await this.apiService.getUsername();
        const savedToken = await this.apiService.getToken();

        if (savedUsername && savedToken) {
          this.username = savedUsername;
          const loginState: LoginState = {
            isLoggedIn: true,
            username: savedUsername,
            userId: null,
            token: savedToken
          };
          
          console.info('自动登录成功，用户:', savedUsername);
          this.callbacks.onLoginSuccess(loginState);
        } else {
          await this.apiService.clearAuth();
          console.info('未找到有效登录状态');
        }
      },
      (error: ErrorInfo) => {
        console.error('自动登录检查失败:', error.message);
      }
    );
  }

  private async handleLogin(): Promise<void> {
    if (!this.validateInput()) {
      return;
    }

    this.isLoading = true;
    
    await safeExecute(
      async () => {
        console.info('开始登录，用户名:', this.username);
        const response = await this.apiService.login(this.username, this.password);
        console.info('登录响应:', JSON.stringify(response));
        
        await this.apiService.setToken(response.token);
        await this.apiService.setUsername(this.username);
        
        const loginState: LoginState = {
          isLoggedIn: true,
          username: this.username,
          userId: 1,
          token: response.token
        };
        
        promptAction.showToast({ message: '登录成功' });
        this.callbacks.onLoginSuccess(loginState);
      },
      (error: ErrorInfo) => {
        console.error('登录失败详细信息:', error.message);
        const errorMessage = `登录失败：${error.message}`;
        promptAction.showToast({ message: errorMessage });
        this.callbacks.onLoginError(errorMessage);
      }
    );
    
    this.isLoading = false;
  }

  private async handleRegister(): Promise<void> {
    if (!this.validateInput()) {
      return;
    }

    this.isLoading = true;
    
    await safeExecute(
      async () => {
        await this.apiService.register(this.username, this.password);
        promptAction.showToast({ message: '注册成功，请登录' });
        this.callbacks.onRegisterSuccess();
      },
      (error: ErrorInfo) => {
        console.error('注册失败:', error.message);
        const errorMessage = `注册失败：${error.message}`;
        promptAction.showToast({ message: errorMessage });
        this.callbacks.onRegisterError(errorMessage);
      }
    );
    
    this.isLoading = false;
  }

  private validateInput(): boolean {
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名' });
      return false;
    }
    
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' });
      return false;
    }
    
    if (this.username.length < 3) {
      promptAction.showToast({ message: '用户名至少需要3个字符' });
      return false;
    }
    
    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码至少需要6个字符' });
      return false;
    }
    
    return true;
  }

  build() {
    Column() {
      Text('✨ Daily Focus')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })

      Column({ space: 20 }) {
        Text('欢迎回来')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)

        TextInput({ placeholder: '用户名', text: this.username })
          .onChange((value: string) => {
            this.username = value;
          })

        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })

        Button(this.isLoading ? '登录中...' : '登录')
          .enabled(!this.isLoading)
          .onClick(() => this.handleLogin())

        Button('注册')
          .enabled(!this.isLoading)
          .onClick(() => this.handleRegister())
      }
      .padding(20)
      .backgroundColor('#f5f5f5')
      .borderRadius(10)
      .width('90%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
}

export class LoginUtils {
  static createDefaultCallbacks(
    onSuccess?: (state: LoginState) => void,
    onError?: (error: string) => void
  ): LoginCallbacks {
    return {
      onLoginSuccess: onSuccess || ((state: LoginState) => {
        console.info('登录成功:', state.username);
      }),
      onLoginError: onError || ((error: string) => {
        console.error('登录失败:', error);
      }),
      onRegisterSuccess: () => {
        console.info('注册成功');
      },
      onRegisterError: (error: string) => {
        console.error('注册失败:', error);
      }
    };
  }

  static isValidLoginState(state: LoginState): boolean {
    return state.isLoggedIn && 
           !!state.username && 
           !!state.token;
  }

  static createEmptyLoginState(): LoginState {
    return {
      isLoggedIn: false,
      username: '',
      userId: null,
      token: null
    };
  }
} 