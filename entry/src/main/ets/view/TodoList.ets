import { TodoGroup, TodoItem, mockTodoGroups } from '../model/TodoModel';

@Component
export struct TodoList {
  @State todoGroups: TodoGroup[] = [];
  @State currentTodo: TodoItem | null = null;
  @State remainingTime: number = 0;
  private timer: number = -1;

  aboutToAppear() {
    // 初始化数据
    this.todoGroups = mockTodoGroups;
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  startTodo(todo: TodoItem) {
    if (this.currentTodo) {
      return; // 如果已经有正在进行的待办，则不启动新的
    }

    this.currentTodo = todo;
    this.remainingTime = todo.duration;
    todo.startTime = Date.now();

    // 启动定时器
    this.timer = setInterval(() => {
      if (this.remainingTime > 0) {
        this.remainingTime--;
      } else {
        // 当前待办完成
        if (this.currentTodo) {
          this.currentTodo.isCompleted = true;
          this.currentTodo = null;
          clearInterval(this.timer);
          this.timer = -1;

          // 查找并启动下一个待办
          this.startNextTodo();
        }
      }
    }, 1000);
  }

  startNextTodo() {
    for (let group of this.todoGroups) {
      for (let todo of group.todos) {
        if (!todo.isCompleted) {
          this.startTodo(todo);
          return;
        }
      }
    }
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      ForEach(this.todoGroups, (group: TodoGroup) => {
        Column() {
          // 分组标题
          Row() {
            Text(group.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Image(group.isExpanded ? '/common/images/arrow_up.png' : '/common/images/arrow_down.png')
              .width(24)
              .height(24)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F5F5F5')
          .onClick(() => {
            group.isExpanded = !group.isExpanded;
          })

          // 待办列表
          if (group.isExpanded) {
            ForEach(group.todos, (todo: TodoItem) => {
              Column() {
                Row() {
                  Column() {
                    Text(todo.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    Text(todo.description)
                      .fontSize(14)
                      .margin({ top: 4 })
                      .opacity(0.6)
                  }
                  .layoutWeight(1)

                  if (this.currentTodo?.id === todo.id) {
                    Text(this.formatTime(this.remainingTime))
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#007DFF')
                  } else if (todo.isCompleted) {
                    Text('已完成')
                      .fontSize(14)
                      .fontColor('#4CAF50')
                  } else {
                    Button('开始')
                      .onClick(() => this.startTodo(todo))
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(8)
                .margin({ top: 8 })
              }
            })
          }
        }
        .width('100%')
        .margin({ bottom: 16 })
      })
    }
    .width('100%')
    .padding(16)
  }
} 