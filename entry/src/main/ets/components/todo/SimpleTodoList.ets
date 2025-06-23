// 简化的待办事项列表组件

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ApiService, TodoItemRequest } from '../../services/ApiService';
import { TodoItem } from '../../model/TodoItem';
import { ThemeService, ThemeConfig, DEFAULT_THEME_CONFIG } from '../../services/ThemeService';
import { ThemeAwareGlassCard } from '../../utils/GlassmorphismStyles';
import { safeExecute } from '../../utils/ErrorHandler';
import { ErrorInfo } from '../../types/CommonTypes';
import { FONT_SIZES, DURATIONS } from '../../constants/AppConstants';
import { FocusTimerRouterParams } from '../../types/CommonTypes';

/**
 * 简化的待办事项列表组件
 */
@Component
export struct SimpleTodoList {
  @State todos: TodoItem[] = [];
  @State isLoading: boolean = false;
  @State currentTheme: ThemeConfig = DEFAULT_THEME_CONFIG;
  
  private apiService: ApiService = ApiService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();

  async aboutToAppear() {
    this.currentTheme = await this.themeService.getCurrentTheme();
    await this.loadTodos();
  }

  /**
   * 加载待办事项
   */
  async loadTodos(): Promise<void> {
    this.isLoading = true;
    
    await safeExecute(
      async () => {
        const apiTodos = await this.apiService.getTodoItems();
        this.todos = apiTodos.map(apiTodo => {
          return new TodoItem(
            apiTodo.id,
            apiTodo.title,
            apiTodo.type || '未分类',
            apiTodo.duration || DURATIONS.FOCUS_DEFAULT,
            apiTodo.completed || false
          );
        });
      },
      (error: ErrorInfo) => {
        console.error('加载待办事项失败:', error.message);
        promptAction.showToast({ message: '加载失败' });
      }
    );
    
    this.isLoading = false;
  }

  /**
   * 切换完成状态
   */
  async toggleTodoStatus(todoId: number): Promise<void> {
    await safeExecute(
      async () => {
        const updatedTodo = await this.apiService.toggleTodoItemStatus(todoId);
        
        // 更新本地状态
        const todo = this.todos.find(t => t.id === todoId);
        if (todo) {
          todo.isCompleted = updatedTodo.completed;
          promptAction.showToast({ 
            message: updatedTodo.completed ? '已完成' : '已重新激活' 
          });
        }
      },
      (error: ErrorInfo) => {
        console.error('更新状态失败:', error.message);
        promptAction.showToast({ message: '状态更新失败' });
      }
    );
  }

  /**
   * 删除待办
   */
  async deleteTodo(todoId: number): Promise<void> {
    await safeExecute(
      async () => {
        await this.apiService.deleteTodoItem(todoId);
        const index = this.todos.findIndex(t => t.id === todoId);
        if (index > -1) {
          this.todos.splice(index, 1);
        }
        promptAction.showToast({ message: '已删除' });
      },
      (error: ErrorInfo) => {
        console.error('删除失败:', error.message);
        promptAction.showToast({ message: '删除失败' });
      }
    );
  }

  /**
   * 开始专注
   */
  private startFocus(todo: TodoItem): void {
    const params: FocusTimerRouterParams = {
      title: todo.title,
      time: todo.duration * 60,
      todoId: todo.id
    };
    
    router.pushUrl({
      url: 'pages/FocusTimer',
      params: params
    });
  }

  build() {
    Column() {
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
          Text('加载中...')
            .fontSize(FONT_SIZES.BODY_MEDIUM)
            .fontColor(this.currentTheme.textColor)
        }
        .justifyContent(FlexAlign.Center)
        .height(100)
      } else if (this.todos.length === 0) {
        Column() {
          Text('📋')
            .fontSize(32)
          Text('暂无待办事项')
            .fontSize(FONT_SIZES.BODY_MEDIUM)
            .fontColor(this.currentTheme.textColor)
            .opacity(0.6)
        }
        .justifyContent(FlexAlign.Center)
        .height(100)
      } else {
        List() {
          ForEach(this.todos, (todo: TodoItem) => {
            ListItem() {
              ThemeAwareGlassCard({ level: 'light' }) {
                Row() {
                  Text(todo.isCompleted ? '✅' : '⭕')
                    .fontSize(FONT_SIZES.TITLE_MEDIUM)
                    .onClick(() => this.toggleTodoStatus(todo.id))
                  
                  Column() {
                    Text(todo.title)
                      .fontSize(FONT_SIZES.BODY_LARGE)
                      .fontColor(this.currentTheme.textColor)
                      .opacity(todo.isCompleted ? 0.5 : 1.0)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    
                    Text(`${todo.type} • ${todo.duration}分钟`)
                      .fontSize(FONT_SIZES.BODY_SMALL)
                      .fontColor(this.currentTheme.textColor)
                      .opacity(0.6)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  
                  Row({ space: 8 }) {
                    if (!todo.isCompleted) {
                      Text('▶️')
                        .fontSize(FONT_SIZES.BODY_MEDIUM)
                        .onClick(() => this.startFocus(todo))
                    }
                    
                    Text('🗑️')
                      .fontSize(FONT_SIZES.BODY_MEDIUM)
                      .onClick(() => this.deleteTodo(todo.id))
                  }
                }
                .alignItems(VerticalAlign.Center)
                .padding(12)
              }
            }
          })
        }
        .width('100%')
      }
    }
    .width('100%')
  }
} 