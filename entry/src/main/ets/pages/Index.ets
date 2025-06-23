import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import wantConstant from '@ohos.ability.wantConstant';
import Want from '@ohos.app.ability.Want';
import { TabBar } from '../components/TabBar';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { PhxSystemActionUtil } from '../utils/PhxSystemActionUtil';
import { ApiService, TodoItemRequest } from '../services/ApiService';
import type { TodoItem as ApiTodoItem } from '../services/ApiService';
import { TodoItem } from '../model/TodoItem';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';
import { ThemeAwareGlassCard, ThemeAwareGradientBackground, GlassmorphismStyles } from '../utils/GlassmorphismStyles';

// TodoList 被移除，因为它与 TodoCollection 关联较多，后续按需调整
// import { TodoList } from '../view/TodoList';

// 不直接导入Context类型，我们将在需要时使用common模块
// Index.ets

// 定义通用错误接口，替代any/unknown类型
interface CommonError {
  message: string;
  code?: string | number;
  name?: string;
  stack?: string;
  cause?: string;
  detail?: string;
  // 移除索引签名，ArkTS不支持
}

// 系统设置跳转参数接口
interface SettingsWantOptions {
  action?: string;
  bundleName?: string;
  abilityName?: string;
  uri?: string;
  parameters?: Record<string, string | number | boolean | Array<string | number | boolean>>;
}

// Want类型定义
interface SystemWant {
  action?: string;
  bundleName?: string;
  abilityName?: string;
  uri?: string;
  parameters?: Record<string, string | number | boolean | Array<string | number | boolean>>;
}

// 上下文接口定义
interface ContextLike {
  applicationInfo?: Record<string, string>;
  startAbility: Function;
}

// FocusTimer页面路由参数定义
interface FocusTimerRouterParams {
  taskTitle?: string;
  title?: string;
  time?: number; // 注意：FocusTimer 期望的是秒
  duration?: number; // 这个可能是分钟，需要统一
  isSequence?: boolean; // Index 页面不再处理序列
  collectionId?: string; // Index 页面不再处理合集
  subTaskId?: string; // Index 页面不再处理子任务
  currentSubTaskIndex?: number; // Index 页面不再处理子任务索引
  totalSubTasksInCollection?: number; // Index 页面不再处理合集任务总数
  todoId?: string | number; // 支持待办事项ID
}

// 添加自启动设置Want参数接口
interface StartupSettingsParams {
  packageName: string;
}

// TodoOperation页面路由参数定义 (可能仍需调整，取决于简单待办的操作)
interface TodoOperationParams {
  todoId: string | number;
  todoTitle?: string;
}

// // 子任务编辑页面路由参数 (从Index移除)
// interface SubTaskEditPageParams {
//   collectionId: string;
//   subTaskId: string;
// }

// // 子任务查找结果接口 (从Index移除)
// interface SubTaskResult {
//   collection: TodoCollection | undefined;
//   subtask: ActualTodoItem | undefined;
// }

// 定义AboutToAppear方法中使用的参数接口
interface AboutToAppearParams {
  action?: string;
  todoId?: string | number; // 保留用于简单待办返回
  // sequenceAction?: string; // 移除序列相关
  // collectionId?: string | number; // 移除合集相关
  // completedSubTaskIndex?: string | number; // 移除子任务相关
  // currentSubTaskIndexCompleted?: number; // 移除子任务相关
  // allSubTasksInCollectionCompleted?: boolean; // 移除合集完成相关
}

// 定义偏移量类
class DialogOffset {
  dx: number;
  dy: number;

  constructor(dx: number, dy: number) {
    this.dx = dx;
    this.dy = dy;
  }
}

// 权限列表类型
class PermissionItem {
  name: string;
  granted: boolean;

  constructor(name: string, granted: boolean) {
    this.name = name;
    this.granted = granted;
  }
}

// 路由参数接口
interface RouterParams {
  action?: string;
  todoId?: string | number; // 简单待办ID
  // 移除序列和合集相关参数
  // sequenceAction?: string;
  // collectionId?: string | number;
  // completedSubTaskIndex?: string | number;
  // currentSubTaskIndexCompleted?: string;
  // allSubTasksInCollectionCompleted?: string;
}

// 在文件顶部的接口定义部分添加一个通用错误类型
// 通用错误类型，用于处理各种错误情况
interface ErrorInfo {
  message: string;
  code?: number;
  details?: string;
}

// 创建错误信息的辅助方法
function createErrorInfo(err: Error): ErrorInfo {
  return { message: err.message };
}

// 从字符串创建错误信息
function createErrorInfoFromString(errStr: string): ErrorInfo {
  return { message: errStr };
}

// 从对象创建错误信息
function createErrorInfoFromObject(errObj: CommonError): ErrorInfo {
  const message = errObj.message ? String(errObj.message) : "未知错误";
  const code = typeof errObj.code === 'number' ? errObj.code : undefined;
  const details = String(errObj);
  return { message, code, details };
}

// AddSimpleTodoDialog 保持，用于添加简单待办
@CustomDialog
struct AddSimpleTodoDialog {
  @State todoName: string = '';
  @State todoType: string = '';
  @State todoDuration: number = 25;
  @Prop currentTheme: ThemeConfig; // 添加主题属性
  onConfirm: (name: string, type: string, duration: number) => void = () => {
  };
  controller?: CustomDialogController;

  build() {
    Column() {
      // 标题区域
      Column() {
        Text('✨')
          .fontSize(32)
          .margin({ bottom: 8 })
        Text('添加新待办')
          .fontSize(20)
          .fontColor(this.currentTheme.textColor)
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 24 })

      // 输入区域
      Column({ space: 16 }) {
        TextInput({ placeholder: "待办名称", text: this.todoName })
          .onChange(val => {
            this.todoName = val;
          })
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'D0')
          .borderRadius(16)
          .border({ 
            width: 0.5, 
            color: this.currentTheme.glassmorphism.accentSecondary + '50' 
          })
          .fontColor(this.currentTheme.textColor)
          .placeholderColor(this.currentTheme.textColor + '80')
          .padding(16)
          .backdropBlur(8)
          .shadow({
            radius: 6,
            color: this.currentTheme.glassmorphism.accentPrimary + '20',
            offsetX: 0,
            offsetY: 2
          })

        TextInput({ placeholder: "类型 (如: 学习, 工作)", text: this.todoType })
          .onChange(val => {
            this.todoType = val;
          })
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'D0')
          .borderRadius(16)
          .border({ 
            width: 0.5, 
            color: this.currentTheme.glassmorphism.accentSecondary + '50' 
          })
          .fontColor(this.currentTheme.textColor)
          .placeholderColor(this.currentTheme.textColor + '80')
          .padding(16)
          .backdropBlur(8)
          .shadow({
            radius: 6,
            color: this.currentTheme.glassmorphism.accentPrimary + '20',
            offsetX: 0,
            offsetY: 2
          })

        TextInput({ placeholder: "时长 (分钟)", text: this.todoDuration.toString() })
          .type(InputType.Number)
          .onChange(val => {
            this.todoDuration = Number(val) || 25;
          })
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'D0')
          .borderRadius(16)
          .border({ 
            width: 0.5, 
            color: this.currentTheme.glassmorphism.accentSecondary + '50' 
          })
          .fontColor(this.currentTheme.textColor)
          .placeholderColor(this.currentTheme.textColor + '80')
          .padding(16)
          .backdropBlur(8)
          .shadow({
            radius: 6,
            color: this.currentTheme.glassmorphism.accentPrimary + '20',
            offsetX: 0,
            offsetY: 2
          })
      }
      .margin({ bottom: 24 })

      // 按钮区域
      Row({ space: 12 }) {
        Button("取消")
          .onClick(() => this.controller?.close())
          .layoutWeight(1)
          .height(48)
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'B0')
          .borderRadius(16)
          .border({ 
            width: 0.5, 
            color: this.currentTheme.glassmorphism.accentSecondary + '60' 
          })
          .fontColor(this.currentTheme.glassmorphism.accentSecondary)
          .backdropBlur(8)
          .shadow({
            radius: 8,
            color: this.currentTheme.glassmorphism.accentSecondary + '20',
            offsetX: 0,
            offsetY: 2
          })

        Button("确定")
          .onClick(() => {
            this.onConfirm(this.todoName, this.todoType, this.todoDuration);
            this.controller?.close();
          })
          .layoutWeight(1)
          .height(48)
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
          .fontColor('#FFFFFF')
          .backdropBlur(8)
          .shadow({
            radius: 12,
            color: this.currentTheme.glassmorphism.accentPrimary + '50',
            offsetX: 0,
            offsetY: 3
          })
          .blur(0.2)
      }
      .width('100%')
    }
    .padding(24)
    .width(320)
    .backgroundColor(this.currentTheme.backgroundColor + 'F8') // 降低透明度，提高可读性
    .borderRadius(24)
    .backdropBlur(15) // 适度减少背景模糊
    .border({ 
      width: 0.5, 
      color: this.currentTheme.glassmorphism.accentPrimary + '40' // 稍微增加边框可见度
    })
    .shadow({
      radius: 25,
      color: this.currentTheme.glassmorphism.accentPrimary + '30',
      offsetX: 0,
      offsetY: 10
    })
    .linearGradient({
      angle: 135,
      colors: [
        [this.currentTheme.backgroundColor + 'F5', 0.0],
        [this.currentTheme.glassmorphism.surfaceLight + 'F8', 1.0]
      ]
    })
  }
}

// // New CustomDialog for adding TodoCollection (移至 TodoDetail.ets)
// @CustomDialog
// struct AddCollectionDialog { ... }

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State bgColor: string = 'rgba(255, 192, 203, 0.15)';
  @State isClockInMenuShow: boolean = false;
  @State isClockInStatsShow: boolean = false;
  @State isPermissionDialogShow: boolean = false;
  @State isLoggedIn: boolean = false;
  @State username: string = '';
  @State password: string = '';
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  private apiService: ApiService = ApiService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();
  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
      console.info('Index页面主题已更新:', this.currentTheme.name);
    } catch (error) {
      console.error('Index主题更新失败:', error);
    }
  };
  // 使用后端API的待办事项
  @State simpleTodos: TodoItem[] = [];
  @State isLoadingTodos: boolean = false;
  // @State selectedTodoId: number = -1; // 如果需要跟踪选中的简单待办，可以保留
  @State isOperationMenuShow: boolean = false; // 保留操作菜单状态 (可能用于简单待办的编辑/删除)
  // @State showAddTodoModal: boolean = false; // AddSimpleTodoDialog 有自己的controller

  // 用于 AddSimpleTodoDialog 的状态变量
  @State newSimpleTodoName: string = '';
  @State newSimpleTodoType: string = '';
  @State newSimpleTodoDuration: number = 25;
  permissionList: PermissionItem[] = [
    new PermissionItem('通知权限', false),
    new PermissionItem('日历权限', false),
    new PermissionItem('位置权限', false)
  ];
  // // Dialog controller for adding collections (移除)
  // private addCollectionDialog: CustomDialogController = ... ;

  // Dialog controller for adding simple todos
  private addSimpleTodoDialogController: CustomDialogController | null = null;

  async aboutToAppear() {
    this.checkLoginStatus();
    // 注册主题变化监听器
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    // 加载当前主题
    try {
      // 首先加载保存的主题偏好设置
      await this.themeService.loadThemePreference();
      this.currentTheme = await this.themeService.getCurrentTheme();
      console.info('Index页面加载主题成功:', this.currentTheme.name);
    } catch (error) {
      console.error('Index页面加载主题失败:', error);
    }
  }

  aboutToDisappear() {
    // 注销主题变化监听器
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  async checkLoginStatus() {
    const savedUsername = await this.apiService.getUsername();
    const savedToken = await this.apiService.getToken();

    // 只有在同时存在用户名和有效token时才自动登录
    if (savedUsername && savedToken) {
      this.username = savedUsername;
      this.isLoggedIn = true;
      console.info('自动登录成功，用户:', this.username);
      // 登录成功后加载待办事项
      await this.loadTodos();
    } else {
      // 如果没有有效的登录状态，清除可能残留的数据
      await this.apiService.clearAuth();
      this.isLoggedIn = false;
      console.info('未找到有效登录状态');
    }
  }

  async handleLogin() {
    console.info('点击登录，用户名:', this.username, '密码:', this.password);
    try {
      console.info('调用 ApiService.login');
      const response = await this.apiService.login(this.username, this.password);
      console.info('后端返回:', JSON.stringify(response));
      await this.apiService.setToken(response.token);
      await this.apiService.setUsername(this.username);
      this.isLoggedIn = true;
      promptAction.showToast({ message: '登录成功' });
      // 登录成功后加载待办事项
      await this.loadTodos();
    } catch (error) {
      console.error('登录失败详细信息:', JSON.stringify(error));
      console.error('错误消息:', (error as Error).message);
      promptAction.showToast({ message: '登录失败：' + (error as Error).message });
    }
  }

  async handleRegister() {
    try {
      await this.apiService.register(this.username, this.password);
      promptAction.showToast({ message: '注册成功，请登录' });
    } catch (error) {
      console.error('注册失败:', error);
      promptAction.showToast({ message: '注册失败，请稍后重试' });
    }
  }

  async handleLogout() {
    await this.apiService.clearAuth();
    this.isLoggedIn = false;
    this.username = '';
    this.password = '';
    promptAction.showToast({ message: '已退出登录' });
  }

  async handleCheckIn() {
    try {
      await this.apiService.checkIn();
      promptAction.showToast({ message: '打卡成功' });
      this.isClockInMenuShow = false;
    } catch (error) {
      console.error('打卡失败:', error);
    }
  }

  onPageShow() {
    console.info("Index page onPageShow triggered");
    const routeParams = router.getParams() as RouterParams;
    if (routeParams && typeof routeParams === 'object') {
      console.info('Index onPageShow router.getParams(): ' + JSON.stringify(routeParams));

      if (routeParams.action === 'focusCompleted' && routeParams.todoId !== undefined) {
        const completedTodoId = Number(routeParams.todoId);
        // 通过API更新待办状态
        this.toggleTodoStatus(completedTodoId);

        const todo = this.simpleTodos.find(t => t.id === completedTodoId);
        if (todo) {
          promptAction.showToast({ message: `任务 "${todo.title}" 专注完成！` });
        }
      }
      // 移除所有与 sequenceAction, collectionId, completedSubTaskIndex 相关的处理逻辑
    }
    this.currentIndex = 0; // 确保在页面显示时 currentIndex 正确

    // 每次页面显示时刷新数据
    this.loadTodos();
  }

  // 显示添加简单待办对话框
  async showAddSimpleTodoDialog(): Promise<void> {
    try {
      // 重置输入状态
      this.newSimpleTodoName = '';
      this.newSimpleTodoType = '';
      this.newSimpleTodoDuration = 25;
      
      // 预先获取当前主题，确保弹窗显示时主题已加载
      const currentTheme = await this.themeService.getCurrentTheme();
      console.info('准备打开添加简单待办弹窗，当前主题:', currentTheme.name);
      
      // 每次打开时重新创建，确保获取最新主题
      this.addSimpleTodoDialogController = new CustomDialogController({
        builder: AddSimpleTodoDialog({
          todoName: this.newSimpleTodoName,
          todoType: this.newSimpleTodoType,
          todoDuration: this.newSimpleTodoDuration,
          currentTheme: currentTheme, // 传递当前主题
          onConfirm: (name: string, type: string, duration: number) => {
            this.addNewSimpleTodoFromDialog(name, type, duration);
          }
        }),
        autoCancel: true,
        alignment: DialogAlignment.Center,
        customStyle: true, // 使用自定义样式
        maskColor: Color.Transparent // 去掉默认的遮罩颜色
      });
      this.addSimpleTodoDialogController.open();
    } catch (error) {
      console.error('打开添加简单待办弹窗失败:', error);
    }
  }

  async addNewSimpleTodoFromDialog(name: string, type: string, duration: number) {
    if (name.trim() === '') {
      promptAction.showToast({ message: '请输入待办名称' });
      return;
    }
    if (type.trim() === '') {
      promptAction.showToast({ message: '请输入待办类型' });
      return;
    }
    if (duration <= 0) {
      promptAction.showToast({ message: '请输入有效的时长' });
      return;
    }

    try {
      const todoData: TodoItemRequest = {
        title: name.trim(),
        description: type.trim(),
        type: type.trim() || 'general',
        duration: duration,
        isImportant: false,
        isUrgent: false
      };

      const newTodo: ApiTodoItem = await this.apiService.createTodoItem(todoData);

      // 转换为本地TodoItem格式
      const localTodo = new TodoItem(
        newTodo.id,
        newTodo.title,
        newTodo.type || 'general',
        newTodo.duration || 25,
        newTodo.completed
      );

      this.simpleTodos.push(localTodo);

      // 重置输入框状态
      this.newSimpleTodoName = '';
      this.newSimpleTodoType = '';
      this.newSimpleTodoDuration = 25;

      promptAction.showToast({ message: "新待办已添加" });
    } catch (error) {
      console.error('添加待办失败:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      promptAction.showToast({ message: '添加待办失败：' + errorMessage });
    }
  }

  async addNewSimpleTodo() {
    if (this.newSimpleTodoName.trim() === '') {
      promptAction.showToast({ message: '请输入待办名称' });
      return;
    }
    if (this.newSimpleTodoType.trim() === '') {
      promptAction.showToast({ message: '请输入待办类型' });
      return;
    }
    if (this.newSimpleTodoDuration <= 0) {
      promptAction.showToast({ message: '请输入有效的时长' });
      return;
    }

    try {
      const todoData: TodoItemRequest = {
        title: this.newSimpleTodoName.trim(),
        description: this.newSimpleTodoType.trim(),
        type: this.newSimpleTodoType.trim() || 'general',
        duration: this.newSimpleTodoDuration,
        isImportant: false,
        isUrgent: false
      };

      const newTodo: ApiTodoItem = await this.apiService.createTodoItem(todoData);

      // 转换为本地TodoItem格式
      const localTodo = new TodoItem(
        newTodo.id,
        newTodo.title,
        newTodo.type || 'general',
        newTodo.duration || 25,
        newTodo.completed
      );

      this.simpleTodos.push(localTodo);

      // 重置输入框
      this.newSimpleTodoName = '';
      this.newSimpleTodoType = '';
      this.newSimpleTodoDuration = 25;

      promptAction.showToast({ message: "新待办已添加" });
    } catch (error) {
      console.error('添加待办失败:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      promptAction.showToast({ message: '添加待办失败：' + errorMessage });
    }
  }

  // 加载待办事项
  async loadTodos() {
    if (!this.isLoggedIn) {
      return;
    }

    try {
      this.isLoadingTodos = true;
      const todos: ApiTodoItem[] = await this.apiService.getTodoItems();

      // 转换为本地TodoItem格式
      this.simpleTodos = todos.map((todo: ApiTodoItem): TodoItem => new TodoItem(
        todo.id,
        todo.title,
        todo.type || 'general',
        todo.duration || 25,
        todo.completed
      ));
    } catch (error) {
      console.error('加载待办事项失败:', error);
      promptAction.showToast({ message: '加载待办事项失败' });
    } finally {
      this.isLoadingTodos = false;
    }
  }

  // 切换待办完成状态
  async toggleTodoStatus(todoId: number) {
    try {
      const updatedTodo: ApiTodoItem = await this.apiService.toggleTodoItemStatus(todoId);

      // 更新本地状态
      const index = this.simpleTodos.findIndex(t => t.id === todoId);
      if (index !== -1) {
        this.simpleTodos[index].isCompleted = updatedTodo.completed;
        this.simpleTodos = Array.from(this.simpleTodos); // 触发UI更新
      }

      promptAction.showToast({
        message: updatedTodo.completed ? '任务已完成' : '任务已重新激活'
      });
    } catch (error) {
      console.error('更新待办状态失败:', error);
      promptAction.showToast({ message: '更新状态失败' });
    }
  }

  // 删除待办事项
  async deleteTodo(todoId: number) {
    try {
      await this.apiService.deleteTodoItem(todoId);

      // 从本地列表中移除
      this.simpleTodos = this.simpleTodos.filter(t => t.id !== todoId);

      promptAction.showToast({ message: '待办已删除' });
    } catch (error) {
      console.error('删除待办失败:', error);
      promptAction.showToast({ message: '删除失败' });
    }
  }

  // 为待办开始专注的方法
  private startFocusForTodo(todo: TodoItem): void {
    const params: FocusTimerRouterParams = {
      title: todo.title,
      taskTitle: todo.title,
      time: todo.duration * 60,
      todoId: todo.id,
      isSequence: false
    };
    router.pushUrl({ url: 'pages/FocusTimer', params: params })
      .catch((err: Error) => {
        console.error(`跳转FocusTimer出错: ${err.message}`);
      });
  }

  handlePermissionSettings() {
    const context = this.getAppAbilityContext();
    if (!context) {
      promptAction.showToast({ message: "无法获取应用上下文" });
      return;
    }
    // 跳转到应用详情页
    PhxSystemActionUtil.goAppInfoSetting(context);
  }

  // --- System and Permission Methods Placeholder ---
  getAppAbilityContext(): common.UIAbilityContext | undefined {
    const context = getContext(this) as common.UIAbilityContext; // 明确类型
    if (context && typeof context === 'object') {
      try {
        // 尝试将context转为UIAbilityContext类型
        const uiContext = context as common.UIAbilityContext;
        // 检查必要的属性是否存在
        if (uiContext.applicationInfo !== undefined && typeof uiContext.startAbility === 'function') {
          return uiContext;
        }
      } catch (e) {
        const errorMessage = e instanceof Error ? e.message : String(e);
        console.error("Context conversion to UIAbilityContext error: " + errorMessage);
      }
    }
    console.warn("Failed to get a valid UIAbilityContext.");
    return undefined;
  }

  async startSystemSettingsGuidanceFlow() {
    console.info('[MyTestApp] startSystemSettingsGuidanceFlow: Method executing with new logic.');
    const context = this.getAppAbilityContext();
    if (!context) {
      promptAction.showToast({ message: "无法获取应用上下文" });
      return;
    }

    const currentBundleName = context.applicationInfo?.name || context.abilityInfo?.bundleName || '';
    if (!currentBundleName) {
      promptAction.showToast({ message: "无法获取当前应用包名" });
      console.error('[MyTestApp] 无法获取当前应用包名');
      return;
    }
    console.info(`[MyTestApp] 当前应用包名: ${currentBundleName}`);

    // 依次尝试所有常见action
    const tryWants: Want[] = [
      { action: 'ohos.settings.action.application_details_settings', parameters: { bundleName: currentBundleName } },
      { action: 'ohos.settings.action.APP_DETAILS', parameters: { bundleName: currentBundleName } },
      { action: 'ohos.settings.action.APP_PERMISSION_MANAGER', parameters: { bundleName: currentBundleName } },
      { action: 'ohos.settings.action.APP_NOTIFICATION_SETTINGS', parameters: { bundleName: currentBundleName } },
      { action: 'ohos.settings.action.SETTINGS' }
    ];
    let success = false;
    for (let want of tryWants) {
      try {
        console.info(`[MyTestApp] 尝试action: ${JSON.stringify(want)}`);
        await context.startAbility(want as Want);
        console.info('[MyTestApp] 跳转设置相关页面成功');
        success = true;
        break;
      } catch (e) {
        console.error(`[MyTestApp] 跳转失败: ${e}`);
        // 继续尝试下一个
      }
    }
    if (!success) {
      promptAction.showToast({
        message: "无法打开设置页面，请手动前往设置",
        duration: 3000
      });
    }
  }

  createSystemWant(options: SettingsWantOptions): SystemWant {
    // This function should create a Want object based on options
    // Placeholder implementation
    let want: Want = {
      bundleName: options.bundleName,
      abilityName: options.abilityName,
      uri: options.uri,
      parameters: options.parameters,
      action: options.action
    };
    // Make sure Want conforms to SystemWant, or SystemWant is an interface Want implements
    return want as SystemWant;
  }

  // --- End of Placeholder ---

  // 删除简单待办按钮构建器
  @Builder
  deleteSimpleTodoBuilder(todo: TodoItem) {
    Row() {
      Column() {
        Text('🗑️')
          .fontSize(18)
          .margin({ bottom: 2 })
        Text('删除')
          .fontSize(12)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width(80)
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#FF6B6B', 0.0], ['#FF3B30', 1.0]]
      })
      .shadow({
        radius: 8,
        color: 'rgba(255, 59, 48, 0.3)',
        offsetX: 2,
        offsetY: 2
      })
      .onClick(() => {
        AlertDialog.show({
          title: '确认删除',
          message: `确定要删除待办事项"${todo.title}"吗？`,
          primaryButton: {
            value: '取消',
            action: () => {}
          },
          secondaryButton: {
            value: '删除',
            fontColor: '#FF3B30',
            action: () => {
              this.deleteTodo(todo.id);
            }
          }
        });
      })
      .gesture(
        TapGesture()
          .onAction(() => {
            // 添加点击动画效果
            animateTo({
              duration: 150,
              curve: Curve.FastOutSlowIn
            }, () => {
              // 点击反馈动画
            })
          })
      )
      .stateStyles({
        pressed: {
          .backgroundColor('#D32F2F')
          .scale({ x: 0.95, y: 0.95 })
        },
        normal: {
          .backgroundColor('transparent')
          .scale({ x: 1.0, y: 1.0 })
        }
      })
    }
    .width(80)
    .height('100%')
    .backgroundColor('transparent')
  }

  @Builder
  AddSimpleTodoDialog() {
    Column({ space: 20 }) {
      Text('添加新待办')
        .fontSize(20)
        .fontColor(this.currentTheme.glassmorphism.accentPrimary)
        .fontWeight(FontWeight.Bold)
        .textShadow({
          radius: 8,
          color: this.currentTheme.glassmorphism.accentPrimary + '50',
          offsetX: 0,
          offsetY: 0
        })

      // ... existing dialog content ...
    }
    .width('100%')
    .backgroundColor(this.currentTheme.glassmorphism.surfaceStrong)
    .borderRadius(20)
    .border({ width: 1, color: this.currentTheme.glassmorphism.borderMedium })
    .padding(24)
    .shadow({
      radius: 24,
      color: this.currentTheme.glassmorphism.shadowDeep,
      offsetX: 0,
      offsetY: 12
    })
  }

  build() {
    if (!this.isLoggedIn) {
      // 登录界面 - 使用主题感知的渐变背景
      ThemeAwareGradientBackground({ gradientType: 'primary' }) {
        Column() {
          // 标题区域
          Column() {
            Text('✨')
              .fontSize(64)
              .margin({ bottom: 16 })
            
            Text('Daily Focus')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentTheme.textColor)
              .textShadow({
                radius: 12,
                color: this.currentTheme.glassmorphism.accentPrimary + '60',
                offsetX: 0,
                offsetY: 0
              })
              .margin({ bottom: 8 })
            
            Text('专注每一天，成就更好的自己')
              .fontSize(16)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.8)
              .margin({ bottom: 48 })
          }

          // 登录卡片 - 使用主题感知的玻璃卡片
          ThemeAwareGlassCard({ level: 'strong' }) {
            Column({ space: 20 }) {
              // 登录标题
              Text('欢迎回来')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.currentTheme.textColor)
                .textAlign(TextAlign.Center)

              // 用户名输入
              TextInput({ placeholder: '用户名', text: this.username })
                .type(InputType.Normal)
                .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
                .borderRadius(12)
                .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
                .fontColor(this.currentTheme.textColor)
                .placeholderColor(this.currentTheme.textColor + '60')
                .onChange((value: string) => {
                  this.username = value;
                })

              // 密码输入
              TextInput({ placeholder: '密码', text: this.password })
                .type(InputType.Password)
                .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
                .borderRadius(12)
                .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
                .fontColor(this.currentTheme.textColor)
                .placeholderColor(this.currentTheme.textColor + '60')
                .onChange((value: string) => {
                  this.password = value;
                })

              // 登录按钮
              Button('🚀 登录')
                .width('100%')
                .height(50)
                .backgroundColor(this.currentTheme.glassmorphism.accentPrimary + '30')
                .borderRadius(25)
                .border({ width: 1, color: this.currentTheme.glassmorphism.accentPrimary })
                .fontColor(this.currentTheme.glassmorphism.accentPrimary)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .shadow({
                  radius: 20,
                  color: this.currentTheme.glassmorphism.accentPrimary + '40',
                  offsetX: 0,
                  offsetY: 0
                })
                .onClick(() => {
                  this.handleLogin();
                })

              // 注册按钮
              Button('✨ 注册')
                .width('100%')
                .height(50)
                .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
                .borderRadius(25)
                .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
                .fontColor(this.currentTheme.textColor)
                .fontSize(16)
                .shadow({
                  radius: 8,
                  color: this.currentTheme.glassmorphism.shadowSoft,
                  offsetX: 0,
                  offsetY: 4
                })
                .onClick(() => {
                  this.handleRegister();
                })
            }
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .padding(24)
      }
    } else {
      // 主界面内容 - 应用渐变背景
      ThemeAwareGradientBackground({ gradientType: 'primary' }) {
        Column() {
          // 顶部毛玻璃导航栏
          Row() {
            Text('✨ 待办列表')
              .fontSize(20)
              .fontColor(this.currentTheme.textColor)
              .fontWeight(FontWeight.Bold)
              .textShadow({
                radius: 8,
                color: this.currentTheme.glassmorphism.accentPrimary + '50',
                offsetX: 0,
                offsetY: 0
              })
            
            Blank()
            
            Row({ space: 12 }) {
              // 权限设置按钮
              Row() {
                Text('🛡️')
                  .fontSize(16)
                  .margin({ right: 4 })
                Text('权限')
                  .fontSize(12)
                  .fontColor(this.currentTheme.textColor)
              }
              .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
              .borderRadius(16)
              .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .shadow({
                radius: 8,
                color: this.currentTheme.glassmorphism.shadowSoft,
                offsetX: 0,
                offsetY: 4
              })
              .onClick(() => {
                this.handlePermissionSettings();
              })

              // 打卡按钮
              Text('✓')
                .fontSize(20)
                .fontColor(this.currentTheme.glassmorphism.accentSecondary)
                .textShadow({
                  radius: 8,
                  color: this.currentTheme.glassmorphism.accentSecondary,
                  offsetX: 0,
                  offsetY: 0
                })
                .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
                .borderRadius(20)
                .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
                .width(40)
                .height(40)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  promptAction.showToast({ message: "打卡菜单待实现" });
                })

              // 添加按钮
              Text('+')
                .fontSize(24)
                .fontColor(this.currentTheme.glassmorphism.accentTertiary)
                .textShadow({
                  radius: 12,
                  color: this.currentTheme.glassmorphism.accentTertiary,
                  offsetX: 0,
                  offsetY: 0
                })
                .backgroundColor(this.currentTheme.glassmorphism.surfaceMedium)
                .borderRadius(20)
                .border({ width: 1, color: this.currentTheme.glassmorphism.accentTertiary })
                .width(40)
                .height(40)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  this.showAddSimpleTodoDialog();
                })

              // 菜单按钮
              Text('≡')
                .fontSize(20)
                .fontColor(this.currentTheme.glassmorphism.accentPrimary)
                .textShadow({
                  radius: 8,
                  color: this.currentTheme.glassmorphism.accentPrimary,
                  offsetX: 0,
                  offsetY: 0
                })
                .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
                .borderRadius(20)
                .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
                .width(40)
                .height(40)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  router.pushUrl({ url: 'pages/ThemeSettingsPage' });
                })
            }
          }
          .width('100%')
          .height(60)
          .padding({ left: 20, right: 20 })
          .backgroundColor(this.currentTheme.glassmorphism.blurOverlay)
          .border({ width: { bottom: 1 }, color: this.currentTheme.glassmorphism.borderLight })

          // 内容区域
          Scroll() {
            Column({ space: 16 }) {
              if (this.isLoadingTodos) {
                // 加载状态的玻璃卡片
                ThemeAwareGlassCard({ level: 'medium' }) {
                  Column() {
                    LoadingProgress()
                      .width(40)
                      .height(40)
                      .color(this.currentTheme.glassmorphism.accentPrimary)
                      .margin({ bottom: 12 })
                    Text('加载中...')
                      .fontSize(16)
                      .fontColor(this.currentTheme.glassmorphism.accentPrimary)
                      .textShadow({
                        radius: 8,
                        color: this.currentTheme.glassmorphism.accentPrimary + '50',
                        offsetX: 0,
                        offsetY: 0
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .padding(32)
                }
              } else if (this.simpleTodos.length === 0) {
                // 空状态的玻璃卡片
                ThemeAwareGlassCard({ level: 'medium' }) {
                  Column() {
                    Text('🌟')
                      .fontSize(48)
                      .margin({ bottom: 16 })
                    Text('暂无待办事项')
                      .fontSize(18)
                      .fontColor(this.currentTheme.glassmorphism.accentSecondary)
                      .fontWeight(FontWeight.Bold)
                      .textShadow({
                        radius: 8,
                        color: this.currentTheme.glassmorphism.accentSecondary + '50',
                        offsetX: 0,
                        offsetY: 0
                      })
                    Text('点击右上角 + 号添加新的待办')
                      .fontSize(14)
                      .fontColor(this.currentTheme.textColor)
                      .opacity(0.7)
                      .margin({ top: 8 })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .padding(40)
                }
              } else {
                // 待办列表
                ForEach(this.simpleTodos, (todo: TodoItem) => {
                  ThemeAwareGlassCard({ level: 'light' }) {
                    Row() {
                      // 完成状态指示器
                      Circle({ width: 12, height: 12 })
                        .fill(todo.isCompleted ? 
                          this.currentTheme.glassmorphism.accentSecondary : 
                          this.currentTheme.glassmorphism.accentPrimary)
                        .shadow(todo.isCompleted ? undefined : {
                          radius: 8,
                          color: this.currentTheme.glassmorphism.accentPrimary + '60',
                          offsetX: 0,
                          offsetY: 0
                        })
                        .margin({ right: 12 })

                      // 待办内容
                      Column() {
                        // 使用Stack实现渐变文字效果
                        Stack() {
                          Text(todo.title)
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .decoration({
                              type: todo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None
                            })
                            .opacity(todo.isCompleted ? 0.6 : 1.0)
                            .linearGradient(todo.isCompleted ? undefined : {
                              angle: 45,
                              colors: [
                                [this.currentTheme.glassmorphism.accentPrimary, 0.0],
                                [this.currentTheme.glassmorphism.accentSecondary, 1.0]
                              ]
                            })
                            .blur(todo.isCompleted ? 0 : 0.3) // 轻微哑光效果
                            .textShadow({
                              radius: todo.isCompleted ? 2 : 6,
                              color: todo.isCompleted ? 
                                this.currentTheme.glassmorphism.shadowSoft : 
                                this.currentTheme.glassmorphism.accentPrimary + '50',
                              offsetX: 0,
                              offsetY: todo.isCompleted ? 1 : 2
                            })
                        }

                        if (todo.type) {
                          // 升级描述标签的渐变和哑光效果
                          Stack() {
                            Text(todo.type)
                              .fontSize(12)
                              .fontColor('#FFFFFF')
                              .fontWeight(FontWeight.Medium)
                              .textShadow({
                                radius: 4,
                                color: '#00000040',
                                offsetX: 0,
                                offsetY: 1
                              })
                          }
                          .linearGradient({
                            angle: 135,
                            colors: [
                              [this.currentTheme.glassmorphism.accentSecondary, 0.0],
                              [this.currentTheme.glassmorphism.accentTertiary, 1.0]
                            ]
                          })
                          .borderRadius(12)
                          .border({ 
                            width: 1, 
                            color: this.currentTheme.glassmorphism.accentSecondary + '60' 
                          })
                          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                          .shadow({
                            radius: 8,
                            color: this.currentTheme.glassmorphism.accentSecondary + '40',
                            offsetX: 0,
                            offsetY: 2
                          })
                          .blur(0.4) // 哑光效果
                          .margin({ top: 6 })
                        }

                        // 添加时长显示（如果存在）
                        if (todo.duration && todo.duration > 0) {
                          Stack() {
                            Text(`${todo.duration}分钟`)
                              .fontSize(11)
                              .fontColor('#FFFFFF')
                              .fontWeight(FontWeight.Medium)
                              .textShadow({
                                radius: 3,
                                color: '#00000030',
                                offsetX: 0,
                                offsetY: 1
                              })
                          }
                          .linearGradient({
                            angle: 45,
                            colors: [
                              [this.currentTheme.glassmorphism.accentTertiary, 0.0],
                              [this.currentTheme.glassmorphism.accentPrimary, 1.0]
                            ]
                          })
                          .borderRadius(10)
                          .border({ 
                            width: 1, 
                            color: this.currentTheme.glassmorphism.accentTertiary + '50' 
                          })
                          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                          .shadow({
                            radius: 6,
                            color: this.currentTheme.glassmorphism.accentTertiary + '30',
                            offsetX: 0,
                            offsetY: 1
                          })
                          .blur(0.3) // 轻微哑光效果
                          .margin({ top: 4 })
                        }
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)

                      // 专注按钮 - 升级为二色渐变哑光效果
                      Stack() {
                        Text('专注')
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                          .fontWeight(FontWeight.Medium)
                          .textAlign(TextAlign.Center)
                          .width('100%')
                          .height('100%')
                          .textShadow({
                            radius: 4,
                            color: '#00000050',
                            offsetX: 0,
                            offsetY: 1
                          })
                      }
                      .width(80)
                      .height(36)
                      .padding({ left: 16, right: 16 })
                      .linearGradient({
                        angle: 135,
                        colors: [
                          [this.currentTheme.glassmorphism.accentPrimary, 0.0],
                          [this.currentTheme.glassmorphism.accentSecondary, 1.0]
                        ]
                      })
                      .borderRadius(16)
                      .border({ 
                        width: 1, 
                        color: this.currentTheme.glassmorphism.accentPrimary + '60' 
                      })
                      .shadow({
                        radius: 12,
                        color: this.currentTheme.glassmorphism.accentPrimary + '40',
                        offsetX: 0,
                        offsetY: 3
                      })
                      .blur(0.6) // 增强哑光效果
                      .animation({
                        duration: 200,
                        curve: Curve.EaseInOut
                      })
                      .onClick(() => {
                        this.startFocusForTodo(todo);
                      })
                    }
                    .width('100%')
                    .padding(16)
                    .onClick(() => {
                      this.toggleTodoStatus(todo.id);
                    })
                  }
                }, (todo: TodoItem) => todo.id.toString())
              }
            }
            .width('100%')
            .padding(20)
          }
          .layoutWeight(1)

          // 底部毛玻璃导航栏
          Column() {
            TabBar({ currentIndex: 0 })
          }
          .backgroundColor(this.currentTheme.glassmorphism.blurOverlay)
          .border({ width: { top: 1 }, color: this.currentTheme.glassmorphism.borderLight })
        }
        .width('100%')
        .height('100%')
      }
    }
  }
}

// // Minimal TodoItem class is already defined above
// // class TodoItem { ... }

// // Note: System and Permission methods (getAppAbilityContext, etc.) are part of the Index struct.
// // Interfaces are defined at the top of the file.