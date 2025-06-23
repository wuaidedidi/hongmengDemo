import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import wantConstant from '@ohos.ability.wantConstant';
import bundleManager from '@ohos.bundle.bundleManager';
import type Want from '@ohos.app.ability.Want';
import { TodoCollection, TodoItem, TodoStatus } from '../model/TodoTypes';
import { mockCollections } from '../model/MockData';
import { TabBar } from '../components/TabBar';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';
import { ActualTodoItem, LocalTodoCollection } from '../model/TodoDetailTypes';
import { AddTodoDialog, AddCollectionDialog, PermissionDialog, AddSubTaskDialog } from '../components/dialogs/TodoDialogs';
import { 
  TodoDetailRouterParams, 
  TodoItemDisplay, 
  RouterError, 
  FocusTimerRouterParams 
} from '../types/CommonTypes';










@Entry
@Component
struct TodoDetail {
  @State collections: LocalTodoCollection[] = [];
  @State currentExpandedId: string | null = null;
  @State currentIndex: number = 1;
  @State bgColor: string = 'rgba(173, 216, 230, 0.15)';
  @State showCongratulationsDialog: boolean = false;
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
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
  private addCollectionDialogController: CustomDialogController | null = null;
  private addSubTaskDialogController: CustomDialogController | null = null;
  private themeService = ThemeService.getInstance();

  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('TodoDetail主题更新失败:', error);
    }
  };

  async aboutToAppear() {
    console.info('TodoDetail aboutToAppear. CurrentIndex: ' + this.currentIndex);
    this.currentIndex = 1;
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    // 首先加载保存的主题偏好设置
    await this.themeService.loadThemePreference();
    this.currentTheme = await this.themeService.getCurrentTheme();
    this.processRouteParams(); // 处理首次进入时可能存在的路由参数
  }

  aboutToDisappear() {
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  onPageShow() {
    console.info("TodoDetail page onPageShow triggered");
    this.currentIndex = 1;
    this.processRouteParams(); // 处理每次页面显示时的路由参数
  }

  processRouteParams() {
    const params = router.getParams() as TodoDetailRouterParams;
    if (!params || Object.keys(params).length === 0) {
      console.info('TodoDetail: No route params to process.');
      return;
    }
    console.info('TodoDetail router.getParams(): ' + JSON.stringify(params));

    this.handleRouterParams(params);
  }

  handleRouterParams(params: TodoDetailRouterParams) {
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
    this.todoCollections = Array.from(this.todoCollections);
  }

  // 动态创建添加合集弹窗
  async openAddCollectionDialog() {
    try {
      this.newCollectionTitle = '';
      const currentTheme = await this.themeService.getCurrentTheme();
      
      this.addCollectionDialogController = new CustomDialogController({
        builder: AddCollectionDialog({
          collectionTitle: this.newCollectionTitle,
          currentTheme: currentTheme,
          onConfirm: (title: string) => {
            this.newCollectionTitle = title;
            this.addNewCollection();
          }
        }),
        autoCancel: true,
        alignment: DialogAlignment.Center,
        customStyle: true,
        maskColor: Color.Transparent
      });
      this.addCollectionDialogController.open();
    } catch (error) {
      console.error('打开添加合集弹窗失败:', error);
    }
  }

  // 动态创建添加子任务弹窗
  async openAddSubTaskDialog() {
    try {
      const currentTheme = await this.themeService.getCurrentTheme();
      
      this.addSubTaskDialogController = new CustomDialogController({
        builder: AddSubTaskDialog({
          currentTheme: currentTheme,
          onConfirm: (title: string, duration: number) => {
            this.addNewSubTask(title, duration);
          }
        }),
        autoCancel: true,
        alignment: DialogAlignment.Center,
        customStyle: true,
        maskColor: Color.Transparent
      });
      this.addSubTaskDialogController.open();
    } catch (error) {
      console.error('打开添加子任务弹窗失败:', error);
    }
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
      this.todoCollections = Array.from(this.todoCollections);
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
    this.todoCollections = Array.from(this.todoCollections);

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
        this.todoCollections = Array.from(this.todoCollections);
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
    this.todoCollections = Array.from(this.todoCollections);
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

  // 添加新子任务的方法
  addNewSubTask(title: string, duration: number) {
    const collection = this.todoCollections.find(c => c.id === this.currentExpandedId);
    if (collection) {
      const newTaskId = collection.id + '_s' + (collection.subTasks.length + 1);
      const newTask = new ActualTodoItem(newTaskId, title, duration);
      collection.subTasks.push(newTask);
      
      // 更新集合
      const index = this.todoCollections.findIndex(c => c.id === collection.id);
      if (index !== -1) {
        const updatedCollection = new LocalTodoCollection(
          collection.id,
          collection.collectionTitle,
          collection.subTasks,
          collection.isExpanded
        );
        updatedCollection.isSequenceActive = collection.isSequenceActive;
        updatedCollection.currentTaskIndex = collection.currentTaskIndex;
        this.todoCollections.splice(index, 1, updatedCollection);
        this.todoCollections = Array.from(this.todoCollections);
      }
      
      promptAction.showToast({ message: "新子任务已添加" });
    }
  }

  build() {
    Stack() {
      Column().width('100%').height('100%').backgroundColor(this.currentTheme.backgroundColor)
        Column() {
          Row() {
            Text('待办事项')
            .fontSize(22).fontWeight(FontWeight.Bold).fontColor(Color.White)
            Blank()
          Row({ space: 16 }) {
            Row() {
              Text('必开').fontSize(14).fontColor(Color.White)
              Text('权限').fontSize(14).fontColor(Color.White)
            }
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .borderRadius(12).padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ right: 4 })
            .onClick(() => { this.startSystemSettingsGuidanceFlow(); })
            Text('+').fontSize(24).fontColor(Color.White)
              .onClick(() => {
                this.openAddCollectionDialog();
              })
            Text('≡').fontSize(24).fontColor(Color.White)
              .onClick(() => {
                promptAction.showToast({ message: "更多菜单待实现" });
              })
          }
        }
        .width('100%').height(50).padding({ left: 16, right: 16 })
        .backgroundColor(this.currentTheme.primaryColor)

        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.todoCollections, (collection: LocalTodoCollection) => {
        Column() {
          Row() {
                  Text(collection.collectionTitle)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                    .fontColor(collection.isSequenceActive ? '#FFA500' : this.currentTheme.textColor)
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

                  Button(collection.isSequenceActive ? '序列进行中...' : 
                    (collection.subTasks.every(st => st.isCompleted) ? '重新开始序列' : '开始序列'))
                    .fontSize(14)
                    .fontColor(Color.White)
                    .backgroundColor(collection.isSequenceActive ? '#FFA500' : '#1E90FF')
                    .borderRadius(12)
                    .height(32)
                    .padding({ left: 8, right: 8 })
                    .margin({ left: 10 })
                    .enabled(!collection.isSequenceActive)
                    .onClick(() => {
                      // 如果所有任务都已完成，重置所有任务状态
                      if (collection.subTasks.every(st => st.isCompleted)) {
                        collection.subTasks.forEach(st => st.isCompleted = false);
                        // 更新UI
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
                          this.todoCollections = Array.from(this.todoCollections);
                        }
                      }
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
                .backgroundColor(collection.isExpanded ? this.currentTheme.cardBackgroundColor : this.currentTheme.cardBackgroundColor)
                .borderRadius(8)

                if (collection.isExpanded) {
                  Column({ space: 8 }) {
                    ForEach(collection.subTasks, (task: ActualTodoItem) => {
                      Swiper() {
                        Row() {
                          Column() {
                            Text(task.title)
                              .fontSize(16)
                              .fontWeight(FontWeight.Medium)
                              .fontColor(this.currentTheme.textColor)
                            Text(`${task.durationMinutes} 分钟`)
                              .fontSize(14)
                              .fontColor(this.currentTheme.textColor)
                              .opacity(0.6)
                              .margin({ top: 4 })
                          }
                          .layoutWeight(1)
                          .alignItems(HorizontalAlign.Start)

                          if (task.isCompleted) {
                            Text('✓')
                              .fontSize(20)
                              .fontColor('#4CAF50')
                          } else if (collection.currentTaskIndex === collection.subTasks.indexOf(task) && collection.isSequenceActive) {
                            Text('⏳')
                              .fontSize(20)
                              .fontColor('#FFA500')
                          }
                        }
                        .width('100%')
                        .padding(12)
                        .backgroundColor(task.isCompleted ? this.currentTheme.borderColor : this.currentTheme.cardBackgroundColor)
                        .borderRadius(8)
                        .margin({ top: collection.subTasks.indexOf(task) === 0 ? 8 : 0 })
                        .onClick(() => {
                          if (!task.isCompleted && !collection.isSequenceActive) {
                            // 如果点击未完成的子任务，从该任务开始序列
                            this.startSequenceTask(collection, collection.subTasks.indexOf(task));
                          }
                        })

                        Row() {
                          Button('删除')
                            .width('100%')
                            .height('100%')
                            .backgroundColor(this.currentTheme.errorColor)
                            .fontColor(Color.White)
                            .onClick(() => {
                              // 删除子任务
                              const taskIndex = collection.subTasks.indexOf(task);
                              if (taskIndex !== -1) {
                                collection.subTasks.splice(taskIndex, 1);
                                
                                // 更新集合
                                const index = this.todoCollections.findIndex(c => c.id === collection.id);
                                if (index !== -1) {
                                  const updatedCollection = new LocalTodoCollection(
                                    collection.id,
                                    collection.collectionTitle,
                                    collection.subTasks,
                                    collection.isExpanded
                                  );
                                  updatedCollection.isSequenceActive = collection.isSequenceActive;
                                  updatedCollection.currentTaskIndex = collection.currentTaskIndex;
                                  this.todoCollections.splice(index, 1, updatedCollection);
                                  this.todoCollections = Array.from(this.todoCollections);
                                }
                                
                                promptAction.showToast({ message: "子任务已删除" });
                              }
                            })
                        }
                        .width(80)
                        .height('100%')
                        .backgroundColor(this.currentTheme.errorColor)
                        .borderRadius(8)
                      }
                      .index(0)
                      .width('100%')
                      .height(80)
                      .displayMode(SwiperDisplayMode.STRETCH)
                      .itemSpace(0)
                      .indicator(false)
                    })

                    // 添加新子任务的按钮
                    Button('+ 添加子任务')
                      .width('100%')
                      .height(40)
                      .fontSize(14)
                      .fontColor(this.currentTheme.primaryColor)
                      .backgroundColor(this.currentTheme.cardBackgroundColor)
                      .borderRadius(8)
                      .margin({ top: 12 })
                      .onClick(() => {
                        this.currentExpandedId = collection.id;
                        this.openAddSubTaskDialog();
                      })
                  }
                  .width('100%')
                  .padding({
                    left: 8,
                    right: 8,
                    bottom: 8,
                    top: 8
                  })
                  .backgroundColor(this.currentTheme.borderColor)
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
              .backgroundColor(this.currentTheme.cardBackgroundColor)
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
          Text('太棒了!').fontSize(22).fontWeight(FontWeight.Bold).fontColor(this.currentTheme.textColor).margin({ bottom: 8 })
          Text('你已完成当前合集中的所有任务!').fontSize(16).fontColor(this.currentTheme.textColor).margin({ bottom: 20 })
          Button('我知道了')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width('70%')
            .height(40)
            .backgroundColor(this.currentTheme.primaryColor)
            .fontColor(Color.White)
          .onClick(() => {
              this.showCongratulationsDialog = false;
            })
        }
        .width('85%')
        .padding(25)
        .backgroundColor(this.currentTheme.cardBackgroundColor)
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