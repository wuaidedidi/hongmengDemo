// 通用类型定义文件 - 统一管理所有接口类型

// ==================== 通用错误类型 ====================
export interface CommonError {
  message: string;
  code?: string | number;
  name?: string;
  stack?: string;
  cause?: string;
  detail?: string;
}

export interface ErrorInfo {
  message: string;
  code?: number;
  details?: string;
}

// ==================== 路由相关类型 ====================
export interface BaseRouterParams {
  action?: string;
  todoId?: string | number;
  title?: string;
  message?: string;
  status?: string;
  type?: string;
}

export interface FocusTimerRouterParams extends BaseRouterParams {
  taskTitle?: string;
  title?: string;
  time?: number; // 秒
  duration?: number; // 分钟，用于向后兼容
  isSequence?: boolean;
  collectionId?: string | number;
  subTaskId?: string | number;
  currentSubTaskIndex?: number;
  totalSubTasksInCollection?: number;
  todoId?: string | number;
}

export interface TodoOperationParams extends BaseRouterParams {
  todoId: string | number;
  todoTitle?: string;
}

// ==================== UI相关类型 ====================
export interface DialogOffset {
  dx: number;
  dy: number;
}

export interface DialogData {
  title: string;
  description?: string;
}

export interface PermissionItem {
  name: string;
  granted: boolean;
}

// ==================== 系统设置相关类型 ====================
export interface SettingsWantOptions {
  action?: string;
  bundleName?: string;
  abilityName?: string;
  uri?: string;
  parameters?: Record<string, string | number | boolean | Array<string | number | boolean>>;
}

export interface SystemWant {
  action?: string;
  bundleName?: string;
  abilityName?: string;
  uri?: string;
  parameters?: Record<string, string | number | boolean | Array<string | number | boolean>>;
}

export interface ContextLike {
  applicationInfo?: Record<string, string>;
  startAbility: Function;
}

// ==================== 滑动操作相关类型 ====================
export interface SwipeActionBuilder {
  builder: () => void;
  actionAreaDistance: number;
  onAction: () => void;
}

export interface SwipeActionOptions {
  end: SwipeActionBuilder;
}

// ==================== 音效相关类型 ====================
export interface SoundOption {
  name: string;
  file: string;
  icon: string;
}

// ==================== 时长选项类型 ====================
export interface DurationOption {
  label: string;
  minutes: number;
  icon: string;
  description: string;
}

// ==================== 菜单项类型 ====================
export interface MenuItem {
  icon: string;
  title: string;
  onClick: () => void;
}

// ==================== 主题预览类型 ====================
export interface ThemePreviewColors {
  primary: string;
  secondary: string;
  accent: string;
}

export interface ThemePreviewStyle {
  backgroundColor: string;
  borderColor: string;
  shadowColor: string;
}

// ==================== 工具方法类型 ====================
export type RouterParamsObject = Record<string, string | number | boolean>;

// ==================== 任务相关扩展类型 ====================
export interface TaskLogInfo {
  id: number;
  title: string;
  completed?: boolean;
  index?: number;
}

export interface NextTaskItem {
  id: number;
  title: string;
  isCompleted: boolean;
  orderIndex: number;
  collectionId: number;
  createTime: string;
}

// ==================== TodoDetail页面相关类型 ====================

/**
 * TodoDetail路由参数接口 (当从FocusTimer返回时)
 */
export interface TodoDetailRouterParams extends BaseRouterParams {
  sequenceAction?: string; // e.g., 'taskCompleted', 'sequenceAborted'
  collectionId?: string | number;
  subTaskId?: string | number; // 记录完成或中止的子任务ID
  completedSubTaskIndex?: string | number; // 兼容旧的参数名
  currentSubTaskIndexCompleted?: string; // 兼容旧的参数名
  allSubTasksInCollectionCompleted?: string; // 兼容旧的参数名
}

/**
 * TodoItem界面显示所需的类型
 */
export interface TodoItemDisplay {
  title: string;
  description: string;
  isImportant: boolean;
  isUrgent: boolean;
  status: string; // 使用string而非TodoStatus以避免循环依赖
}

/**
 * 路由错误类型
 */
export interface RouterError {
  message: string;
}

// ==================== FocusTimer 相关类型 ====================
export interface FocusCompletionParams {
  action?: 'focusCompleted';
  sequenceAction?: 'taskCompleted' | 'sequenceAborted' | 'sequenceCompleted';
  collectionId?: string;
  subTaskId?: string;
  todoId?: string | number;
  currentSubTaskIndex?: number;
}

// ==================== Index页面路由参数类型 ====================
export interface IndexRouterParams extends BaseRouterParams {
  initialTab?: number; // 用于设置初始Tab索引
  todoId?: string | number; // 待办事项ID
} 