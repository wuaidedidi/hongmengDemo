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
import { ThemeService, ThemeConfig } from '../services/ThemeService';

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

// TodoItem类定义 (这个是 Index.ets 使用的简单待办项)
class TodoItem {
  id: number; // 简单待办使用数字ID
  title: string;
  type: string; // 例如：'学习', '工作', '锻炼'
  duration: number = 25; // 默认25分钟
  isCompleted: boolean = false; // 添加完成状态

  constructor(id: number, title: string, type: string, duration: number = 25, isCompleted: boolean = false) {
    this.id = id;
    this.title = title;
    this.type = type;
    this.duration = duration;
    this.isCompleted = isCompleted;
  }

  formatDuration(): string {
    return `${this.duration}分钟`;
  }
}

// // 新的：单个具体待办事项 (移至 TodoDetail.ets)
// class ActualTodoItem { ... }

// // 修改的：待办事项合集 (移至 TodoDetail.ets)
// class TodoCollection { ... }

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
  @Link todoName: string;
  @Link todoType: string;
  @Link todoDuration: number;
  onConfirm: () => void = () => {
  };
  controller?: CustomDialogController;

  build() {
    Column() {
      Text("添加新待办").fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
      TextInput({ placeholder: "待办名称", text: this.todoName })
        .onChange(val => {
          this.todoName = val;
        })
        .margin({ bottom: 10 })
      TextInput({ placeholder: "类型 (如: 学习, 工作)", text: this.todoType })
        .onChange(val => {
          this.todoType = val;
        })
        .margin({ bottom: 10 })
      TextInput({ placeholder: "时长 (分钟)", text: this.todoDuration.toString() })
        .type(InputType.Number)
        .onChange(val => {
          this.todoDuration = Number(val) || 25;
        })
        .margin({ bottom: 20 })
      Row({ space: 10 }) {
        Button("取消").onClick(() => this.controller?.close()).layoutWeight(1)
        Button("确定").onClick(() => {
          this.onConfirm();
          this.controller?.close();
        }).layoutWeight(1).backgroundColor('#8A2BE2')
      }.width('100%')
    }
    .padding(20).width("80%").backgroundColor(Color.White).borderRadius(15)
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
  @State currentTheme: ThemeConfig = {
    id: 'light',
    name: '浅色主题',
    primaryColor: '#007AFF',
    backgroundColor: '#FFFFFF',
    textColor: '#000000',
    cardBackgroundColor: '#F8F8F8',
    borderColor: '#E0E0E0',
    shadowColor: 'rgba(0, 0, 0, 0.1)',
    errorColor: '#FF3B30'
  };
  private apiService: ApiService = ApiService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();
  private themeChangeListener = (theme: ThemeConfig) => {
    this.currentTheme = theme;
    console.info('Index页面主题已更新:', theme.name);
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
  private addSimpleTodoDialogController: CustomDialogController = new CustomDialogController({
    builder: AddSimpleTodoDialog({
      todoName: $newSimpleTodoName,
      todoType: $newSimpleTodoType,
      todoDuration: $newSimpleTodoDuration,
      onConfirm: () => {
        this.addNewSimpleTodo();
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: false // 根据需要设置
  });

  async aboutToAppear() {
    this.checkLoginStatus();
    // 注册主题变化监听器
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    // 加载当前主题
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
      console.info('Index页面加载主题:', this.currentTheme.name);
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
      promptAction.showToast({ message: '添加待办失败：' + (error as Error).message });
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
      this.simpleTodos = todos.map((todo: ApiTodoItem) => new TodoItem(
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

  // // startSequenceTask (移除)

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
        console.error("Context conversion to UIAbilityContext error: " + ((e as Error).message || String(e)));
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

  build() {
    Column() {
      if (!this.isLoggedIn) {
        // 登录表单
        Column() {
          Text('鸿蒙每日打卡')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 50, bottom: 30 })

          TextInput({ placeholder: '用户名', text: this.username })
            .width('80%')
            .height(50)
            .margin({ bottom: 20 })
            .onChange((value: string) => {
              this.username = value;
            })

          TextInput({ placeholder: '密码', text: this.password })
            .width('80%')
            .height(50)
            .margin({ bottom: 30 })
            .type(InputType.Password)
            .onChange((value: string) => {
              this.password = value;
            })

          Button('登录')
            .width('80%')
            .height(50)
            .backgroundColor('#8A2BE2')
            .onClick(() => {
              this.handleLogin();
            })

          Button('注册')
            .width('80%')
            .height(50)
            .margin({ top: 20 })
            .backgroundColor('#F5F5F5')
            .fontColor('#8A2BE2')
            .onClick(() => {
              this.handleRegister();
            })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFFFF')
      } else {
        // 主界面内容
        Stack() {
          Column() {
            // 顶部标题栏
            Row() {
              Text('待办列表')
                .fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
              Blank()
              Row({ space: 16 }) {
                Row() {
                  Text('必开').fontSize(14).fontColor('#FFFFFF')
                  Text('权限').fontSize(14).fontColor('#FFFFFF')
                }
                .backgroundColor('rgba(255, 255, 255, 0.2)')
                .borderRadius(12)
                .padding({
                  left: 8,
                  right: 8,
                  top: 4,
                  bottom: 4
                })
                .margin({ right: 4 })
                .onClick(() => {
                  this.handlePermissionSettings();
                })

                Text('✓').fontSize(24).fontColor('#FFFFFF')
                  .onClick(() => {
                    promptAction.showToast({ message: "打卡菜单待实现" });
                  })
                Text('+').fontSize(24).fontColor('#FFFFFF')
                  .onClick(() => {
                    this.newSimpleTodoName = '';
                    this.newSimpleTodoType = '';
                    this.newSimpleTodoDuration = 25;
                    this.addSimpleTodoDialogController.open();
                  })
                Text('≡').fontSize(24).fontColor('#FFFFFF')
                  .onClick(() => {
                    promptAction.showToast({ message: "更多菜单待实现" });
                  })
              }
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.currentTheme.primaryColor)

            // 内容区域
            Scroll() {
              Column({ space: 10 }) {
                if (this.isLoadingTodos) {
                  Row() {
                    LoadingProgress()
                      .width(30)
                      .height(30)
                      .margin({ right: 10 })
                    Text('加载中...')
                      .fontSize(16)
                      .fontColor(this.currentTheme.textColor)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .padding(20)
                } else if (this.simpleTodos.length === 0) {
                  Column() {
                    Text('暂无待办事项')
                      .fontSize(16)
                      .fontColor(this.currentTheme.textColor)
                      .opacity(0.6)
                    Text('点击右上角 + 号添加新的待办')
                      .fontSize(14)
                      .fontColor(this.currentTheme.textColor)
                      .opacity(0.4)
                      .margin({ top: 8 })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .padding(40)
                } else {
                  List({ space: 10 }) {
                  ForEach(this.simpleTodos, (todo: TodoItem) => {
                      ListItem() {
                    Row() {
                      Column() {
                        Text(todo.title)
                          .fontSize(18)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.currentTheme.textColor)
                          .decoration({
                            type: todo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None
                          })
                          .opacity(todo.isCompleted ? 0.6 : 1.0)
                              .textAlign(TextAlign.Start)
                        Text(`${todo.type} - ${todo.formatDuration()}`)
                          .fontSize(14)
                          .fontColor(this.currentTheme.textColor)
                          .opacity(todo.isCompleted ? 0.4 : 0.7)
                          .decoration({
                            type: todo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None
                          })
                          .margin({ top: 4 })
                              .textAlign(TextAlign.Start)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)

                          // 只保留专注按钮
                        if (!todo.isCompleted) {
                          Button('专注')
                            .fontSize(12)
                            .fontColor(Color.White)
                            .backgroundColor(this.currentTheme.primaryColor)
                            .borderRadius(8)
                            .height(28)
                            .padding({ left: 8, right: 8 })
                            .onClick(() => {
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
                            })
                        }
                    }
                    .width('100%')
                    .backgroundColor(this.currentTheme.cardBackgroundColor)
                    .borderRadius(8)
                    .padding(12)
                    .opacity(todo.isCompleted ? 0.7 : 1.0)
                      }
                      .swipeAction({
                        end: {
                          builder: () => {
                            this.deleteSimpleTodoBuilder(todo)
                          }
                        }
                      })
                  }, (todo: TodoItem) => todo.id.toString())
                  }
                  .width('100%')
                  .divider({ strokeWidth: 0 }) // 移除分割线
                }
              }
              .width('100%')
              .padding(16)
            }
            .layoutWeight(1)

            // 底部导航栏
            TabBar({ currentIndex: 0 })
          }
          .width('100%')
          .height('100%')
          .backgroundColor(this.currentTheme.backgroundColor)
        }
      }
    }
  }
}

// // Minimal TodoItem class is already defined above
// // class TodoItem { ... }

// // Note: System and Permission methods (getAppAbilityContext, etc.) are part of the Index struct.
// // Interfaces are defined at the top of the file.