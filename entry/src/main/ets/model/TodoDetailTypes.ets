// TodoDetail页面专用的类型和类定义

/**
 * 单个具体待办事项
 */
export class ActualTodoItem {
  id: string;
  title: string;
  durationMinutes: number;
  isCompleted: boolean = false;

  constructor(id: string, title: string, durationMinutes: number, isCompleted: boolean = false) {
    this.id = id;
    this.title = title;
    this.durationMinutes = durationMinutes;
    this.isCompleted = isCompleted;
  }
}

/**
 * 本地待办合集类
 */
export class LocalTodoCollection {
  id: string;
  collectionTitle: string;
  subTasks: ActualTodoItem[];
  isExpanded: boolean = false;
  currentTaskIndex: number = -1;
  isSequenceActive: boolean = false;

  constructor(id: string, collectionTitle: string, subTasks: ActualTodoItem[] = [], isExpanded: boolean = false) {
    this.id = id;
    this.collectionTitle = collectionTitle;
    this.subTasks = subTasks;
    this.isExpanded = isExpanded;
    this.currentTaskIndex = -1;
    this.isSequenceActive = false;
    
    // 为默认合集添加示例数据
    if (subTasks.length === 0 && id.startsWith("default")) {
      this.subTasks.push(new ActualTodoItem(Date.now().toString() + "-s1", "子任务A", 5));
      this.subTasks.push(new ActualTodoItem(Date.now().toString() + "-s2", "子任务B", 10));
    }
  }
} 