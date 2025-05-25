import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import wantConstant from '@ohos.ability.wantConstant';
import Want from '@ohos.app.ability.Want';
import { TabBar } from '../components/TabBar';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { PhxSystemActionUtil } from '../utils/PhxSystemActionUtil';
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
  todoId?: string | number; // 用于简单待办
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
  onConfirm: () => void = () => {};
  controller?: CustomDialogController;

  build() {
    Column() {
      Text("添加新待办").fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
      TextInput({ placeholder: "待办名称", text: this.todoName })
        .onChange(val => { this.todoName = val; })
        .margin({ bottom: 10 })
      TextInput({ placeholder: "类型 (如: 学习, 工作)", text: this.todoType })
        .onChange(val => { this.todoType = val; })
        .margin({ bottom: 10 })
      TextInput({ placeholder: "时长 (分钟)", text: this.todoDuration.toString() })
        .type(InputType.Number)
        .onChange(val => { this.todoDuration = Number(val) || 25; })
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
  // @State showCongratulationsDialog: boolean = false; // 暂时移除，或根据简单待办调整
  @State isClockInMenuShow: boolean = false; // 保留打卡相关UI状态
  @State isClockInStatsShow: boolean = false; // 保留打卡相关UI状态
  @State isPermissionDialogShow: boolean = false; // 保留权限相关UI状态

  // 替换 todoCollections 为 simpleTodos
  @State simpleTodos: TodoItem[] = [
    new TodoItem(1, "阅读ArkTS文档", "学习", 30),
    new TodoItem(2, "编写示例代码", "学习", 45),
    new TodoItem(3, "跑步", "锻炼", 20)
  ];
  private nextTodoId: number = 4; // 用于生成新的简单待办ID

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
      onConfirm: () => { this.addNewSimpleTodo(); }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: false // 根据需要设置
  });

  aboutToAppear() {
    console.info('Index aboutToAppear. CurrentIndex: ' + this.currentIndex);
    this.currentIndex = 0; // 明确 Index 页面的 currentIndex
  }

  onPageShow() {
    console.info("Index page onPageShow triggered");
    const routeParams = router.getParams() as RouterParams;
    if (routeParams && typeof routeParams === 'object') {
      console.info('Index onPageShow router.getParams(): ' + JSON.stringify(routeParams));

      if (routeParams.action === 'focusCompleted' && routeParams.todoId !== undefined) {
        const completedTodoId = Number(routeParams.todoId);
        const todo = this.simpleTodos.find(t => t.id === completedTodoId);
        if (todo) {
          todo.isCompleted = true;
          // 更新列表以触发UI刷新
          this.simpleTodos = [...this.simpleTodos];
          promptAction.showToast({ message: `任务 "${todo.title}" 专注完成！` });

          // 检查是否所有简单待办都已完成
          // const allSimpleTodosDone = this.simpleTodos.every(t => t.isCompleted);
          // if (allSimpleTodosDone) {
          //   // this.showCongratulationsDialog = true; // 可选择性开启
          //   // setTimeout(() => { this.showCongratulationsDialog = false; }, 5000);
          //   promptAction.showToast({ message: "太棒了！所有待办都已完成！" });
          // }
        }
      }
      // 移除所有与 sequenceAction, collectionId, completedSubTaskIndex 相关的处理逻辑
    }
    this.currentIndex = 0; // 确保在页面显示时 currentIndex 正确
  }

  addNewSimpleTodo() {
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

    const newTodo = new TodoItem(
      this.nextTodoId++,
      this.newSimpleTodoName.trim(),
      this.newSimpleTodoType.trim(),
      this.newSimpleTodoDuration
    );
    this.simpleTodos.push(newTodo);
    // this.simpleTodos = [...this.simpleTodos]; // 如果直接push不更新UI，则使用此方法

    // 重置输入框
    this.newSimpleTodoName = '';
    this.newSimpleTodoType = '';
    this.newSimpleTodoDuration = 25;

    promptAction.showToast({ message: "新待办已添加" });
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

  build() {
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
            .borderRadius(12).padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ right: 4 })
            .onClick(() => { this.handlePermissionSettings(); })
            Text('✓').fontSize(24).fontColor('#FFFFFF')
              .onClick(() => { promptAction.showToast({message: "打卡菜单待实现"}); })
            Text('+').fontSize(24).fontColor('#FFFFFF')
            .onClick(() => {
                this.newSimpleTodoName = '';
                this.newSimpleTodoType = '';
                this.newSimpleTodoDuration = 25;
                this.addSimpleTodoDialogController.open();
              })
            Text('≡').fontSize(24).fontColor('#FFFFFF')
              .onClick(() => { promptAction.showToast({message: "更多菜单待实现"}); })
          }
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .linearGradient({ angle: 90, colors: [['#8A2BE2', 0.0], ['#FF1493', 1.0]] })

        // 内容区域
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.simpleTodos, (todo: TodoItem) => {
              Row() {
                Column() {
                  Text(todo.title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .decoration({type: todo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                  Text(`${todo.type} - ${todo.formatDuration()}`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .decoration({type: todo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                    .margin({top: 4})
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Button('开始专注')
                  .fontSize(14)
                  .fontColor(Color.White)
                  .backgroundColor('#4682B4')
                  .borderRadius(12)
                  .height(32)
                  .padding({left: 8, right: 8})
                  .margin({left: 10})
                  .onClick(() => {
                      const params: FocusTimerRouterParams = {
                      title: todo.title,
                      taskTitle: todo.title,
                      time: todo.duration * 60,
                      todoId: todo.id,
                      isSequence: false
                    };
                    router.pushUrl({ url: 'pages/FocusTimer', params: params })
                      .catch((err: Error) => { console.error(`跳转FocusTimer出错: ${err.message}`); });
                  })
                  .visibility(todo.isCompleted ? Visibility.Hidden : Visibility.Visible)
              }
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(8)
              .padding(12)
            }, (todo: TodoItem) => todo.id.toString())
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
      .backgroundColor(this.bgColor)
      }
      .width('100%')
      .height('100%')
  }
  }

// // Minimal TodoItem class is already defined above
// // class TodoItem { ... }

// // Note: System and Permission methods (getAppAbilityContext, etc.) are part of the Index struct.
// // Interfaces are defined at the top of the file.