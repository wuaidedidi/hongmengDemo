/**
 * 待办事项状态
 */
export enum TodoStatus {
  TODO = 'TODO',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED'
}

/**
 * 单个待办事项
 */
export interface TodoItem {
  id: string;
  title: string;
  description?: string;
  status: TodoStatus;
  createTime: number;
  completedTime?: number;
  focusTime?: number; // 专注时间（分钟）
  isImportant?: boolean;
  isUrgent?: boolean;
}

/**
 * 待办集合
 */
export interface TodoCollection {
  id: string;
  title: string;
  description?: string;
  createTime: number;
  updateTime: number;
  color?: string; // 集合的显示颜色
  icon?: string; // 集合的图标
  isExpanded?: boolean; // UI 状态：是否展开
  items: TodoItem[];
  totalCount: number;
  completedCount: number;
}

/**
 * 统计数据
 */
export interface Statistics {
  totalTodos: number;
  completedTodos: number;
  totalFocusTime: number;
  todayFocusTime: number;
  weeklyFocusTime: number;
  monthlyFocusTime: number;
} 