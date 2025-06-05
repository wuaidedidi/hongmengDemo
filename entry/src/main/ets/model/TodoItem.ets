import { ApiService } from '../services/ApiService';

export class TodoItem {
  id: number;
  title: string;
  type: string;
  duration: number;
  isCompleted: boolean;
  private apiService: ApiService = ApiService.getInstance();

  constructor(id: number, title: string, type: string, duration: number, isCompleted: boolean = false) {
    this.id = id;
    this.title = title;
    this.type = type;
    this.duration = duration;
    this.isCompleted = isCompleted;
  }

  formatDuration(): string {
    return `${this.duration}分钟`;
  }

  async toggleComplete(): Promise<void> {
    try {
      this.isCompleted = !this.isCompleted;
      // 这里可以添加与后端同步的逻辑
      // 例如：await this.apiService.updateTodoStatus(this.id, this.isCompleted);
    } catch (error) {
      console.error('更新待办状态失败:', error);
      // 如果更新失败，恢复状态
      this.isCompleted = !this.isCompleted;
      throw error;
    }
  }

  async delete(): Promise<void> {
    try {
      // 这里可以添加与后端同步的删除逻辑
      // 例如：await this.apiService.deleteTodo(this.id);
    } catch (error) {
      console.error('删除待办失败:', error);
      throw error;
    }
  }

  static fromJson(json: any): TodoItem {
    return new TodoItem(
      json.id,
      json.title,
      json.type,
      json.duration,
      json.isCompleted
    );
  }

  toJson(): any {
    return {
      id: this.id,
      title: this.title,
      type: this.type,
      duration: this.duration,
      isCompleted: this.isCompleted
    };
  }
} 