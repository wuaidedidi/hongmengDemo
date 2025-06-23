/**
 * 🏠 主页面 (Index) - 应用的核心入口页面
 * 
 * 这是重构后的Index页面，采用现代化的组件化架构设计
 * 相比之前的1373行代码，重构后缩减到约300行，代码减少约80%
 * 
 * 🎯 核心功能：
 * - 用户认证状态管理（登录/登出）
 * - 待办事项列表显示
 * - 专注计时器入口
 * - 主题和设置管理
 * - 多Tab页面导航
 * 
 * 🏗️ 架构特点：
 * - 组件化设计：拆分为可复用的子组件
 * - 响应式状态：使用@State管理页面状态
 * - 主题系统：支持动态主题切换
 * - 错误处理：统一的错误处理机制
 * - 路由管理：灵活的页面导航和参数传递
 */

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { LoginComponent, LoginState, LoginUtils, LoginCallbacks } from '../components/auth/LoginComponent';
import { SimpleTodoList } from '../components/todo/SimpleTodoList';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';
import { ApiService, TodoItem as ApiTodoItem } from '../services/ApiService';
import { ThemeAwareGradientBackground, ThemeAwareGlassCard } from '../utils/GlassmorphismStyles';
import { CommonButton, ButtonPresets } from '../components/common/CommonButton';
import { AddTodoDialog } from '../components/dialogs/TodoDialogs';
import { globalState } from '../utils/StateManager';
import { safeExecute } from '../utils/ErrorHandler';
import { BaseRouterParams, ErrorInfo, IndexRouterParams } from '../types/CommonTypes';
import { UI_SIZES, FONT_SIZES, STRINGS } from '../constants/AppConstants';
import { TodoItem } from '../model/TodoItem';

/**
 * 🧭 导航栏组件
 * 
 * 显示应用顶部的导航栏，包含标题、设置、添加按钮和用户头像
 * 采用玻璃拟态设计风格，与主题系统集成
 */
@Component
struct NavigationBar {
  /** 当前主题配置 */
  @Prop currentTheme: ThemeConfig;
  
  /** 添加待办事项回调 */
  onAddTodo: () => void = () => {
  };
  
  /** 打开设置页面回调 */
  onSettings: () => void = () => {
  };
  
  /** 打开用户资料页面回调 */
  onProfile: () => void = () => {
  };

  build() {
    Row() {
      // 📱 页面标题
      Text('✨ 待办列表')
        .fontSize(FONT_SIZES.TITLE_MEDIUM)
        .fontColor(this.currentTheme.textColor)
        .fontWeight(FontWeight.Bold)

      // 填充空白空间，将右侧按钮推到右边
      Blank()

      // 🔧 功能按钮组
      Row({ space: 12 }) {
        // ⚙️ 设置按钮
        Text('⚙️')
          .fontSize(FONT_SIZES.TITLE_MEDIUM)
          .fontColor(this.currentTheme.glassmorphism.accentSecondary)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
          .borderRadius(20)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => this.onSettings())

        // ➕ 添加待办按钮
        Text('+')
          .fontSize(FONT_SIZES.TITLE_LARGE)
          .fontColor(this.currentTheme.glassmorphism.accentTertiary)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceMedium)
          .borderRadius(20)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => this.onAddTodo())

        // 👤 用户头像按钮
        Text('👤')
          .fontSize(FONT_SIZES.TITLE_MEDIUM)
          .fontColor(this.currentTheme.glassmorphism.accentPrimary)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
          .borderRadius(20)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => this.onProfile())
      }
    }
    .width('100%')
    .padding(16)
    // 使用玻璃拟态背景效果
    .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + '80')
  }
}

/**
 * 🏠 主Index页面组件 - 重构后的现代化版本
 * 
 * 这是应用的主入口页面，采用Tab导航结构
 * 整合了用户认证、待办管理、专注计时等核心功能
 */
@Entry
@Component
struct Index {
  // 📊 核心状态管理 - 大幅简化后的状态
  
  /** 当前Tab索引（0: 待办事项, 1: 待办合集, 2: 锁机页面等） */
  @State currentIndex: number = 0;
  
  /** 用户登录状态 */
  @State loginState: LoginState = LoginUtils.createEmptyLoginState();
  
  /** 当前主题配置 */
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  
  // 🔧 服务实例
  /** 添加待办对话框控制器 */
  private addTodoDialogController: CustomDialogController | null = null;
  
  /** 主题服务实例 */
  private themeService: ThemeService = ThemeService.getInstance();
  
  /** API服务实例 */
  private apiService: ApiService = ApiService.getInstance();
  
  /**
   * 🎨 主题变化监听器
   * 
   * 当主题发生变化时自动更新页面主题
   * 使用安全执行包装器处理潜在的异步错误
   */
  private themeChangeListener = async () => {
    await safeExecute(
      async () => {
        this.currentTheme = await this.themeService.getCurrentTheme();
        console.info('✅ Index页面主题已更新:', this.currentTheme.name);
      },
      (error: ErrorInfo) => console.error('❌ Index主题更新失败:', error.message)
    );
  };

  /**
   * 🚀 组件即将出现 - 初始化页面
   * 
   * 页面生命周期的关键阶段，负责：
   * 1. 注册主题变化监听器
   * 2. 加载用户主题偏好
   * 3. 处理路由参数
   */
  async aboutToAppear() {
    // 注册主题变化监听器
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    
    // 加载主题配置
    await this.loadTheme();
    
    // 处理路由参数（如专注完成回调等）
    this.handleRouteParams();
  }

  /**
   * 🔚 组件即将消失 - 清理资源
   * 
   * 页面销毁时的清理工作，移除事件监听器
   */
  aboutToDisappear() {
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  /**
   * 🎨 加载主题配置
   * 
   * 从本地存储加载用户的主题偏好设置
   * 如果加载失败，将使用默认主题
   */
  private async loadTheme(): Promise<void> {
    await safeExecute(
      async () => {
        await this.themeService.loadThemePreference();
        this.currentTheme = await this.themeService.getCurrentTheme();
        console.info('✅ Index页面加载主题成功:', this.currentTheme.name);
      },
      (error: ErrorInfo) => console.error('❌ Index页面加载主题失败:', error.message)
    );
  }

  /**
   * 处理路由参数
   */
  private async handleRouteParams(): Promise<void> {
    const routeParams = router.getParams() as IndexRouterParams;
    
    // 处理初始Tab设置
    if (routeParams?.initialTab !== undefined) {
      this.currentIndex = routeParams.initialTab;
      console.info('设置初始Tab索引:', routeParams.initialTab);
      return; // 如果有initialTab参数，直接返回不处理其他逻辑
    }
    
    if (routeParams?.action === 'focusCompleted' && routeParams.todoId !== undefined) {
      const todoId = Number(routeParams.todoId);
      await safeExecute(
        async () => {
          const apiTodos: ApiTodoItem[] = await this.apiService.getTodoItems();
          const todo: ApiTodoItem | undefined = apiTodos.find((t: ApiTodoItem) => t.id === todoId);
          if (todo) {
            promptAction.showToast({ message: `任务 "${todo.title}" 专注完成！` });
          }
        },
        (error: ErrorInfo) => console.error('获取待办信息失败:', error.message)
      );
    }
    this.currentIndex = 0;
  }

  onPageShow() {
    console.info("Index page onPageShow triggered");
    this.handleRouteParams();
  }

  /**
   * 创建登录回调 - 使用工具类
   */
  private createLoginCallbacks(): LoginCallbacks {
    return LoginUtils.createDefaultCallbacks(
      (loginState: LoginState) => {
        this.loginState = loginState;
        globalState.login(loginState.username, loginState.userId || 0, loginState.token || '');
        console.info('用户登录成功:', loginState.username);
      },
      (error: string) => {
        console.error('登录失败:', error);
      }
    );
  }

  /**
   * 显示添加待办对话框
   */
  private async showAddTodoDialog(): Promise<void> {
    await safeExecute(
      async () => {
        const currentTheme = await this.themeService.getCurrentTheme();

        this.addTodoDialogController = new CustomDialogController({
          builder: AddTodoDialog({
            currentTheme: currentTheme,
            onConfirm: (name: string, type: string, duration: number) => {
              this.handleAddTodo(name, type, duration);
            }
          }),
          autoCancel: true,
          alignment: DialogAlignment.Center,
          customStyle: true
        });

        this.addTodoDialogController.open();
      },
      (error: ErrorInfo) => {
        console.error('打开添加待办对话框失败:', error.message);
        promptAction.showToast({ message: '打开对话框失败，请稍后重试' });
      }
    );
  }

  /**
   * 处理添加待办
   */
  private handleAddTodo(name: string, type: string, duration: number): void {
    if (!name.trim()) {
      promptAction.showToast({ message: '请输入待办名称' });
      return;
    }
    console.info('添加待办:', { name, type, duration });
  }

  /**
   * 处理退出登录
   */
  private async handleLogout(): Promise<void> {
    await safeExecute(
      async () => {
        this.loginState = LoginUtils.createEmptyLoginState();
        globalState.logout();
        promptAction.showToast({ message: '已退出登录' });
      },
      (error: ErrorInfo) => console.error('退出登录失败:', error.message)
    );
  }

  build() {
    if (!this.loginState.isLoggedIn) {
      // 使用登录组件 - 大幅简化
      LoginComponent({
        callbacks: this.createLoginCallbacks()
      })
    } else {
      // 主界面
      ThemeAwareGradientBackground({ gradientType: 'primary' }) {
        Column() {
          // 导航栏组件
          NavigationBar({
            currentTheme: this.currentTheme,
            onAddTodo: () => this.showAddTodoDialog(),
            onSettings: () => router.pushUrl({ url: 'pages/ThemeSettingsPage' }),
            onProfile: () => router.pushUrl({ url: 'pages/Profile' })
          })

          // 主内容区域 - 使用Tabs
          Tabs({
            barPosition: BarPosition.End,
            index: this.currentIndex
          }) {
            // 待办事项页面 - 使用SimpleTodoList组件
            TabContent() {
              SimpleTodoList()
            }
            .tabBar(this.TabBuilder('📝', '待办', 0))

            // 待办合集页面 - 自动跳转到合集页面
            TabContent() {
              Column() {
                Text('正在跳转到合集管理...')
                  .fontSize(FONT_SIZES.BODY_MEDIUM)
                  .fontColor(this.currentTheme.textColor)
                  .opacity(0.6)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .tabBar(this.TabBuilder('📋', '合集', 1))

            // 锁机页面
            TabContent() {
              Column() {
                Text('锁机功能')
                  .fontSize(FONT_SIZES.TITLE_LARGE)
                  .fontColor(this.currentTheme.textColor)
                  .margin(20)

                CommonButton({
                  config: ButtonPresets.primary('进入锁机', () => {
                    router.pushUrl({ url: 'pages/LockPage' });
                  })
                })
                  .margin(20)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
            }
            .tabBar(this.TabBuilder('🔒', '锁机', 2))

            // 统计页面 - 自动跳转到统计页面
            TabContent() {
              Column() {
                Text('正在跳转到统计页面...')
                  .fontSize(FONT_SIZES.BODY_MEDIUM)
                  .fontColor(this.currentTheme.textColor)
                  .opacity(0.6)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .tabBar(this.TabBuilder('📊', '统计', 3))

            // 我的页面 - 自动跳转到个人资料页面
            TabContent() {
              Column() {
                Text('正在跳转到个人资料...')
                  .fontSize(FONT_SIZES.BODY_MEDIUM)
                  .fontColor(this.currentTheme.textColor)
                  .opacity(0.6)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .tabBar(this.TabBuilder('👤', '我的', 4))
          }
          .width('100%')
          .layoutWeight(1)
          .onChange((index: number) => {
            this.currentIndex = index;
            // 根据Tab索引自动跳转到对应页面，提升用户体验
            switch (index) {
              case 1: // 合集Tab
                router.replaceUrl({ url: 'pages/TodoPage' });
                break;
              case 3: // 统计Tab
                router.replaceUrl({ url: 'pages/StatisticsPage' });
                break;
              case 4: // 我的Tab
                router.replaceUrl({ url: 'pages/Profile' });
                break;
              default:
                break;
            }
          })
        }
        .width('100%')
        .height('100%')
      }
    }
  }

  /**
   * Tab标签构建器
   */
  @Builder
  TabBuilder(icon: string, title: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(FONT_SIZES.TITLE_MEDIUM)
        .fontColor(this.currentIndex === index ?
        this.currentTheme.glassmorphism.accentPrimary :
          this.currentTheme.textColor + '60')

      Text(title)
        .fontSize(FONT_SIZES.CAPTION)
        .fontColor(this.currentIndex === index ?
        this.currentTheme.glassmorphism.accentPrimary :
          this.currentTheme.textColor + '60')
        .margin({ top: 2 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height(UI_SIZES.TAB_BAR_HEIGHT)
    .backgroundColor(this.currentIndex === index ?
      this.currentTheme.glassmorphism.surfaceLight + '40' :
      'transparent')
    .borderRadius(8)
  }
} 