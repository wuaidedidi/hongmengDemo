import { TodoCollection, TodoItem, TodoStatus } from './TodoTypes';

// 定义统计数据的接口
interface Statistics {
  totalTodos: number;
  completedTodos: number;
  totalFocusTime: number;
  todayFocusTime: number;
  weeklyFocusTime: number;
  monthlyFocusTime: number;
}

// 生成随机ID
function generateId(): string {
  return Math.random().toString(36).substring(2, 15);
}

// 创建示例待办事项
function createMockTodoItem(title: string, status: TodoStatus = TodoStatus.TODO): TodoItem {
  const todoItem: TodoItem = {
    id: generateId(),
    title,
    status,
    createTime: Date.now(),
    completedTime: status === TodoStatus.COMPLETED ? Date.now() : undefined,
    focusTime: Math.floor(Math.random() * 120),
    isImportant: Math.random() > 0.5,
    isUrgent: Math.random() > 0.7
  };
  return todoItem;
}

// 创建示例待办集合
function createMockCollection(title: string, items: TodoItem[]): TodoCollection {
  const collection: TodoCollection = {
    id: generateId(),
    title,
    createTime: Date.now(),
    updateTime: Date.now(),
    items,
    totalCount: items.length,
    completedCount: items.filter(item => item.status === TodoStatus.COMPLETED).length,
    color: `#${Math.floor(Math.random()*16777215).toString(16)}`,
    icon: '📝',
    isExpanded: false
  };
  return collection;
}

// 示例数据
export const mockCollections: TodoCollection[] = [
  createMockCollection('工作项目', [
    createMockTodoItem('完成项目文档'),
    createMockTodoItem('代码审查', TodoStatus.IN_PROGRESS),
    createMockTodoItem('修复BUG', TodoStatus.COMPLETED),
    createMockTodoItem('团队会议'),
    createMockTodoItem('性能优化')
  ]),
  createMockCollection('个人学习', [
    createMockTodoItem('学习HarmonyOS'),
    createMockTodoItem('看技术书籍'),
    createMockTodoItem('练习算法题', TodoStatus.IN_PROGRESS),
    createMockTodoItem('写技术博客')
  ]),
  createMockCollection('生活安排', [
    createMockTodoItem('健身'),
    createMockTodoItem('买菜', TodoStatus.COMPLETED),
    createMockTodoItem('整理房间'),
    createMockTodoItem('看电影')
  ]),
  createMockCollection('阅读清单', [
    createMockTodoItem('《深入理解计算机系统》'),
    createMockTodoItem('《算法导论》', TodoStatus.IN_PROGRESS),
    createMockTodoItem('《设计模式》'),
    createMockTodoItem('《代码大全》', TodoStatus.COMPLETED)
  ])
];

// 示例统计数据
export const mockStatistics: Statistics = {
  totalTodos: mockCollections.reduce((sum, collection) => sum + collection.totalCount, 0),
  completedTodos: mockCollections.reduce((sum, collection) => sum + collection.completedCount, 0),
  totalFocusTime: 3600,
  todayFocusTime: 120,
  weeklyFocusTime: 840,
  monthlyFocusTime: 3600
}; 