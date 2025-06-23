/**
 * 📝 待办事项数据模型 (TodoItem)
 * 
 * 这是应用的核心数据模型，代表一个待办事项
 * 包含了待办事项的所有属性和相关操作方法
 * 
 * 🔥 核心功能：
 * - 待办事项的基本信息管理
 * - 完成状态切换
 * - 数据持久化操作
 * - JSON序列化/反序列化
 */

import { ApiService } from '../services/ApiService';

/**
 * 待办事项JSON接口
 * 用于数据的序列化和反序列化
 */
interface TodoItemJson {
  id: number;        // 待办事项唯一标识
  title: string;     // 待办事项标题
  type: string;      // 待办事项分类
  duration: number;  // 预计完成时长（分钟）
  isCompleted: boolean; // 完成状态
}

/**
 * 📋 待办事项类
 * 
 * 这个类封装了待办事项的所有属性和行为
 * 采用面向对象的设计，便于维护和扩展
 */
export class TodoItem {
  /** 待办事项唯一标识符 */
  id: number;
  
  /** 待办事项标题 */
  title: string;
  
  /** 待办事项分类（如：工作、学习、生活等） */
  type: string;
  
  /** 预计完成时长（单位：分钟） */
  duration: number;
  
  /** 完成状态标识 */
  isCompleted: boolean;
  
  /** API服务实例，用于与后端交互 */
  private apiService: ApiService = ApiService.getInstance();

  /**
   * 构造函数 - 创建待办事项实例
   * 
   * @param id - 待办事项ID
   * @param title - 待办事项标题
   * @param type - 待办事项分类
   * @param duration - 预计完成时长（分钟）
   * @param isCompleted - 完成状态，默认为false
   */
  constructor(id: number, title: string, type: string, duration: number, isCompleted: boolean = false) {
    this.id = id;
    this.title = title;
    this.type = type;
    this.duration = duration;
    this.isCompleted = isCompleted;
  }

  /**
   * 🕐 格式化时长显示
   * 
   * 将数字时长转换为用户友好的文本格式
   * 
   * @returns 格式化后的时长字符串，如 "25分钟"
   */
  formatDuration(): string {
    return `${this.duration}分钟`;
  }

  /**
   * ✅ 切换完成状态
   * 
   * 切换待办事项的完成状态，并同步到后端
   * 
   * 🔄 操作流程：
   * 1. 先更新本地状态
   * 2. 调用API同步到后端
   * 3. 如果失败则回滚本地状态
   * 
   * @throws Error 当状态更新失败时抛出异常
   */
  async toggleComplete(): Promise<void> {
    try {
      // 先更新本地状态
      this.isCompleted = !this.isCompleted;
      
      // TODO: 与后端同步状态
      // 这里可以添加与后端同步的逻辑
      // 例如：await this.apiService.updateTodoStatus(this.id, this.isCompleted);
      
      console.info(`✅ 待办事项状态已更新: ${this.title} -> ${this.isCompleted ? '已完成' : '未完成'}`);
    } catch (error) {
      console.error('❌ 更新待办状态失败:', error);
      
      // 如果更新失败，回滚本地状态
      this.isCompleted = !this.isCompleted;
      
      // 统一错误处理
      const errorToThrow = error instanceof Error ? error : new Error(String(error));
      throw errorToThrow;
    }
  }

  /**
   * 🗑️ 删除待办事项
   * 
   * 删除当前待办事项，并从后端移除
   * 
   * @throws Error 当删除失败时抛出异常
   */
  async delete(): Promise<void> {
    try {
      // TODO: 与后端同步删除操作
      // 这里可以添加与后端同步的删除逻辑
      // 例如：await this.apiService.deleteTodo(this.id);
      
      console.info(`🗑️ 待办事项已删除: ${this.title}`);
    } catch (error) {
      console.error('❌ 删除待办失败:', error);
      
      // 统一错误处理
      const errorToThrow = error instanceof Error ? error : new Error(String(error));
      throw errorToThrow;
    }
  }

  /**
   * 📥 从JSON创建TodoItem实例
   * 
   * 静态工厂方法，用于从JSON数据创建TodoItem对象
   * 常用于API响应数据的转换
   * 
   * @param json - 包含待办事项数据的JSON对象
   * @returns 新创建的TodoItem实例
   */
  static fromJson(json: TodoItemJson): TodoItem {
    return new TodoItem(
      json.id,
      json.title,
      json.type,
      json.duration,
      json.isCompleted
    );
  }

  /**
   * 📤 转换为JSON格式
   * 
   * 将TodoItem实例转换为JSON对象
   * 常用于API请求数据的准备
   * 
   * @returns 包含待办事项数据的JSON对象
   */
  toJson(): TodoItemJson {
    return {
      id: this.id,
      title: this.title,
      type: this.type,
      duration: this.duration,
      isCompleted: this.isCompleted
    };
  }
} 