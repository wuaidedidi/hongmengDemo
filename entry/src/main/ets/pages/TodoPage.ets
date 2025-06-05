import { AddTodoCollectionDialog } from '../components/AddTodoCollectionDialog';
import { AddSubTodoDialog } from '../components/AddSubTodoDialog';
import { TabBar } from '../components/TabBar';
import { ThemeService, ThemeConfig } from '../services/ThemeService';
import { 
  ApiService, 
  TodoCollection, 
  TodoCollectionItem,
  TodoCollectionRequest,
  TodoCollectionItemRequest
} from '../services/ApiService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ToastOptions } from '../models/ToastOptions';
import { RouterOptions } from '../models/RouterOptions';
import { FocusTimerParams } from '../models/FocusTimerParams';
import { BusinessError } from '@ohos.base';

// 用于对话框的简单接口
interface DialogData {
  title: string;
  description?: string;
}

@Entry
@Component
struct TodoPage {
  @State todoCollections: TodoCollection[] = [];
  @State isLoadingCollections: boolean = false;
  @State expandedCollections: Set<number> = new Set(); // 记录哪些合集是展开的
  @State collectionItems: Map<number, TodoCollectionItem[]> = new Map(); // 合集ID -> 子待办列表
  @State loadingItems: Set<number> = new Set(); // 正在加载子待办的合集ID
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

  // 待办合集对话框控制器
  private addTodoCollectionDialogController: CustomDialogController = new CustomDialogController({
    builder: AddTodoCollectionDialog({
      onConfirm: (data: DialogData) => {
        this.createTodoCollectionWithParams(data.title, data.description);
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  // 添加子待办对话框控制器
  private addSubTodoDialogController: CustomDialogController | null = null;

  async aboutToAppear(): Promise<void> {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('加载主题失败:', error);
    }
    await this.loadTodoCollections();
  }

  async onPageShow(): Promise<void> {
    await this.loadTodoCollections();
    // 确保重新加载已展开合集的子待办数据
    await this.reloadExpandedCollections();
  }

  // 加载待办合集
  async loadTodoCollections(): Promise<void> {
    try {
      this.isLoadingCollections = true;
      const apiCollections = await this.apiService.getTodoCollections();
      this.todoCollections = apiCollections;
    } catch (error) {
      console.error('加载待办合集失败:', error);
      promptAction.showToast(new ToastOptions('加载待办合集失败'));
    } finally {
      this.isLoadingCollections = false;
    }
  }

  // 重新加载已展开合集的子待办数据
  async reloadExpandedCollections(): Promise<void> {
    const expandedIds = Array.from(this.expandedCollections);
    console.info('重新加载已展开合集的子待办数据:', expandedIds);
    
    for (let collectionId of expandedIds) {
      try {
        await this.loadCollectionItems(collectionId);
      } catch (error) {
        console.error(`重新加载合集${collectionId}子待办失败:`, error);
      }
    }
  }

  // 加载合集子待办
  async loadCollectionItems(collectionId: number): Promise<void> {
    try {
      console.info(`开始加载合集${collectionId}的子待办数据`);
      this.loadingItems.add(collectionId);
      this.loadingItems = new Set(this.loadingItems);
      
      const items = await this.apiService.getCollectionItems(collectionId);
      console.info(`成功加载合集${collectionId}的子待办，数量: ${items.length}`);
      
      this.collectionItems.set(collectionId, items);
      this.collectionItems = new Map(this.collectionItems);
    } catch (error) {
      console.error(`加载合集${collectionId}子待办失败:`, error);
      promptAction.showToast(new ToastOptions('加载子待办失败'));
      
      // 即使加载失败，也要设置空数组，避免一直显示加载状态
      this.collectionItems.set(collectionId, []);
      this.collectionItems = new Map(this.collectionItems);
    } finally {
      this.loadingItems.delete(collectionId);
      this.loadingItems = new Set(this.loadingItems);
      console.info(`合集${collectionId}子待办加载完成`);
    }
  }

  // 切换合集展开/折叠状态
  async toggleCollectionExpanded(collectionId: number): Promise<void> {
    if (this.expandedCollections.has(collectionId)) {
      // 折叠
      this.expandedCollections.delete(collectionId);
      this.expandedCollections = new Set(this.expandedCollections);
      console.info(`合集${collectionId}已折叠`);
    } else {
      // 展开
      this.expandedCollections.add(collectionId);
      this.expandedCollections = new Set(this.expandedCollections);
      console.info(`合集${collectionId}已展开`);
      
      // 如果还没有加载子待办，则立即加载
      if (!this.collectionItems.has(collectionId)) {
        console.info(`开始加载合集${collectionId}的子待办`);
        await this.loadCollectionItems(collectionId);
      } else {
        console.info(`合集${collectionId}的子待办已缓存，数量: ${this.collectionItems.get(collectionId)?.length}`);
      }
    }
  }

  // 创建待办合集
  async createTodoCollectionWithParams(title: string, description?: string): Promise<void> {
    try {
      const response = await this.apiService.createTodoCollectionDirect(title, description);
      this.todoCollections.push(response);
      this.todoCollections = Array.from(this.todoCollections);
      promptAction.showToast(new ToastOptions('待办合集创建成功'));
    } catch (error) {
      console.error('创建待办合集失败:', error);
      promptAction.showToast(new ToastOptions('创建失败'));
    }
  }

  // 删除待办合集
  async deleteTodoCollection(collectionId: number): Promise<void> {
    try {
      await this.apiService.deleteTodoCollection(collectionId);
      this.todoCollections = this.todoCollections.filter(collection => collection.id !== collectionId);
      // 清理相关状态
      this.expandedCollections.delete(collectionId);
      this.collectionItems.delete(collectionId);
      this.loadingItems.delete(collectionId);
      this.expandedCollections = new Set(this.expandedCollections);
      this.collectionItems = new Map(this.collectionItems);
      this.loadingItems = new Set(this.loadingItems);
      promptAction.showToast(new ToastOptions('待办合集已删除'));
    } catch (error) {
      console.error('删除待办合集失败:', error);
      promptAction.showToast(new ToastOptions('删除失败'));
    }
  }

  // 添加子待办
  async addSubTodo(collectionId: number, title: string, description?: string, durationMinutes: number = 25): Promise<void> {
    try {
      const newItem = await this.apiService.addItemToCollection(collectionId, {
        title,
        description,
        order: 0  // 后端会自动处理顺序
      });
      
      // 更新本地状态
      const existingItems = this.collectionItems.get(collectionId) || [];
      existingItems.push(newItem);
      this.collectionItems.set(collectionId, existingItems);
      this.collectionItems = new Map(this.collectionItems);
      
      promptAction.showToast(new ToastOptions('子待办添加成功'));
    } catch (error) {
      console.error('添加子待办失败:', error);
      promptAction.showToast(new ToastOptions('添加子待办失败'));
    }
  }

  // 删除子待办
  async deleteSubTodo(collectionId: number, itemId: number): Promise<void> {
    try {
      await this.apiService.deleteCollectionItem(collectionId, itemId);
      
      // 更新本地状态
      const existingItems = this.collectionItems.get(collectionId) || [];
      const updatedItems = existingItems.filter(item => item.id !== itemId);
      this.collectionItems.set(collectionId, updatedItems);
      this.collectionItems = new Map(this.collectionItems);
      
      promptAction.showToast(new ToastOptions('子待办已删除'));
    } catch (error) {
      console.error('删除子待办失败:', error);
      promptAction.showToast(new ToastOptions('删除失败'));
    }
  }

  // 切换子待办完成状态
  async toggleSubTodoStatus(collectionId: number, itemId: number): Promise<void> {
    try {
      const updatedItem = await this.apiService.toggleCollectionItemStatus(collectionId, itemId);
      
      // 更新本地状态
      const existingItems = this.collectionItems.get(collectionId) || [];
      const index = existingItems.findIndex(item => item.id === itemId);
      if (index !== -1) {
        existingItems[index] = updatedItem;
        this.collectionItems.set(collectionId, [...existingItems]);
        this.collectionItems = new Map(this.collectionItems);
      }
      
      const message = updatedItem.completed ? '子待办已完成' : '子待办已重新激活';
      promptAction.showToast(new ToastOptions(message));
    } catch (error) {
      console.error('更新子待办状态失败:', error);
      promptAction.showToast(new ToastOptions('更新状态失败'));
    }
  }

  // 开始单个子待办专注
  startFocusForSubTodo(collectionId: number, itemId: number): void {
    const items = this.collectionItems.get(collectionId) || [];
    console.info(`开始单个子待办专注 - 合集ID: ${collectionId}, 子待办ID: ${itemId}, 总数: ${items.length}`);
    
    const currentIndex = items.findIndex(item => item.id === itemId);
    
    if (currentIndex === -1) {
      console.error(`找不到子待办 ${itemId} 在合集 ${collectionId} 中`);
      promptAction.showToast(new ToastOptions('找不到指定的子待办'));
      return;
    }

    const currentItem = items[currentIndex];
    console.info(`当前任务信息:`, { id: currentItem.id, title: currentItem.title, index: currentIndex });
    
    const params: FocusTimerParams = {
      title: currentItem.title,
      taskTitle: currentItem.title,
      time: 25 * 60, // 默认25分钟，因为ApiService中的TodoCollectionItem没有durationMinutes属性
      isSequence: true,
      collectionId: collectionId.toString(),
      subTaskId: itemId.toString(),
      currentSubTaskIndex: currentIndex,
      totalSubTasksInCollection: items.length
    };

    console.info(`启动专注参数:`, JSON.stringify(params));

    const routerOpts = new RouterOptions('pages/FocusTimer');
    router.pushUrl({
      url: routerOpts.url,
      params: params
    }, router.RouterMode.Single, (err: BusinessError) => {
      if (err) {
        console.error(`跳转FocusTimer出错: ${err.message}`);
      }
    });
  }

  // 开始合集序列专注（从第一个开始）
  async startFocusForCollection(collection: TodoCollection): Promise<void> {
    console.info(`开始合集序列专注 - 合集: ${collection.title}`);
    
    // 自动展开合集（如果未展开）
    if (!this.expandedCollections.has(collection.id)) {
      console.info(`自动展开合集${collection.id}`);
      this.expandedCollections.add(collection.id);
      this.expandedCollections = new Set(this.expandedCollections);
    }
    
    // 确保已加载子待办数据
    if (!this.collectionItems.has(collection.id)) {
      console.info(`合集${collection.id}的子待办数据未加载，开始加载...`);
      try {
        await this.loadCollectionItems(collection.id);
      } catch (error) {
        console.error('加载子待办数据失败:', error);
        promptAction.showToast(new ToastOptions('加载子待办数据失败'));
        return;
      }
    }
    
    const items = this.collectionItems.get(collection.id) || [];
    console.info(`合集序列专注 - 子待办数量: ${items.length}`);
    
    if (items.length === 0) {
      console.warn('合集中没有子待办');
      promptAction.showToast(new ToastOptions('合集中没有子待办，请先添加子待办'));
      return;
    }

    // 从第一个未完成的子待办开始
    const firstIncompleteIndex = items.findIndex(item => !item.completed);
    const startIndex = firstIncompleteIndex === -1 ? 0 : firstIncompleteIndex;
    const firstItem = items[startIndex];
    
    console.info(`序列开始信息:`, { 
      startIndex, 
      firstIncompleteIndex, 
      firstItem: { id: firstItem.id, title: firstItem.title, completed: firstItem.completed },
      totalItems: items.length
    });

    const params: FocusTimerParams = {
      title: `${collection.title} - ${firstItem.title}`,
      taskTitle: firstItem.title,
      time: 25 * 60, // 默认25分钟
      isSequence: true,
      collectionId: collection.id.toString(),
      subTaskId: firstItem.id.toString(),
      currentSubTaskIndex: startIndex,
      totalSubTasksInCollection: items.length
    };

    console.info(`启动序列专注参数:`, JSON.stringify(params));

    const routerOpts = new RouterOptions('pages/FocusTimer');
    router.pushUrl({
      url: routerOpts.url,
      params: params
    }, router.RouterMode.Single, (err: BusinessError) => {
      if (err) {
        console.error(`跳转FocusTimer出错: ${err.message}`);
      }
    });
  }

  // 显示添加子待办对话框
  showAddSubTodoDialog(collectionId: number): void {
    this.addSubTodoDialogController = new CustomDialogController({
      builder: AddSubTodoDialog({
        onConfirm: (title: string, description: string, duration: number) => {
          this.addSubTodo(collectionId, title, description, duration);
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center
    });
    this.addSubTodoDialogController.open();
  }

  // 渲染待办合集列表
  @Builder
  buildTodoCollectionsList() {
    if (this.isLoadingCollections) {
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
    } else if (this.todoCollections.length === 0) {
      Column() {
        Text('暂无待办合集')
          .fontSize(16)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.6)
        Text('点击右上角 + 号添加新的待办合集')
          .fontSize(14)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.4)
          .margin({ top: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(40)
    } else {
      List({ space: 8 }) {
        ForEach(this.todoCollections, (collection: TodoCollection) => {
          ListItem() {
            this.buildCollectionItemView(collection)
          }
          .swipeAction({
            end: {
              builder: () => {
                this.deleteCollectionBuilder(collection)
              }
            }
          })
        }, (collection: TodoCollection) => collection.id.toString())
      }
      .width('100%')
      .divider({ strokeWidth: 0 })
    }
  }

  // 构建合集项视图
  @Builder
  buildCollectionItemView(collection: TodoCollection) {
    Column() {
      // 合集主行
      Row() {
        // 展开/折叠指示器
        Text(this.expandedCollections.has(collection.id) ? '▼' : '▶')
          .fontSize(14)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.6)
          .width(20)
          .onClick(() => {
            this.toggleCollectionExpanded(collection.id);
          })

        Column() {
          Text(collection.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.currentTheme.textColor)
          
          if (collection.description) {
            Text(collection.description)
              .fontSize(14)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.6)
              .margin({ top: 4 })
          }
          
          Text(this.getItemCountText(collection.id))
            .fontSize(12)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.5)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => {
          this.toggleCollectionExpanded(collection.id);
        })

        Button('开始序列')
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(this.currentTheme.primaryColor)
          .borderRadius(8)
          .height(28)
          .padding({left: 8, right: 8})
          .onClick(async () => {
            await this.startFocusForCollection(collection);
          })
      }
      .width('100%')
      .padding(12)

      // 子待办列表（展开时显示）
      if (this.expandedCollections.has(collection.id)) {
        this.buildSubItemsList(collection.id)
      }
    }
    .width('100%')
    .backgroundColor(this.currentTheme.cardBackgroundColor)
    .borderRadius(8)
  }

  // 构建子项列表
  @Builder
  buildSubItemsList(collectionId: number) {
    Divider()
      .color(this.currentTheme.borderColor)
      .margin({ left: 12, right: 12 })

    if (this.loadingItems.has(collectionId)) {
      Row() {
        LoadingProgress()
          .width(20)
          .height(20)
          .margin({ right: 8 })
        Text('加载子待办中...')
          .fontSize(14)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.6)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 10, bottom: 10 })
    } else {
      Column({ space: 4 }) {
        // 使用List组件支持swipeAction
        List({ space: 4 }) {
          ForEach(this.getCollectionItems(collectionId), (item: TodoCollectionItem, index: number) => {
            ListItem() {
              this.buildSubItemRow(item, index, collectionId)
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.deleteSubTodoBuilder(item, collectionId)
                }
              }
            })
          }, (item: TodoCollectionItem) => item.id.toString())
        }
        .width('100%')
        .scrollBar(BarState.Off)

        // 添加子待办按钮
        Row() {
          Text('+')
            .fontSize(16)
            .fontColor(this.currentTheme.primaryColor)
            .width(30)
          
          Text('添加子待办')
            .fontSize(14)
            .fontColor(this.currentTheme.primaryColor)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.showAddSubTodoDialog(collectionId);
        })
      }
      .width('100%')
      .padding({ bottom: 8 })
    }
  }

  // 构建子项行
  @Builder
  buildSubItemRow(item: TodoCollectionItem, index: number, collectionId: number) {
    Row() {
      Text(`${index + 1}.`)
        .fontSize(14)
        .fontColor(this.currentTheme.textColor)
        .opacity(0.6)
        .width(30)
      
      Column() {
        Text(item.title)
          .fontSize(14)
          .fontColor(this.currentTheme.textColor)
          .decoration({type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
          .opacity(item.completed ? 0.6 : 1.0)
        
        if (item.description) {
          Text(item.description)
            .fontSize(12)
            .fontColor(this.currentTheme.textColor)
            .opacity(item.completed ? 0.4 : 0.6)
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      Text('25min') // 默认25分钟，因为ApiService中的TodoCollectionItem没有durationMinutes属性
        .fontSize(12)
        .fontColor(this.currentTheme.textColor)
        .opacity(0.5)
        .margin({ right: 8 })
      
      if (item.completed) {
        Text('✓')
          .fontSize(16)
          .fontColor('#34C759')
          .margin({ right: 8 })
      }

      Button('开始')
        .fontSize(10)
        .fontColor(Color.White)
        .backgroundColor(this.currentTheme.primaryColor)
        .borderRadius(6)
        .height(24)
        .padding({left: 6, right: 6})
        .onClick(() => {
          this.startFocusForSubTodo(collectionId, item.id);
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor(item.completed ? 'rgba(0, 0, 0, 0.05)' : 'transparent')
    .borderRadius(4)
    .onClick(() => {
      this.toggleSubTodoStatus(collectionId, item.id);
    })
  }

  // 删除子待办按钮构建器
  @Builder
  deleteSubTodoBuilder(item: TodoCollectionItem, collectionId: number) {
    Row() {
      Column() {
        Text('🗑️')
          .fontSize(16)
          .margin({ bottom: 2 })
        Text('删除')
          .fontSize(10)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width(70)
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#FF6B6B', 0.0], ['#FF3B30', 1.0]]
      })
      .shadow({
        radius: 6,
        color: 'rgba(255, 59, 48, 0.3)',
        offsetX: 2,
        offsetY: 2
      })
      .onClick(() => {
        AlertDialog.show({
          title: '确认删除',
          message: `确定要删除子待办"${item.title}"吗？`,
          primaryButton: {
            value: '取消',
            action: () => {}
          },
          secondaryButton: {
            value: '删除',
            fontColor: '#FF3B30',
            action: () => {
              this.deleteSubTodo(collectionId, item.id);
            }
          }
        });
      })
    }
    .height('100%')
  }

  // 删除合集按钮构建器
  @Builder
  deleteCollectionBuilder(collection: TodoCollection) {
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
          message: `确定要删除待办合集"${collection.title}"吗？`,
          primaryButton: {
            value: '取消',
            action: () => {}
          },
          secondaryButton: {
            value: '删除',
            fontColor: '#FF3B30',
            action: () => {
              this.deleteTodoCollection(collection.id);
            }
          }
        });
      })
      .gesture(
        TapGesture()
          .onAction(() => {
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

  // 获取子待办数量的显示文本
  getItemCountText(collectionId: number): string {
    if (this.loadingItems.has(collectionId)) {
      return '加载中...';
    }
    
    const items = this.collectionItems.get(collectionId);
    if (items === undefined) {
      // 如果合集是展开状态但数据未加载，显示加载中
      if (this.expandedCollections.has(collectionId)) {
        return '加载中...';
      }
      // 如果合集是折叠状态，显示未加载
      return '点击展开查看';
    }
    
    return `${items.length} 个子待办`;
  }

  // 辅助方法
  getItemCount(collectionId: number): number {
    return this.collectionItems.get(collectionId)?.length || 0;
  }

  getCollectionItems(collectionId: number): TodoCollectionItem[] {
    return this.collectionItems.get(collectionId) || [];
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('待办合集管理')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        
        Blank()
        
        Button('+')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .backgroundColor('transparent')
          .onClick(() => {
            this.addTodoCollectionDialogController.open();
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.currentTheme.primaryColor)

      // 内容区域
      Scroll() {
        Column() {
          this.buildTodoCollectionsList()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor(this.currentTheme.backgroundColor)

      // 底部导航栏
      TabBar({ currentIndex: 1 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.backgroundColor)
  }
}