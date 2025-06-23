import { AddCollectionDialog } from '../components/dialogs/TodoDialogs';
import { AddSubTodoDialog } from '../components/AddSubTodoDialog';
import { TabBar } from '../components/TabBar';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../services/ThemeService';
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


// 滑动操作相关接口
interface SwipeActionBuilder {
  builder: () => void;
  actionAreaDistance: number;
  onAction: () => void;
}

interface SwipeActionOptions {
  end: SwipeActionBuilder;
}

@Entry
@Component
struct TodoPage {
  @State todoCollections: TodoCollection[] = [];
  @State isLoadingCollections: boolean = false;
  @State expandedCollections: Set<number> = new Set(); // 记录哪些合集是展开的
  @State collectionItems: Map<number, TodoCollectionItem[]> = new Map(); // 合集ID -> 子待办列表
  @State loadingItems: Set<number> = new Set(); // 正在加载子待办的合集ID
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;

  private apiService: ApiService = ApiService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();
  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
    } catch (error) {
      console.error('TodoPage主题更新失败:', error);
    }
  };

  // 待办合集对话框控制器
  private addTodoCollectionDialogController: CustomDialogController | null = null;

  // 添加子待办对话框控制器
  private addSubTodoDialogController: CustomDialogController | null = null;

  async aboutToAppear(): Promise<void> {
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    try {
      // 首先加载保存的主题偏好设置
      await this.themeService.loadThemePreference();
      this.currentTheme = await this.themeService.getCurrentTheme();
      console.info('TodoPage加载主题成功:', this.currentTheme.name);
    } catch (error) {
      console.error('加载主题失败:', error);
    }
    await this.loadTodoCollections();
    // 默认展开所有合集，提升用户体验
    await this.expandAllCollections();
  }

  aboutToDisappear() {
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  async onPageShow(): Promise<void> {
    await this.loadTodoCollections();
    // 默认展开所有合集，包括新创建的
    await this.expandAllCollections();
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

  // 默认展开所有合集，提升用户体验
  async expandAllCollections(): Promise<void> {
    if (this.todoCollections.length === 0) return;
    
    console.info('默认展开所有合集，提升用户体验');
    
    // 展开所有合集
    for (let collection of this.todoCollections) {
      this.expandedCollections.add(collection.id);
    }
    this.expandedCollections = new Set(this.expandedCollections);
    
    // 加载所有合集的子任务
    for (let collection of this.todoCollections) {
      try {
        await this.loadCollectionItems(collection.id);
      } catch (error) {
        console.error(`自动加载合集${collection.id}的子任务失败:`, error);
      }
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
      
      // 自动展开新创建的合集，提升用户体验
      this.expandedCollections.add(response.id);
      this.expandedCollections = new Set(this.expandedCollections);
      
      // 初始化新合集的子任务列表为空数组
      this.collectionItems.set(response.id, []);
      this.collectionItems = new Map(this.collectionItems);
      
      promptAction.showToast(new ToastOptions('待办合集创建成功'));
    } catch (error) {
      console.error('创建待办合集失败:', error);
      promptAction.showToast(new ToastOptions('创建失败'));
    }
  }

  // 删除待办合集 - 滑动删除
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

  // 添加子待办 - 添加后自动展开
  async addSubTodo(collectionId: number, title: string, description?: string, durationMinutes: number = 25): Promise<void> {
    try {
      console.info(`发送添加子待办请求 - 合集ID: ${collectionId}, 标题: ${title}, 时长: ${durationMinutes}分钟`);
      
      const newItem = await this.apiService.addItemToCollection(collectionId, {
        title,
        description,
        durationMinutes,
        orderIndex: 0
      });
      
      const existingItems = this.collectionItems.get(collectionId) || [];
      existingItems.push(newItem);
      this.collectionItems.set(collectionId, existingItems);
      this.collectionItems = new Map(this.collectionItems);
      
      // 自动展开该合集
      if (!this.expandedCollections.has(collectionId)) {
        this.expandedCollections.add(collectionId);
        this.expandedCollections = new Set(this.expandedCollections);
        console.info(`添加子任务后自动展开合集${collectionId}`);
      }
      
      promptAction.showToast(new ToastOptions('子待办添加成功'));
    } catch (error) {
      console.error('添加子待办失败:', error);
      promptAction.showToast(new ToastOptions('添加子待办失败'));
    }
  }

  // 删除子待办 - 滑动删除
  async deleteSubTodo(collectionId: number, itemId: number): Promise<void> {
    try {
      await this.apiService.deleteCollectionItem(collectionId, itemId);
      const items = this.collectionItems.get(collectionId) || [];
      const updatedItems = items.filter(item => item.id !== itemId);
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
      const items = this.collectionItems.get(collectionId) || [];
      const item = items.find(i => i.id === itemId);
      if (!item) return;

      await this.apiService.toggleCollectionItemStatus(collectionId, itemId);
      
      // 更新本地状态
      item.isCompleted = !item.isCompleted;
      this.collectionItems.set(collectionId, [...items]);
      this.collectionItems = new Map(this.collectionItems);
      
      promptAction.showToast(new ToastOptions(item.isCompleted ? '任务已完成' : '任务已重新开启'));
    } catch (error) {
      console.error('更新子待办状态失败:', error);
      promptAction.showToast(new ToastOptions('更新失败'));
    }
  }

  // 开始专注子待办
  startFocusForSubTodo(collectionId: number, itemId: number): void {
    const items = this.collectionItems.get(collectionId) || [];
    const item = items.find(i => i.id === itemId);
    if (!item) return;

    const focusParams: FocusTimerParams = {
      title: item.title,
      time: (item.durationMinutes || 25) * 60,
      taskTitle: item.title,
      isSequence: true,
      collectionId: collectionId.toString(),
      subTaskId: itemId.toString(),
      currentSubTaskIndex: items.findIndex(i => i.id === itemId),
      totalSubTasksInCollection: items.length
    };

    router.pushUrl({ url: 'pages/FocusTimer', params: focusParams });
  }

  // 开始序列专注（整个合集）
  startSequenceFocus(collectionId: number): void {
    const items = this.collectionItems.get(collectionId) || [];
    const uncompletedItems = items.filter(item => !item.isCompleted);
    
    if (uncompletedItems.length === 0) {
      promptAction.showToast(new ToastOptions('该合集中没有未完成的任务'));
      return;
    }

    const firstItem = uncompletedItems[0];
    const focusParams: FocusTimerParams = {
      title: firstItem.title,
      time: (firstItem.durationMinutes || 25) * 60,
      taskTitle: firstItem.title,
      isSequence: true,
      collectionId: collectionId.toString(),
      subTaskId: firstItem.id.toString(),
      currentSubTaskIndex: 0,
      totalSubTasksInCollection: uncompletedItems.length
    };

    router.pushUrl({ url: 'pages/FocusTimer', params: focusParams });
  }

  // 苹果风格的合集卡片组件 - 支持滑动删除
  @Builder
  CollectionCard(collection: TodoCollection) {
    // 使用ListItem来实现滑动删除
    ListItem() {
      Column() {
        // 合集标题区域
        Row() {
                  Column() {
          Text(collection.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTheme.textColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(collection.description || '')
            .fontSize(14)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.6)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
            .visibility(collection.description ? Visibility.Visible : Visibility.None)
        }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 展开/折叠按钮
          Button() {
            Text(this.expandedCollections.has(collection.id) ? '▼' : '▶')
              .fontSize(14)
              .fontColor(this.currentTheme.glassmorphism.accentPrimary)
          }
          .backgroundColor('transparent')
          .width(32)
          .height(32)
          .onClick(() => {
            this.toggleCollectionExpanded(collection.id);
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })

        // 操作按钮区域 - 苹果风格渐变设计
        Row({ space: 8 }) {
          Button('📝 添加子任务')
            .fontSize(12)
            .fontColor(this.currentTheme.glassmorphism.accentPrimary)
            .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
            .borderRadius(16)
            .height(32)
            .padding({ left: 12, right: 12 })
            .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
            .shadow({
              radius: 4,
              color: this.currentTheme.glassmorphism.shadowSoft,
              offsetX: 0,
              offsetY: 1
            })
            .onClick(() => {
              this.showAddSubTodoDialog(collection.id);
            })

          Button('🚀 开始序列')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .linearGradient({
              angle: 135,
              colors: [
                [this.currentTheme.glassmorphism.accentPrimary, 0.0],
                [this.currentTheme.glassmorphism.accentSecondary, 1.0]
              ]
            })
            .borderRadius(16)
            .height(32)
            .padding({ left: 12, right: 12 })
            .shadow({
              radius: 6,
              color: this.currentTheme.glassmorphism.accentPrimary + '40',
              offsetX: 0,
              offsetY: 2
            })
            .blur(0.3) // 轻微哑光效果
            .onClick(() => {
              this.startSequenceFocus(collection.id);
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })

        // 子待办列表
        Column() {
          Divider()
            .color(this.currentTheme.glassmorphism.borderLight)
            .margin({ left: 16, right: 16 })

          // 加载状态
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(this.currentTheme.glassmorphism.accentPrimary)
            Text('加载中...')
              .fontSize(14)
              .fontColor(this.currentTheme.textColor)
              .opacity(0.6)
              .margin({ left: 8 })
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.Center)
          .visibility(this.loadingItems.has(collection.id) ? Visibility.Visible : Visibility.None)

          // 空状态
          Text('暂无子任务')
            .fontSize(14)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.5)
            .width('100%')
            .height(60)
            .textAlign(TextAlign.Center)
            .padding({ top: 20 })
            .visibility(!this.loadingItems.has(collection.id) && (this.collectionItems.get(collection.id) || []).length === 0 ? Visibility.Visible : Visibility.None)

          // 子任务列表
          List() {
            ForEach(this.collectionItems.get(collection.id) || [], (item: TodoCollectionItem) => {
              this.SubTodoItem(collection.id, item);
            }, (item: TodoCollectionItem) => item.id.toString())
          }
          .width('100%')
          .backgroundColor('transparent')
          .divider({ strokeWidth: 0 })
          .visibility(!this.loadingItems.has(collection.id) && (this.collectionItems.get(collection.id) || []).length > 0 ? Visibility.Visible : Visibility.None)
        }
        .visibility(this.expandedCollections.has(collection.id) ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
      .borderRadius(16)
      .border({ width: 1, color: this.currentTheme.glassmorphism.borderLight })
      .shadow({
        radius: 8,
        color: this.currentTheme.glassmorphism.shadowSoft,
        offsetX: 0,
        offsetY: 4
      })
      .margin({ bottom: 16 })
    }
    .swipeAction(this.createDeleteAction(collection.id, 80))
  }

  // 苹果风格的子待办项组件 - 支持滑动删除
  @Builder
  SubTodoItem(collectionId: number, item: TodoCollectionItem) {
    ListItem() {
      Row() {
        // 完成状态按钮
        Button() {
          Text(item.isCompleted ? '✓' : '○')
            .fontSize(16)
            .fontColor(item.isCompleted ? '#FFFFFF' : this.currentTheme.glassmorphism.accentPrimary)
        }
        .width(32)
        .height(32)
        .borderRadius(16)
        .backgroundColor(item.isCompleted ? this.currentTheme.glassmorphism.accentPrimary : 'transparent')
        .border({ 
          width: 2, 
          color: this.currentTheme.glassmorphism.accentPrimary 
        })
        .onClick(() => {
          this.toggleSubTodoStatus(collectionId, item.id);
        })

        // 任务信息
        Column() {
          Text(item.title)
            .fontSize(16)
            .fontColor(this.currentTheme.textColor)
            .opacity(item.isCompleted ? 0.5 : 1.0)
            .decoration({ type: item.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 描述文本 - 主题感知渐变样式
          Stack() {
            // 渐变背景
            Text(item.description || '')
              .fontSize(12)
              .fontColor('transparent')
              .linearGradient({
                angle: 90,
                colors: item.isCompleted ? [
                  [this.currentTheme.glassmorphism.accentTertiary, 0.0],
                  [this.currentTheme.glassmorphism.borderLight, 1.0]
                ] : [
                  [this.currentTheme.glassmorphism.accentSecondary, 0.0],
                  [this.currentTheme.glassmorphism.accentPrimary, 1.0]
                ]
              })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .blur(0.2) // 轻微哑光效果

            // 文字内容
            Text(item.description || '')
              .fontSize(12)
              .fontColor(item.isCompleted ? 
                this.currentTheme.glassmorphism.accentTertiary : 
                this.currentTheme.glassmorphism.accentSecondary)
              .opacity(item.isCompleted ? 0.5 : 0.8)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .margin({ top: 2 })
          .visibility(item.description ? Visibility.Visible : Visibility.None)

          Stack() {
            // 渐变背景
            Text(`⏱️ ${item.durationMinutes || 25}分钟`)
              .fontSize(12)
              .fontColor('transparent')
              .linearGradient({
                angle: 45,
                colors: [
                  [this.currentTheme.glassmorphism.accentPrimary, 0.0],
                  [this.currentTheme.glassmorphism.accentSecondary, 1.0]
                ]
              })
              .fontWeight(FontWeight.Medium)
              .blur(0.1) // 轻微哑光效果

            // 文字内容
            Text(`⏱️ ${item.durationMinutes || 25}分钟`)
              .fontSize(12)
              .fontColor(this.currentTheme.glassmorphism.accentPrimary)
              .fontWeight(FontWeight.Medium)
          }
          .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })

        // 专注按钮 - 主题感知渐变哑光设计
        Stack() {
          // 渐变背景层
          Column()
            .width(34)
            .height(34)
            .borderRadius(16)
            .linearGradient({
              angle: 135,
              colors: [
                [this.currentTheme.glassmorphism.accentPrimary, 0.0],
                [this.currentTheme.glassmorphism.accentSecondary, 0.5],
                [this.currentTheme.glassmorphism.accentTertiary, 1.0]
              ]
            })
            .shadow({
              radius: 10,
              color: this.currentTheme.glassmorphism.accentPrimary + '40',
              offsetX: 0,
              offsetY: 3
            })
            .border({ 
              width: 0.5, 
              color: this.currentTheme.glassmorphism.accentPrimary + '60' 
            })
            .blur(0.6) // 增强哑光效果

          // 按钮内容
          Button('🎯')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('transparent')
            .borderRadius(16)
            .width(34)
            .height(34)
            .onClick(() => {
              this.startFocusForSubTodo(collectionId, item.id);
            })
        }
        .visibility(item.isCompleted ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.currentTheme.backgroundColor)
      .borderRadius(12)
      .margin({ left: 8, right: 8, top: 4, bottom: 4 })
    }
    .swipeAction(this.createSubTodoDeleteAction(collectionId, item.id, 60))
  }

  // 显示添加合集对话框
  async showAddTodoCollectionDialog(): Promise<void> {
    try {
      // 预先获取当前主题，确保弹窗显示时主题已加载
      const currentTheme = await this.themeService.getCurrentTheme();
      console.info('准备打开添加合集弹窗，当前主题:', currentTheme.name);
      
      // 每次打开时重新创建，确保获取最新主题
      this.addTodoCollectionDialogController = new CustomDialogController({
        builder: AddCollectionDialog({
          currentTheme: currentTheme, // 传递当前主题
          onConfirm: (title: string, description?: string) => {
            this.createTodoCollectionWithParams(title, description);
          }
        }),
        autoCancel: true,
        alignment: DialogAlignment.Center,
        customStyle: true, // 使用自定义样式
        maskColor: Color.Transparent // 去掉默认的遮罩颜色
      });
      this.addTodoCollectionDialogController.open();
    } catch (error) {
      console.error('打开添加合集弹窗失败:', error);
    }
  }

  // 显示添加子待办对话框
  async showAddSubTodoDialog(collectionId: number): Promise<void> {
    try {
      // 预先获取当前主题，确保弹窗显示时主题已加载
      const currentTheme = await this.themeService.getCurrentTheme();
      console.info('准备打开添加子待办弹窗，当前主题:', currentTheme.name);
      
      // 每次打开时重新创建，确保获取最新主题
      this.addSubTodoDialogController = new CustomDialogController({
        builder: AddSubTodoDialog({
          currentTheme: currentTheme, // 传递当前主题
          onConfirm: (title: string, description: string, duration: number) => {
            this.addSubTodo(collectionId, title, description, duration);
          }
        }),
        autoCancel: true,
        alignment: DialogAlignment.Center,
        customStyle: true, // 使用自定义样式
        maskColor: Color.Transparent // 去掉默认的遮罩颜色
      });
      this.addSubTodoDialogController.open();
    } catch (error) {
      console.error('打开添加子待办弹窗失败:', error);
    }
  }

  // 创建删除合集的滑动操作
  private createDeleteAction(collectionId: number, width: number): SwipeActionOptions {
    const deleteAction: SwipeActionOptions = {
      end: {
        builder: () => {
          this.createDeleteButton(width, 16, () => {
            this.deleteTodoCollection(collectionId);
          });
        },
        actionAreaDistance: width,
        onAction: () => {
          this.deleteTodoCollection(collectionId);
        }
      } as SwipeActionBuilder
    };
    return deleteAction;
  }

  // 创建删除子待办的滑动操作
  private createSubTodoDeleteAction(collectionId: number, itemId: number, width: number): SwipeActionOptions {
    const deleteAction: SwipeActionOptions = {
      end: {
        builder: () => {
          this.createDeleteButton(width, 12, () => {
            this.deleteSubTodo(collectionId, itemId);
          });
        },
        actionAreaDistance: width,
        onAction: () => {
          this.deleteSubTodo(collectionId, itemId);
        }
      } as SwipeActionBuilder
    };
    return deleteAction;
  }

  // 创建删除按钮的构建器
  @Builder
  private createDeleteButton(width: number, borderRadius: number, clickAction: () => void) {
    Button('删除')
      .fontSize(width > 70 ? 16 : 14)
      .fontColor('#FFFFFF')
      .backgroundColor('#FF3B30')
      .borderRadius(borderRadius)
      .width(width)
      .height(width > 70 ? '100%' : '90%')
      .onClick(clickAction)
  }

  build() {
    Column() {
      // 苹果风格的顶部导航栏
      Row() {
        Text('📝 待办管理')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.textColor)
          .layoutWeight(1)

        Button() {
          Text('＋')
            .fontSize(20)
            .fontColor('#FFFFFF')
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .linearGradient({
          angle: 135,
          colors: [
            [this.currentTheme.glassmorphism.accentPrimary, 0.0],
            [this.currentTheme.glassmorphism.accentSecondary, 1.0]
          ]
        })
        .shadow({
          radius: 10,
          color: this.currentTheme.glassmorphism.accentPrimary + '50',
          offsetX: 0,
          offsetY: 3
        })
        .blur(0.3) // 哑光效果
        .onClick(() => {
          this.showAddTodoCollectionDialog();
        })
      }
      .width('100%')
      .height(64)
      .padding({ left: 20, right: 20 })
      .backgroundColor(this.currentTheme.backgroundColor)

      // 主内容区域
      // 加载状态
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(this.currentTheme.glassmorphism.accentPrimary)
        Text('加载中...')
          .fontSize(16)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.6)
          .margin({ top: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentTheme.backgroundColor)
      .visibility(this.isLoadingCollections ? Visibility.Visible : Visibility.None)

      // 空状态
      Column() {
        Text('📋')
          .fontSize(64)
          .opacity(0.3)
          .margin({ bottom: 16 })
        Text('还没有待办合集')
          .fontSize(18)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.5)
          .margin({ bottom: 8 })
        Text('点击右上角 + 号创建第一个合集')
          .fontSize(14)
          .fontColor(this.currentTheme.textColor)
          .opacity(0.4)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentTheme.backgroundColor)
      .visibility(!this.isLoadingCollections && this.todoCollections.length === 0 ? Visibility.Visible : Visibility.None)

      // 合集列表 - 支持滑动删除
      List() {
        ForEach(this.todoCollections, (collection: TodoCollection) => {
          this.CollectionCard(collection);
        }, (collection: TodoCollection) => collection.id.toString())
      }
      .layoutWeight(1)
      .backgroundColor(this.currentTheme.backgroundColor)
      .scrollBar(BarState.Off)
      .padding({ left: 16, right: 16, top: 16, bottom: 100 })
      .divider({ strokeWidth: 0 })
      .visibility(!this.isLoadingCollections && this.todoCollections.length > 0 ? Visibility.Visible : Visibility.None)

      // 底部导航栏
      TabBar({ currentIndex: 1 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.backgroundColor)
  }
}