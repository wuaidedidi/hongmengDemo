import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import wantConstant from '@ohos.ability.wantConstant';
import bundleManager from '@ohos.bundle.bundleManager';
import type Want from '@ohos.app.ability.Want';
import { TodoCollection, TodoItem, TodoStatus } from '../model/TodoTypes';
import { mockCollections } from '../model/MockData';
import { TabBar } from '../components/TabBar';

// FocusTimer页面路由参数定义 (根据TodoDetail的需求调整)
interface FocusTimerRouterParams {
  taskTitle?: string;
  title?: string;
  time?: number; // 秒
  isSequence?: boolean;
  collectionId?: string;
  subTaskId?: string;
  currentSubTaskIndex?: number;
  totalSubTasksInCollection?: number;
  // todoId?: string | number; // TodoDetail主要处理合集，简单todoId可能不需要
}

// 路由参数接口 (当从FocusTimer返回时)
interface RouterParams {
  action?: string; // e.g., 'focusCompleted'
  sequenceAction?: string; // e.g., 'taskCompleted', 'sequenceAborted'
  collectionId?: string | number;
  subTaskId?: string | number; // 记录完成或中止的子任务ID
  completedSubTaskIndex?: string | number; // 兼容旧的参数名
  currentSubTaskIndexCompleted?: string; // 兼容旧的参数名
  allSubTasksInCollectionCompleted?: string; // 兼容旧的参数名
}

// 定义路由参数接口
interface RouterError {
  message: string;
}

// 单个具体待办事项
class ActualTodoItem {
  id: string;
  title: string;
  durationMinutes: number;
  isCompleted: boolean = false;

  constructor(id: string, title: string, durationMinutes: number, isCompleted: boolean = false) {
    this.id = id;
    this.title = title;
    this.durationMinutes = durationMinutes;
    this.isCompleted = isCompleted;
  }
}

// 重命名本地的 TodoCollection 类为 LocalTodoCollection
class LocalTodoCollection {
  id: string;
  collectionTitle: string;
  subTasks: ActualTodoItem[];
  isExpanded: boolean = false;
  currentTaskIndex: number = -1;
  isSequenceActive: boolean = false;

  constructor(id: string, collectionTitle: string, subTasks: ActualTodoItem[] = [], isExpanded: boolean = false) {
    this.id = id;
    this.collectionTitle = collectionTitle;
    this.subTasks = subTasks;
    this.isExpanded = isExpanded;
    this.currentTaskIndex = -1;
    this.isSequenceActive = false;
    if (subTasks.length === 0 && id.startsWith("default")) {
      this.subTasks.push(new ActualTodoItem(Date.now().toString() + "-s1", "子任务A", 5));
      this.subTasks.push(new ActualTodoItem(Date.now().toString() + "-s2", "子任务B", 10));
    }
  }
}

// 定义TodoItem界面显示所需的类型
interface TodoItemDisplay {
  title: string;
  description: string;
  isImportant: boolean;
  isUrgent: boolean;
  status: TodoStatus;
}

@CustomDialog
struct AddTodoDialog {
  @State newTodoTitle: string = '';
  @State newTodoDuration: number = 15;
  controller: CustomDialogController;
  onConfirm: (title: string, duration: number) => void = () => {
  };

  build() {
    Column() {
      Text('添加待办')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 10 })
      
      TextInput({ placeholder: '请输入待办标题' })
        .width('90%')
        .height(40)
        .margin({ top: 16 })
        .onChange((value: string) => {
          this.newTodoTitle = value;
        })
      
      TextInput({ placeholder: '请输入时长（分钟）' })
        .width('90%')
        .height(40)
        .margin({ top: 16 })
        .type(InputType.Number)
        .onChange((value: string) => {
          this.newTodoDuration = parseInt(value) || 15;
        })
      
      Row() {
        Button('取消')
          .onClick(() => {
            this.controller.close();
          })
          .margin({ right: 10 })
        
        Button('确定')
          .onClick(() => {
            if (this.newTodoTitle.trim() === '') {
              promptAction.showToast({ message: '标题不能为空' });
              return;
            }
            this.onConfirm(this.newTodoTitle, this.newTodoDuration);
            this.controller.close();
          })
      }
      .margin({ top: 20, bottom: 10 })
    }
    .width('80%')
    .padding(20)
  }
}

@CustomDialog
struct AddCollectionDialog {
  @Link newCollectionTitle: string; // 绑定到 TodoDetail 页面的 @State
  onConfirm: () => void = () => {
  };
  controller?: CustomDialogController;

  build() {
    Column() {
      Text("添加新待办合集").fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
      TextInput({ placeholder: "合集名称", text: this.newCollectionTitle })
        .onChange(val => {
          this.newCollectionTitle = val;
        })
        .margin({ bottom: 20 })
      Row({ space: 10 }) {
        Button("取消").onClick(() => {
          if (this.controller) {
            this.controller.close();
          }
        }).layoutWeight(1)
        Button("确定").onClick(() => {
            if (this.newCollectionTitle.trim() === '') {
            promptAction.showToast({ message: '合集名称不能为空' });
              return;
            }
          this.onConfirm();
          if (this.controller) {
            this.controller.close();
      }
        }).layoutWeight(1).backgroundColor('#8A2BE2')
      }.width('100%')
    }
    .padding(20).width("80%").backgroundColor(Color.White).borderRadius(15)
  }
}

@CustomDialog
struct PermissionDialog {
  controller: CustomDialogController;
  onConfirm: () => void = () => {
  };

  build() {
    Column() {
      Text('权限设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 10 })
      
      Text('请确保以下权限已开启：')
        .fontSize(16)
        .margin({ bottom: 16 })
      
      Text('• 通知权限')
        .fontSize(14)
        .margin({ bottom: 8 })
      
      Text('• 后台运行权限')
        .fontSize(14)
        .margin({ bottom: 8 })
      
      Text('• 自启动权限')
        .fontSize(14)
      
      Row() {
        Button('取消')
          .onClick(() => {
            this.controller.close();
          })
          .margin({ right: 10 })
        
        Button('去设置')
          .onClick(() => {
            this.onConfirm();
            this.controller.close();
          })
      }
      .margin({ top: 20, bottom: 10 })
    }
    .width('80%')
    .padding(20)
  }
}

@Entry
@Component
struct TodoDetail {
  @State collections: LocalTodoCollection[] = [];
  @State currentExpandedId: string | null = null;
  @State currentIndex: number = 1;
  @State bgColor: string = 'rgba(173, 216, 230, 0.15)';
  @State showCongratulationsDialog: boolean = false;
  @State todoCollections: LocalTodoCollection[] = [
    new LocalTodoCollection("default_coll1", "学习鸿蒙开发", [
      new ActualTodoItem("s1_1", "阅读官方文档第一章", 25),
      new ActualTodoItem("s1_2", "完成入门Demo", 45),
      new ActualTodoItem("s1_3", "学习UI组件", 60)
    ]),
    new LocalTodoCollection("default_coll2", "家庭清洁任务", [
      new ActualTodoItem("s2_1", "打扫客厅", 20),
      new ActualTodoItem("s2_2", "清洗厨房", 30),
      new ActualTodoItem("s2_3", "整理卧室", 25)
    ])
  ];
  private nextCollectionIdSuffix: number = 3;
  @State newCollectionTitle: string = '';
  private addCollectionDialogController: CustomDialogController = new CustomDialogController({
    builder: AddCollectionDialog({
      newCollectionTitle: $newCollectionTitle,
      onConfirm: () => {
        this.addNewCollection();
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    console.info('TodoDetail aboutToAppear. CurrentIndex: ' + this.currentIndex);
    this.currentIndex = 1;
    this.processRouteParams(); // 处理首次进入时可能存在的路由参数
  }

  onPageShow() {
    console.info("TodoDetail page onPageShow triggered");
    this.currentIndex = 1;
    this.processRouteParams(); // 处理每次页面显示时的路由参数
  }

  processRouteParams() {
    const params = router.getParams() as RouterParams;
    if (!params || Object.keys(params).length === 0) {
      console.info('TodoDetail: No route params to process.');
      return;
    }
    console.info('TodoDetail router.getParams(): ' + JSON.stringify(params));

    this.handleRouterParams(params);
  }

  handleRouterParams(params: RouterParams) {
    if (!params) return;

    const collectionId = params.collectionId ? String(params.collectionId) : null;
    const subTaskId = params.subTaskId ? String(params.subTaskId) : null;

    if (!collectionId) return;

    const collectionIndex = this.todoCollections.findIndex(c => c.id === collectionId);
    if (collectionIndex === -1) return;

    const collection = this.todoCollections[collectionIndex];

    if (params.sequenceAction === 'taskCompleted' && subTaskId) {
      const taskIndex = collection.subTasks.findIndex(st => st.id === subTaskId);
      if (taskIndex !== -1) {
        // 标记当前任务为完成
        collection.subTasks[taskIndex].isCompleted = true;
        
        // 检查是否所有任务都已完成
        const allSubTasksDone = collection.subTasks.every(st => st.isCompleted);
        if (allSubTasksDone) {
          collection.isSequenceActive = false;
          collection.currentTaskIndex = -1;
          this.showCongratulationsDialog = true;
          setTimeout(() => {
            this.showCongratulationsDialog = false;
          }, 5000);
          promptAction.showToast({ message: `恭喜！合集 "${collection.collectionTitle}" 已全部完成！` });
        } else {
          // 序列未完成，自动启动下一个任务
          let nextUncompletedTaskIndex = -1;
          for (let i = taskIndex + 1; i < collection.subTasks.length; i++) {
            if (!collection.subTasks[i].isCompleted) {
              nextUncompletedTaskIndex = i;
              break;
            }
          }
          if (nextUncompletedTaskIndex !== -1) {
            collection.currentTaskIndex = nextUncompletedTaskIndex;
            this.startSequenceTask(collection, nextUncompletedTaskIndex);
          } else {
            collection.isSequenceActive = false;
            collection.currentTaskIndex = -1;
          }
        }
      }
    } else if (params.sequenceAction === 'sequenceAborted') {
      collection.isSequenceActive = false;
      collection.currentTaskIndex = -1;
      promptAction.showToast({ message: `序列 '${collection.collectionTitle}' 已中止` });
    } else if (params.action === 'focusCompleted' && subTaskId) {
      const taskIndex = collection.subTasks.findIndex(st => st.id === subTaskId);
      if (taskIndex !== -1) {
        collection.subTasks[taskIndex].isCompleted = true;
        promptAction.showToast({ message: `任务 '${collection.subTasks[taskIndex].title}' 已完成` });
      }
    }

    // 更新UI
    const updatedCollection = new LocalTodoCollection(
      collection.id, 
      collection.collectionTitle, 
      collection.subTasks,
      collection.isExpanded
    );
    updatedCollection.isSequenceActive = collection.isSequenceActive;
    updatedCollection.currentTaskIndex = collection.currentTaskIndex;
    this.todoCollections.splice(collectionIndex, 1, updatedCollection);
    this.todoCollections = [...this.todoCollections];
  }

  addNewCollection() {
    if (this.newCollectionTitle.trim() === '') {
      promptAction.showToast({ message: "合集名称不能为空" });
      return;
    }
    const newId = "coll_" + Date.now().toString() + '_' + this.nextCollectionIdSuffix++;
    const defaultSubTasks = [
      new ActualTodoItem(newId + '_s1', "新子任务1 (编辑我)", 10),
      new ActualTodoItem(newId + '_s2', "新子任务2 (编辑我)", 15)
    ];
    const newCollection = new LocalTodoCollection(newId, this.newCollectionTitle.trim(), defaultSubTasks);
    this.todoCollections.push(newCollection);
    this.newCollectionTitle = '';
    promptAction.showToast({ message: "新待办合集已添加" });
  }

  startSequenceTask(collection: LocalTodoCollection, startIndex: number = 0) {
    if (!collection || collection.subTasks.length === 0) {
      promptAction.showToast({ message: `合集 "${collection?.collectionTitle}" 中没有任务。` });
      return;
    }

    // 检查从startIndex开始是否还有未完成的任务
    let nextTaskIndex = -1;
    for (let i = startIndex; i < collection.subTasks.length; i++) {
      if (!collection.subTasks[i].isCompleted) {
        nextTaskIndex = i;
        break;
      }
    }

    if (nextTaskIndex === -1) {
      // 检查是否所有任务都已完成
      const allDone = collection.subTasks.every(st => st.isCompleted);
      if (allDone) {
        this.showCongratulationsDialog = true;
        setTimeout(() => {
          this.showCongratulationsDialog = false;
        }, 5000);
        promptAction.showToast({ message: `太棒了！合集 "${collection.collectionTitle}" 已全部完成！` });
      } else {
        promptAction.showToast({ message: `合集 "${collection.collectionTitle}" 中从当前位置开始没有未完成的任务。` });
      }
      collection.isSequenceActive = false;
      collection.currentTaskIndex = -1;
      const colIndex = this.todoCollections.findIndex(c => c.id === collection.id);
      if (colIndex !== -1) {
        const updatedCollection = new LocalTodoCollection(
          collection.id, 
          collection.collectionTitle, 
          collection.subTasks,
          collection.isExpanded
        );
        updatedCollection.isSequenceActive = collection.isSequenceActive;
        updatedCollection.currentTaskIndex = collection.currentTaskIndex;
        this.todoCollections.splice(colIndex, 1, updatedCollection);
      }
      this.todoCollections = [...this.todoCollections];
      return;
    }

    collection.isSequenceActive = true;
    collection.currentTaskIndex = nextTaskIndex;
    const subTask = collection.subTasks[nextTaskIndex];

    const colIdx = this.todoCollections.findIndex(c => c.id === collection.id);
    if (colIdx !== -1) {
      const updatedCollection = new LocalTodoCollection(
        collection.id, 
        collection.collectionTitle, 
        collection.subTasks,
        collection.isExpanded
      );
      updatedCollection.isSequenceActive = collection.isSequenceActive;
      updatedCollection.currentTaskIndex = collection.currentTaskIndex;
      this.todoCollections.splice(colIdx, 1, updatedCollection);
    }
    this.todoCollections = [...this.todoCollections];

    const params: FocusTimerRouterParams = {
      title: subTask.title,
      taskTitle: `${collection.collectionTitle} - ${subTask.title}`,
      time: subTask.durationMinutes * 60,
      isSequence: true,
      collectionId: collection.id,
      subTaskId: subTask.id,
      currentSubTaskIndex: nextTaskIndex,
      totalSubTasksInCollection: collection.subTasks.length
    };

    router.pushUrl({ url: 'pages/FocusTimer', params: params })
      .catch((err: RouterError) => {
        console.error(`Error navigating to FocusTimer for sequence: ${JSON.stringify(err)}`);
        promptAction.showToast({ message: `启动序列任务失败: ${err.message}` });
        collection.isSequenceActive = false;
        collection.currentTaskIndex = -1;
        const cIdx = this.todoCollections.findIndex(c => c.id === collection.id);
        if (cIdx !== -1) {
          const updatedCollection = new LocalTodoCollection(
            collection.id, 
            collection.collectionTitle, 
            collection.subTasks,
            collection.isExpanded
          );
          updatedCollection.isSequenceActive = collection.isSequenceActive;
          updatedCollection.currentTaskIndex = collection.currentTaskIndex;
          this.todoCollections.splice(cIdx, 1, updatedCollection);
        }
        this.todoCollections = [...this.todoCollections];
      });
  }

  // 添加一个处理展开/收起的方法
  toggleExpand(collection: LocalTodoCollection) {
    const index = this.todoCollections.findIndex(c => c.id === collection.id);
    if (index === -1) return;

    // 创建新的集合实例，保持所有状态
    const updatedCollection = new LocalTodoCollection(
      collection.id,
      collection.collectionTitle,
      collection.subTasks,
      !collection.isExpanded // 切换展开状态
    );
    updatedCollection.isSequenceActive = collection.isSequenceActive;
    updatedCollection.currentTaskIndex = collection.currentTaskIndex;

    // 更新集合
    this.todoCollections.splice(index, 1, updatedCollection);
    this.todoCollections = [...this.todoCollections];
  }

  @Builder
  TodoItemBuilder(item: TodoItemDisplay) {
    Row() {
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        if (item.description) {
          Text(item.description)
            .fontSize(14)
            .opacity(0.6)
            .margin({ top: 4 })
        }
      }.layoutWeight(1)

      if (item.isImportant || item.isUrgent) {
        Row() {
          if (item.isImportant) {
            Text('重要')
              .fontSize(12)
              .fontColor('#FF4500')
              .backgroundColor('#FFE4E1')
              .padding({
                left: 8,
                right: 8,
                top: 2,
                bottom: 2
              })
              .borderRadius(4)
              .margin({ right: 8 })
          }
          if (item.isUrgent) {
            Text('紧急')
              .fontSize(12)
              .fontColor('#FF0000')
              .backgroundColor('#FFF0F0')
              .padding({
                left: 8,
                right: 8,
                top: 2,
                bottom: 2
              })
              .borderRadius(4)
          }
        }
      }

      Text(item.status === TodoStatus.COMPLETED ? '✓' :
        (item.status === TodoStatus.IN_PROGRESS ? '⏳' : ''))
        .fontSize(20)
        .fontColor(item.status === TodoStatus.COMPLETED ? '#4CAF50' : '#FFA500')
        .margin({ left: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/FocusTimer',
        params: {
          taskTitle: item.title,
          time: 25 * 60
        }
      }).catch((err: RouterError) => {
        console.error('导航到专注页面失败:', err.message);
      });
    })
  }

  // 获取应用上下文
  getAppAbilityContext(): common.UIAbilityContext | undefined {
    const context = getContext(this);
    if (context && typeof context === 'object') {
      try {
        const uiContext = context as common.UIAbilityContext;
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

  // 跳转到系统应用权限设置页面
  startSystemSettingsGuidanceFlow() {
    const context = this.getAppAbilityContext();
    if (!context) {
      promptAction.showToast({ message: "无法获取应用上下文" });
      return;
    }

    try {
      // 尝试直接跳转到应用权限设置页面
      const want: Want = {
        bundleName: 'com.ohos.settings',
        abilityName: 'com.ohos.settings.MainAbility',
        parameters: {
          SETTINGS_PARAM_TYPE: 'PERMISSION_MANAGER',
          SETTINGS_PARAM_BUNDLE_NAME: context.applicationInfo?.name || '',
          SETTINGS_PARAM_PERMISSION_NAME: 'ALL'
        }
      };

      context.startAbility(want)
        .then(() => {
          console.info('Successfully launched settings page');
        })
        .catch((err: Error) => {
          console.error(`Failed to launch settings page: ${err.message}`);
          // 如果直接跳转失败，尝试跳转到应用管理页面
          const alternativeWant: Want = {
            bundleName: 'com.ohos.settings',
            abilityName: 'com.ohos.settings.MainAbility',
            parameters: {
              SETTINGS_PARAM_TYPE: 'APP_MANAGEMENT',
              SETTINGS_PARAM_BUNDLE_NAME: context.applicationInfo?.name || ''
            }
          };
          
          return context.startAbility(alternativeWant);
        })
        .catch((err: Error) => {
          console.error(`Failed to launch alternative settings page: ${err.message}`);
          // 如果还是失败，尝试跳转到系统设置主页
          const fallbackWant: Want = {
            bundleName: 'com.ohos.settings',
            abilityName: 'com.ohos.settings.MainAbility'
          };
          
          return context.startAbility(fallbackWant);
        })
        .catch((err: Error) => {
          console.error(`All attempts to launch settings failed: ${err.message}`);
          promptAction.showToast({ message: "无法打开设置页面，请手动前往系统设置>应用管理>本应用>权限管理" });
        });
    } catch (error) {
      console.error(`Error launching settings: ${(error as Error).message || String(error)}`);
      promptAction.showToast({ message: "打开设置页面时出错，请手动设置权限" });
    }
  }

  build() {
    Stack() {
      Column().width('100%').height('100%').backgroundColor(this.bgColor)
        Column() {
          Row() {
            Text('待办事项')
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
            .onClick(() => { this.startSystemSettingsGuidanceFlow(); })
            Text('+').fontSize(24).fontColor('#FFFFFF')
              .onClick(() => {
                this.newCollectionTitle = '';
                this.addCollectionDialogController.open();
              })
            Text('≡').fontSize(24).fontColor('#FFFFFF')
              .onClick(() => {
                promptAction.showToast({ message: "更多菜单待实现" });
              })
          }
        }
        .width('100%').height(50).padding({ left: 16, right: 16 })
        .linearGradient({ angle: 90, colors: [['#6A5ACD', 0.0], ['#1E90FF', 1.0]] })

        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.todoCollections, (collection: LocalTodoCollection) => {
        Column() {
          Row() {
                  Text(collection.collectionTitle)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                    .fontColor(collection.isSequenceActive ? '#FFA500' : '#333333')
                    .layoutWeight(1)
                    .onClick(() => {
                      this.toggleExpand(collection);
                    })

                  Text(collection.isExpanded ? "🔼" : "🔽")
                      .width(24)
                      .height(24)
                    .fontSize(18)
                    .textAlign(TextAlign.Center)
                    .margin({ left: 8 })
                    .onClick(() => {
                      this.toggleExpand(collection);
                    })

                  Button(collection.isSequenceActive ? '序列进行中...' : '开始序列')
                    .fontSize(14)
                    .fontColor(Color.White)
                    .backgroundColor(collection.isSequenceActive ? '#FFA500' : '#1E90FF')
                    .borderRadius(12)
                    .height(32)
                    .padding({ left: 8, right: 8 })
                    .margin({ left: 10 })
                    .enabled(!collection.isSequenceActive &&
                    collection.subTasks.some(st => !st.isCompleted))
                    .onClick(() => {
                      this.startSequenceTask(collection, 0);
                    })
                    .visibility(collection.subTasks.length > 0 ? Visibility.Visible : Visibility.Hidden)
                  }
                  .width('100%')
                .padding({
                  top: 10,
                  bottom: 10,
                  left: 10,
                  right: 10
                })
                .backgroundColor(collection.isExpanded ? '#F0F8FF' : Color.White)
                .borderRadius(8)

                if (collection.isExpanded) {
                  Column({ space: 8 }) {
                    ForEach(collection.subTasks, (subTask: ActualTodoItem, index: number) => {
                        Row() {
                          Column() {
                          Text(subTask.title)
                              .fontSize(16)
                              .fontWeight(FontWeight.Medium)
                          Text(`${subTask.durationMinutes} 分钟`)
                              .fontSize(14)
                            .opacity(0.6)
                              .margin({ top: 4 })
                          }
                          .layoutWeight(1)
                        .alignItems(HorizontalAlign.Start)

                        if (subTask.isCompleted) {
                          Text('✓')
                            .fontSize(20)
                              .fontColor('#4CAF50')
                        } else if (collection.currentTaskIndex === index && collection.isSequenceActive) {
                          Text('⏳')
                            .fontSize(20)
                            .fontColor('#FFA500')
                        }
                      }
                      .width('100%')
                      .padding(12)
                      .backgroundColor(subTask.isCompleted ? '#F5F5F5' : '#FFFFFF')
                      .borderRadius(8)
                      .margin({ top: index === 0 ? 8 : 0 })
                      .onClick(() => {
                        if (!subTask.isCompleted && !collection.isSequenceActive) {
                          // 如果点击未完成的子任务，从该任务开始序列
                          this.startSequenceTask(collection, index);
                        }
                      })
                    })
                  }
                  .width('100%')
                  .padding({
                    left: 8,
                    right: 8,
                    bottom: 8,
                    top: 8
                  })
                  .backgroundColor('rgba(0,0,0,0.02)')
                  .borderRadius(8)
                  .animation({
                    duration: 250,
                    curve: Curve.EaseInOut,
                    iterations: 1,
                    playMode: PlayMode.Normal
                  })
                }
              }
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(10)
              .padding(12)
              .shadow({
                radius: 3,
                color: 'rgba(0,0,0,0.08)',
                offsetX: 1,
                offsetY: 2
              })
            })
          }
          .width('100%').padding(16)
        }
        .layoutWeight(1)
        
        // 底部导航栏
        TabBar({ currentIndex: 1 })
      }
      .width('100%').height('100%')

      if (this.showCongratulationsDialog) {
          Column() {
          // 兼容写法：如有图片资源则用图片，否则用Emoji
          // Image($r('app.media.congrats')).width(100).height(100).margin({bottom: 15})
          Text("🎉").fontSize(60).margin({ bottom: 15 }) // 使用Emoji作为占位
          Text('太棒了!').fontSize(22).fontWeight(FontWeight.Bold).margin({ bottom: 8 })
          Text('你已完成当前合集中的所有任务!').fontSize(16).fontColor('#333333').margin({ bottom: 20 })
          Button('我知道了')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width('70%')
            .height(40)
            .backgroundColor('#1E90FF')
            .fontColor(Color.White)
          .onClick(() => {
              this.showCongratulationsDialog = false;
            })
        }
        .width('85%')
        .padding(25)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({
          radius: 10,
          color: 'rgba(0,0,0,0.2)',
          offsetX: 2,
          offsetY: 2
        })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .markAnchor({ x: '50%', y: '50%' }) // 居中显示的关键
        .position({ x: '50%', y: '50%' })
        .transition(TransitionEffect.opacity(300)
          .combine(TransitionEffect.scale({
            x: 0.7,
            y: 0.7,
            centerX: '50%',
            centerY: '50%'
          })))
        .zIndex(10)
      }
    }
    .width('100%').height('100%')
  }
} 