export interface TodoItem {
  id: string;
  title: string;
  description: string;
  duration: number; // 持续时间（秒）
  isCompleted: boolean;
  startTime?: number; // 开始时间戳
}

export interface TodoGroup {
  id: string;
  title: string;
  isExpanded: boolean;
  todos: TodoItem[];
}

// 模拟数据
export const mockTodoGroups: TodoGroup[] = [
  {
    id: '1',
    title: '工作事项',
    isExpanded: false,
    todos: [
      {
        id: '1-1',
        title: '完成项目文档',
        description: '编写项目需求文档和设计文档',
        duration: 1800, // 30分钟
        isCompleted: false
      },
      {
        id: '1-2',
        title: '代码审查',
        description: '审查团队成员的代码提交',
        duration: 1200, // 20分钟
        isCompleted: false
      }
    ]
  },
  {
    id: '2',
    title: '学习计划',
    isExpanded: false,
    todos: [
      {
        id: '2-1',
        title: '学习ArkTS',
        description: '学习ArkTS的基础语法和组件使用',
        duration: 3600, // 1小时
        isCompleted: false
      },
      {
        id: '2-2',
        title: '练习编程',
        description: '完成编程练习题',
        duration: 2400, // 40分钟
        isCompleted: false
      }
    ]
  }
]; 