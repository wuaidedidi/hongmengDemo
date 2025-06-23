// 待办事项列表组件 - 从Index.ets中抽取的待办事项功能

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ApiService, TodoItemRequest } from '../../services/ApiService';
import type { TodoItem as ApiTodoItem } from '../../services/ApiService';
import { TodoItem } from '../../model/TodoItem';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../../services/ThemeService';
import { ThemeAwareGradientBackground, ThemeAwareGlassCard } from '../../utils/GlassmorphismStyles';
import { CommonButton, ButtonPresets } from '../common/CommonButton';
import { InputDialog } from '../dialogs/CommonDialog';
import { handleError, safeExecute } from '../../utils/ErrorHandler';
import { STRINGS, UI_SIZES, FONT_SIZES, DURATION_CONSTANTS } from '../../constants/AppConstants';
import { FocusTimerRouterParams } from '../../types/CommonTypes';

/**
 * 待办事项列表组件事件回调接口
 */
export interface TodoListCallbacks {
  onTodoAdded: (todo: TodoItem) => void;
  onTodoUpdated: (todo: TodoItem) => void;
  onTodoDeleted: (todoId: number) => void;
  onTodoCompleted: (todo: TodoItem) => void;
  onError: (error: string) => void;
}

/**
 * 新增待办事项对话框
 */
@CustomDialog
struct AddTodoDialog {
  @State todoName: string = '';
  @State todoType: string = '';
  @State todoDuration: number = DURATION_CONSTANTS.DEFAULT_TODO_DURATION;
  @Prop currentTheme: ThemeConfig;
  
  onConfirm: (name: string, type: string, duration: number) => void = () => {};
  controller?: CustomDialogController;

  build() {
    Column() {
      // 标题区域
      Column() {
        Text('✨')
          .fontSize(32)
          .margin({ bottom: 8 })
        Text('添加新待办')
          .fontSize(FONT_SIZES.TITLE_MEDIUM)
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
          .borderRadius(UI_SIZES.CARD_BORDER_RADIUS)
          .border({ 
            width: 0.5, 
            color: this.currentTheme.glassmorphism.accentSecondary + '50' 
          })
          .fontColor(this.currentTheme.textColor)
          .fontSize(FONT_SIZES.BODY_LARGE)
          .height(UI_SIZES.BUTTON_HEIGHT)

        TextInput({ placeholder: "待办类型", text: this.todoType })
          .onChange(val => {
            this.todoType = val;
          })
          .backgroundColor(this.currentTheme.glassmorphism.surfaceLight + 'D0')
          .borderRadius(UI_SIZES.CARD_BORDER_RADIUS)
          .border({ 
            width: 0.5, 
            color: this.currentTheme.glassmorphism.accentSecondary + '50' 
          })
          .fontColor(this.currentTheme.textColor)
          .fontSize(FONT_SIZES.BODY_LARGE)
          .height(UI_SIZES.BUTTON_HEIGHT)

        Row() {
          Text('专注时长:')
            .fontSize(FONT_SIZES.BODY_MEDIUM)
            .fontColor(this.currentTheme.textColor)
          
          Slider({
            value: this.todoDuration,
            min: 5,
            max: 120,
            step: 5
          })
            .width(120)
            .trackColor(this.currentTheme.glassmorphism.surfaceLight)
            .selectedColor(this.currentTheme.glassmorphism.accentPrimary)
            .onChange((value: number) => {
              this.todoDuration = value;
            })
          
          Text(`${this.todoDuration}分钟`)
            .fontSize(FONT_SIZES.BODY_MEDIUM)
            .fontColor(this.currentTheme.textColor)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }

      // 按钮区域
      Row() {
        CommonButton({
          config: {
            text: STRINGS.CANCEL,
            type: 'secondary',
            onClick: () => {
              this.controller?.close();
            }
          }
        })
        .layoutWeight(1)
        .margin({ right: 8 })

        CommonButton({
          config: {
            text: STRINGS.CONFIRM,
            type: 'primary',
            onClick: () => {
              this.onConfirm(this.todoName, this.todoType, this.todoDuration);
              this.controller?.close();
            }
          }
        })
        .layoutWeight(1)
        .margin({ left: 8 })
      }
      .margin({ top: 24 })
    }
    .padding(UI_SIZES.DIALOG_PADDING)
    .backgroundColor(this.currentTheme.glassmorphism.surfaceMedium)
    .borderRadius(UI_SIZES.DIALOG_BORDER_RADIUS)
    .width(UI_SIZES.DIALOG_WIDTH)
    .shadow({
      radius: 16,
      color: this.currentTheme.glassmorphism.shadowDeep,
      offsetX: 0,
      offsetY: 8
    })
  }
}

/**
 * 待办事项列表组件
 */
@Component
export struct TodoListComponent {
  // 外部传入的回调函数
  @Prop callbacks: TodoListCallbacks;
  
  // 内部状态
  @State todos: TodoItem[] = [];
  @State isLoading: boolean = false;
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  @State showOperationMenu: boolean = false;
  @State selectedTodoId: number = -1;
  
  // 对话框控制器
  private addTodoDialogController: CustomDialogController | null = null;
  
  // 服务实例
  private apiService: ApiService = ApiService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();
  
  // 主题变化监听器
  private themeChangeListener = async () => {
    try {
      this.currentTheme = await this.themeService.getCurrentTheme();
      console.info('待办列表组件主题已更新:', this.currentTheme.name);
    } catch (error) {
      console.error('待办列表组件主题更新失败:', error);
    }
  };

  async aboutToAppear() {
    // 注册主题变化监听器
    this.themeService.addThemeChangeListener(this.themeChangeListener);
    
    // 加载当前主题
    await safeExecute(
      async () => {
        await this.themeService.loadThemePreference();
        this.currentTheme = await this.themeService.getCurrentTheme();
        console.info('待办列表组件加载主题成功:', this.currentTheme.name);
      },
      (error) => {
        console.error('待办列表组件加载主题失败:', error.message);
      },
      'TodoListComponent.aboutToAppear.loadTheme'
    );

    // 加载待办事项
    await this.loadTodos();
  }

  aboutToDisappear() {
    // 注销主题变化监听器
    this.themeService.removeThemeChangeListener(this.themeChangeListener);
  }

  /**
   * 加载待办事项列表
   */
  async loadTodos(): Promise<void> {
    this.isLoading = true;
    
    await safeExecute(
      async () => {
        console.info('开始加载简单待办事项列表');
        const apiTodos = await this.apiService.getTodoItems();
        console.info('后端返回的待办事项:', JSON.stringify(apiTodos));
        
        // 转换为前端TodoItem格式
        this.todos = apiTodos.map(apiTodo => ({
          id: apiTodo.id,
          title: apiTodo.title,
          type: apiTodo.type || '未分类',
          duration: apiTodo.duration || DURATION_CONSTANTS.DEFAULT_TODO_DURATION,
          isCompleted: apiTodo.isCompleted || false,
          createTime: apiTodo.createTime,
          updateTime: apiTodo.updateTime
        }));
        
        console.info('转换后的待办事项:', JSON.stringify(this.todos));
      },
      (error) => {
        console.error('加载待办事项失败:', error.message);
        this.callbacks.onError(`加载待办事项失败：${error.message}`);
      },
      'TodoListComponent.loadTodos'
    );
    
    this.isLoading = false;
  }

  /**
   * 显示添加待办对话框
   */
  async showAddTodoDialog(): Promise<void> {
    await safeExecute(
      async () => {
        // 预先获取当前主题，确保弹窗显示时主题已加载
        const currentTheme = await this.themeService.getCurrentTheme();
        console.info('准备打开添加待办弹窗，当前主题:', currentTheme.name);
        
        // 每次打开时重新创建，确保获取最新主题
        this.addTodoDialogController = new CustomDialogController({
          builder: AddTodoDialog({
            currentTheme: currentTheme,
            onConfirm: (name: string, type: string, duration: number) => {
              this.addNewTodo(name, type, duration);
            }
          }),
          autoCancel: true,
          alignment: DialogAlignment.Center,
          customStyle: true,
          maskColor: Color.Transparent
        });
        
        this.addTodoDialogController.open();
      },
      (error) => {
        console.error('打开添加待办弹窗失败:', error.message);
        this.callbacks.onError(`打开添加对话框失败：${error.message}`);
      },
      'TodoListComponent.showAddTodoDialog'
    );
  }

  /**
   * 添加新的待办事项
   */
  private async addNewTodo(name: string, type: string, duration: number): Promise<void> {
    if (!this.validateTodoInput(name, type, duration)) {
      return;
    }

    await safeExecute(
      async () => {
        console.info('添加新待办事项:', { name, type, duration });
        
        const request: TodoItemRequest = {
          title: name.trim(),
          type: type.trim(),
          duration: duration,
          isCompleted: false
        };
        
        const createdTodo = await this.apiService.createTodoItem(request);
        console.info('创建的待办事项:', JSON.stringify(createdTodo));
        
        // 转换为前端格式并添加到列表
        const newTodo: TodoItem = {
          id: createdTodo.id,
          title: createdTodo.title,
          type: createdTodo.type || '未分类',
          duration: createdTodo.duration || DURATION_CONSTANTS.DEFAULT_TODO_DURATION,
          isCompleted: createdTodo.isCompleted || false,
          createTime: createdTodo.createTime,
          updateTime: createdTodo.updateTime
        };
        
        this.todos.push(newTodo);
        this.callbacks.onTodoAdded(newTodo);
        
        promptAction.showToast({ message: '待办事项添加成功' });
      },
      (error) => {
        console.error('添加待办事项失败:', error.message);
        const errorMessage = `添加待办事项失败：${error.message}`;
        promptAction.showToast({ message: errorMessage });
        this.callbacks.onError(errorMessage);
      },
      'TodoListComponent.addNewTodo'
    );
  }

  /**
   * 验证待办事项输入
   */
  private validateTodoInput(name: string, type: string, duration: number): boolean {
    if (!name.trim()) {
      promptAction.showToast({ message: '请输入待办名称' });
      return false;
    }
    
    if (!type.trim()) {
      promptAction.showToast({ message: '请输入待办类型' });
      return false;
    }
    
    if (duration <= 0) {
      promptAction.showToast({ message: '请输入有效的时长' });
      return false;
    }
    
    return true;
  }

  /**
   * 切换待办事项状态
   */
  async toggleTodoStatus(todoId: number): Promise<void> {
    await safeExecute(
      async () => {
        const todo = this.todos.find(t => t.id === todoId);
        if (!todo) {
          throw new Error('待办事项不存在');
        }
        
        console.info('切换待办状态:', todoId, '原状态:', todo.isCompleted);
        
        const newStatus = !todo.isCompleted;
        await this.apiService.updateTodoItem(todoId, { isCompleted: newStatus });
        
        // 更新本地状态
        todo.isCompleted = newStatus;
        this.callbacks.onTodoUpdated(todo);
        
        if (newStatus) {
          this.callbacks.onTodoCompleted(todo);
        }
        
        promptAction.showToast({ 
          message: newStatus ? '待办事项已完成' : '待办事项已重新激活' 
        });
      },
      (error) => {
        console.error('切换待办状态失败:', error.message);
        const errorMessage = `更新待办状态失败：${error.message}`;
        promptAction.showToast({ message: errorMessage });
        this.callbacks.onError(errorMessage);
      },
      'TodoListComponent.toggleTodoStatus'
    );
  }

  /**
   * 删除待办事项
   */
  async deleteTodo(todoId: number): Promise<void> {
    await safeExecute(
      async () => {
        const todoIndex = this.todos.findIndex(t => t.id === todoId);
        if (todoIndex === -1) {
          throw new Error('待办事项不存在');
        }
        
        console.info('删除待办事项:', todoId);
        await this.apiService.deleteTodoItem(todoId);
        
        // 从本地列表中移除
        this.todos.splice(todoIndex, 1);
        this.callbacks.onTodoDeleted(todoId);
        
        promptAction.showToast({ message: '待办事项已删除' });
      },
      (error) => {
        console.error('删除待办事项失败:', error.message);
        const errorMessage = `删除待办事项失败：${error.message}`;
        promptAction.showToast({ message: errorMessage });
        this.callbacks.onError(errorMessage);
      },
      'TodoListComponent.deleteTodo'
    );
  }

  /**
   * 开始专注计时
   */
  private startFocusTimer(todo: TodoItem): void {
    const params: FocusTimerRouterParams = {
      title: todo.title,
      time: todo.duration * 60, // 转换为秒
      todoId: todo.id
    };
    
    router.pushUrl({
      url: 'pages/FocusTimer',
      params: params
    }).catch(error => {
      console.error('跳转到专注计时器失败:', error);
      promptAction.showToast({ message: '跳转失败，请稍后重试' });
    });
  }

  build() {
    Column() {
      // 头部区域
      Row() {
        Text('📝 待办事项')
          .fontSize(FONT_SIZES.TITLE_LARGE)
          .fontColor(this.currentTheme.textColor)
          .fontWeight(FontWeight.Bold)
          .textShadow({
            radius: 8,
            color: this.currentTheme.glassmorphism.accentPrimary + '50',
            offsetX: 0,
            offsetY: 0
          })
        
        Blank()
        
        // 添加按钮
        CommonButton({
          config: {
            text: '+ 添加',
            type: 'primary',
            size: 'small',
            backgroundColor: this.currentTheme.glassmorphism.accentPrimary + '30',
            borderColor: this.currentTheme.glassmorphism.accentPrimary,
            borderWidth: 1,
            fontColor: this.currentTheme.glassmorphism.accentPrimary,
            onClick: () => this.showAddTodoDialog()
          }
        })
        .width(80)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })

      // 待办事项列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(this.currentTheme.glassmorphism.accentPrimary)
          
          Text(STRINGS.LOADING)
            .fontSize(FONT_SIZES.BODY_MEDIUM)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.6)
            .margin({ top: 16 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.todos.length === 0) {
        Column() {
          Text('📋')
            .fontSize(48)
            .margin({ bottom: 16 })
          
          Text(STRINGS.EMPTY_TODO_LIST)
            .fontSize(FONT_SIZES.BODY_LARGE)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.6)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.todos, (todo: TodoItem) => {
            ListItem() {
              ThemeAwareGlassCard({ level: 'light' }) {
                Row() {
                  // 状态指示器
                  Text(todo.isCompleted ? '✅' : '⭕')
                    .fontSize(FONT_SIZES.TITLE_MEDIUM)
                    .margin({ right: 12 })
                    .onClick(() => {
                      this.toggleTodoStatus(todo.id);
                    })
                  
                  // 待办信息
                  Column() {
                    Text(todo.title)
                      .fontSize(FONT_SIZES.BODY_LARGE)
                      .fontColor(this.currentTheme.textColor)
                      .fontWeight(FontWeight.Medium)
                      .opacity(todo.isCompleted ? 0.5 : 1.0)
                      .textDecoration({ type: todo.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    
                    Row() {
                      Text(`🏷️ ${todo.type}`)
                        .fontSize(FONT_SIZES.BODY_SMALL)
                        .fontColor(this.currentTheme.textColor)
                        .opacity(0.6)
                      
                      Text(`⏱️ ${todo.duration}分钟`)
                        .fontSize(FONT_SIZES.BODY_SMALL)
                        .fontColor(this.currentTheme.textColor)
                        .opacity(0.6)
                        .margin({ left: 12 })
                    }
                    .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  
                  // 操作按钮
                  Row({ space: 8 }) {
                    if (!todo.isCompleted) {
                      // 开始专注按钮
                      Text('▶️')
                        .fontSize(FONT_SIZES.BODY_LARGE)
                        .fontColor(this.currentTheme.glassmorphism.accentPrimary)
                        .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
                        .borderRadius(16)
                        .width(32)
                        .height(32)
                        .textAlign(TextAlign.Center)
                        .onClick(() => {
                          this.startFocusTimer(todo);
                        })
                    }
                    
                    // 删除按钮
                    Text('🗑️')
                      .fontSize(FONT_SIZES.BODY_LARGE)
                      .fontColor(this.currentTheme.glassmorphism.accentSecondary)
                      .backgroundColor(this.currentTheme.glassmorphism.surfaceLight)
                      .borderRadius(16)
                      .width(32)
                      .height(32)
                      .textAlign(TextAlign.Center)
                      .onClick(() => {
                        this.deleteTodo(todo.id);
                      })
                  }
                }
                .alignItems(VerticalAlign.Center)
                .padding(16)
              }
              .margin({ left: 16, right: 16, bottom: 8 })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 待办事项列表组件工具类
 */
export class TodoListUtils {
  /**
   * 创建默认的待办事项回调
   */
  static createDefaultCallbacks(
    onTodoAdded?: (todo: TodoItem) => void,
    onTodoUpdated?: (todo: TodoItem) => void,
    onTodoDeleted?: (todoId: number) => void,
    onTodoCompleted?: (todo: TodoItem) => void,
    onError?: (error: string) => void
  ): TodoListCallbacks {
    return {
      onTodoAdded: onTodoAdded || ((todo: TodoItem) => {
        console.info('待办事项已添加:', todo.title);
      }),
      onTodoUpdated: onTodoUpdated || ((todo: TodoItem) => {
        console.info('待办事项已更新:', todo.title);
      }),
      onTodoDeleted: onTodoDeleted || ((todoId: number) => {
        console.info('待办事项已删除:', todoId);
      }),
      onTodoCompleted: onTodoCompleted || ((todo: TodoItem) => {
        console.info('待办事项已完成:', todo.title);
      }),
      onError: onError || ((error: string) => {
        console.error('待办事项操作失败:', error);
      })
    };
  }

  /**
   * 过滤待办事项
   */
  static filterTodos(todos: TodoItem[], filter: 'all' | 'active' | 'completed'): TodoItem[] {
    switch (filter) {
      case 'active':
        return todos.filter(todo => !todo.isCompleted);
      case 'completed':
        return todos.filter(todo => todo.isCompleted);
      default:
        return todos;
    }
  }

  /**
   * 排序待办事项
   */
  static sortTodos(todos: TodoItem[], sortBy: 'createTime' | 'title' | 'duration', order: 'asc' | 'desc' = 'desc'): TodoItem[] {
    return [...todos].sort((a, b) => {
      let comparison = 0;
      
      switch (sortBy) {
        case 'title':
          comparison = a.title.localeCompare(b.title);
          break;
        case 'duration':
          comparison = a.duration - b.duration;
          break;
        case 'createTime':
        default:
          comparison = new Date(a.createTime || '').getTime() - new Date(b.createTime || '').getTime();
          break;
      }
      
      return order === 'asc' ? comparison : -comparison;
    });
  }
} 