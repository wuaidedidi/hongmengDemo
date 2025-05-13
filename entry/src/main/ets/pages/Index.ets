import router from '@ohos.router';
// Index.ets

// 待办项数据类型定义
class TodoItem {
  id: number
  title: string
  type: string
  createTime: string
  isCompleted: boolean
  focusCount: number = 0
  focusDuration: number = 0
  targetDate: string = '2025-05-14'
  remainDays: number = 1

  constructor(id: number, title: string, type: string) {
    this.id = id
    this.title = title
    this.type = type
    this.isCompleted = false
    
    // 设置创建时间
    const now = new Date()
    this.createTime = `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日`
  }
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  // 使用一个半透明的粉色背景色
  @State bgColor: string = 'rgba(255, 192, 203, 0.15)';
  @State isDialogShow: boolean = false;
  @State todoName: string = '';
  @State todoType: string = '白兔钟'; // 默认类型
  @State isClockInMenuShow: boolean = false; // 打卡菜单是否显示
  @State isClockInStatsShow: boolean = false; // 专注时长打卡统计是否显示
  @State isPermissionDialogShow: boolean = false; // 权限设置对话框是否显示
  @State todoItems: TodoItem[] = [
    new TodoItem(1, '大白猪', '白兔钟'),
    new TodoItem(2, '劳逸结合', '定目标'),
    new TodoItem(3, '学习计划', '养习惯'),
    new TodoItem(4, '工作任务', '定目标')
  ]; // 待办项列表
  @State selectedTodoId: number = -1; // 当前选中的待办项ID
  @State isOperationMenuShow: boolean = false; // 操作菜单是否显示
  private nextId: number = 5; // 下一个待办项ID

  aboutToAppear() {
    // 检查是否有从其他页面返回的参数
    const params = router.getParams();
    if (params) {
      const paramsObj = params as Record<string, string | number>;
      if (paramsObj.action === 'delete' && paramsObj.todoId !== undefined) {
        const todoId = paramsObj.todoId as number;
        const index = this.todoItems.findIndex(item => item.id === todoId);
        if (index >= 0) {
          this.todoItems.splice(index, 1);
        }
      }
    }
  }

  build() {
    Stack() {
      // 整页背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.bgColor)
      
      Column() {
        // 顶部标题栏
        Row() {
          Text('待办')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          
          Blank()
          
          Row({ space: 16 }) {
            Row() {
              Text('必开')
                .fontSize(14)
                .fontColor('#FFFFFF')
              Text('权限')
                .fontSize(14)
                .fontColor('#FFFFFF')
            }
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .borderRadius(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ right: 4 })
            .onClick(() => {
              this.isPermissionDialogShow = true;
            })
            
            Text('✓')
              .fontSize(24)
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.isClockInMenuShow = true;
              })
            Text('+')
              .fontSize(24)
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.isDialogShow = true;
              })
            Text('≡').fontSize(24).fontColor('#FFFFFF')
          }
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .linearGradient({
          angle: 90,
          colors: [['#8A2BE2', 0.0], ['#FF1493', 1.0]]
        })
        
        // 任务列表部分
        Column() {
          // 列表卡片
          Column({ space: 16 }) {
            // 循环渲染待办项
            ForEach(this.todoItems, (item: TodoItem) => {
              Row() {
                Column() {
                  Text(item.title)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#222222')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                
                if (item.type === '白兔钟') {
                  Text('📊').fontSize(24).margin({ right: 8 })
                  Text('⚙️').fontSize(24).margin({ right: 8 })
                  Text('➕').fontSize(24)
                } else {
                  Text('⏱️').fontSize(24).margin({ right: 8 })
                  Text('✏️').fontSize(24).margin({ right: 8 })
                  Text('✓').fontSize(24)
                }
              }
              .height(60)
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
              .margin({ top: 8, left: 8, right: 8 })
              .gesture(
                LongPressGesture()
                  .onAction(() => {
                    router.pushUrl({
                      url: 'pages/TodoOperation',
                      params: {
                        todoId: item.id
                      }
                    });
                  })
              )
            })
          }
          .width('100%')
          
          // 浮动按钮提示
          Row() {
            Text('双击编辑 AI 组件')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
          .backgroundColor('rgba(138, 43, 226, 0.8)')
          .borderRadius(24)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .position({ x: '30%', y: '50%' })
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
        
        // 底部导航栏
        Row() {
          Column() {
            Text('📅').fontSize(24)
            Text('待办').fontSize(12).margin({ top: 4 }).fontColor('#8A2BE2')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          
          Column() {
            Text('📝').fontSize(24)
            Text('待办事项').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.push({ url: 'pages/TodoDetail' });
          })
          
          Column() {
            Text('🔒').fontSize(24)
            Text('锁机').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.push({ url: 'pages/LockPage' });
          })
          
          Column() {
            Text('📊').fontSize(24)
            Text('统计数据').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.push({ url: 'pages/StatisticsPage' });
          })
          
          Column() {
            Text('👤').fontSize(24)
            Text('我的').fontSize(12).margin({ top: 4 })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.push({ url: 'pages/ProfilePage' });
          })
        }
        .height(56)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 1 }, color: { top: '#E0E0E0' } })
      }
      .width('100%')
      .height('100%')
      
      // 添加待办弹窗
      if (this.isDialogShow) {
        Column() {
          Column() {
            // 弹窗标题
            Text('添加待办')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 16, bottom: 20 })
            
            // 输入框
            TextInput({ placeholder: '请输入待办名称' })
              .width('90%')
              .height(50)
              .fontSize(16)
              .placeholderFont({ size: 16 })
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .margin({ bottom: 20 })
              .onChange((value: string) => {
                this.todoName = value;
              })
            
            // 第一行按钮
            Row({ space: 12 }) {
              Button('白兔钟')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor(this.todoType === '白兔钟' ? '#8A2BE2' : '#F5F5F5')
                .fontColor(this.todoType === '白兔钟' ? '#FFFFFF' : '#333333')
                .onClick(() => {
                  this.todoType = '白兔钟';
                })
              
              Button('定目标')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor(this.todoType === '定目标' ? '#8A2BE2' : '#F5F5F5')
                .fontColor(this.todoType === '定目标' ? '#FFFFFF' : '#333333')
                .onClick(() => {
                  this.todoType = '定目标';
                })
              
              Button('养习惯')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor(this.todoType === '养习惯' ? '#8A2BE2' : '#F5F5F5')
                .fontColor(this.todoType === '养习惯' ? '#FFFFFF' : '#333333')
                .onClick(() => {
                  this.todoType = '养习惯';
                })
            }
            .width('90%')
            .margin({ bottom: 12 })
            
            // 第二行按钮
            Row({ space: 12 }) {
              Button('倒计时')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('正向计时')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('不计时')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
            }
            .width('90%')
            .margin({ bottom: 12 })
            
            // 第三行按钮
            Row({ space: 12 }) {
              Button('25分钟')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('35分钟')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
              
              Button('自定义')
                .height(40)
                .layoutWeight(1)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
            }
            .width('90%')
            .margin({ bottom: 16 })
            
            // 确认和取消按钮
            Row({ space: 16 }) {
              Button('取消')
                .width('40%')
                .height(45)
                .borderRadius(22)
                .backgroundColor('#F5F5F5')
                .fontColor('#333333')
                .onClick(() => {
                  this.isDialogShow = false;
                })
              
              Button('确认')
                .width('40%')
                .height(45)
                .borderRadius(22)
                .backgroundColor('#8A2BE2')
                .fontColor('#FFFFFF')
                .onClick(() => {
                  // 添加新待办项
                  if (this.todoName.trim().length > 0) {
                    const newTodo = new TodoItem(this.nextId++, this.todoName, this.todoType);
                    this.todoItems.push(newTodo);
                    this.todoName = '';
                    this.todoType = '白兔钟';
                  }
                  this.isDialogShow = false;
                })
            }
            .margin({ bottom: 16 })
          }
          .width('85%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding({ top: 10, bottom: 10 })
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.isDialogShow = false;
        })
      }
      
      // 打卡菜单
      if (this.isClockInMenuShow) {
        Column() {
          Column() {
            // 打卡选项
            Text('早起打卡')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .padding(16)
              .borderRadius({ topLeft: 16, topRight: 16 })
              .backgroundColor('#FFFFFF')
              .onClick(() => {
                // 处理早起打卡逻辑
                this.isClockInMenuShow = false;
              })
            
            Divider().color('#EEEEEE').height(1)
            
            Text('今日专注时长打卡')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .onClick(() => {
                this.isClockInMenuShow = false;
                this.isClockInStatsShow = true; // 显示专注时长统计
              })
            
            Divider().color('#EEEEEE').height(1)
            
            Text('睡眠打卡')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .padding(16)
              .borderRadius({ bottomLeft: 16, bottomRight: 16 })
              .backgroundColor('#FFFFFF')
              .onClick(() => {
                // 处理睡眠打卡逻辑
                this.isClockInMenuShow = false;
              })
          }
          .width('80%')
          .margin(16)
          .position({ x: '10%', y: '6%' })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.isClockInMenuShow = false;
        })
      }
      
      // 权限设置对话框
      if (this.isPermissionDialogShow) {
        Column() {
          Column() {
            // 标题和关闭按钮
            Row() {
              Text('请依次全部开启~')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#E74C3C')
              
              Blank()
              
              Text('✖')
                .fontSize(22)
                .fontColor('#666666')
                .onClick(() => {
                  this.isPermissionDialogShow = false;
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })
            
            // 权限说明
            Text('若不设置，计时或锁机会被系统休眠而无法正常运行')
              .fontSize(16)
              .fontColor('#333333')
              .margin({ bottom: 8 })
              .padding({ left: 16, right: 16 })
              .width('100%')
              .textAlign(TextAlign.Start)
            
            Text('请严格按提示设置权限，不要自己去找权限哦，自己找很可能找不全哦')
              .fontSize(16)
              .fontColor('#333333')
              .margin({ bottom: 24 })
              .padding({ left: 16, right: 16 })
              .width('100%')
              .textAlign(TextAlign.Start)
            
            // 第一个权限选项
            Column() {
              Text('设置允许后台运行')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#03A9F4')
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ bottom: 4 })
              
              Text('防止锁屏后被休眠，使提醒更加及时')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .backgroundColor('#E3F2FD')
            .borderRadius(8)
            .padding(16)
            .margin({ bottom: 12, left: 16, right: 16 })
            .onClick(() => {
              // 处理权限设置逻辑
            })
            
            // 第二个权限选项
            Column() {
              Text('设置允许启动')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#03A9F4')
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ bottom: 4 })
              
              Text('允许启动定时提醒或锁机界面')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .backgroundColor('#E3F2FD')
            .borderRadius(8)
            .padding(16)
            .margin({ bottom: 12, left: 16, right: 16 })
            .onClick(() => {
              // 处理权限设置逻辑
            })
            
            // 第三个权限选项
            Column() {
              Text('在多任务界面加锁')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#03A9F4')
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ bottom: 4 })
              
              Text('防止被一键清理')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .backgroundColor('#E3F2FD')
            .borderRadius(8)
            .padding(16)
            .margin({ bottom: 16, left: 16, right: 16 })
            .onClick(() => {
              // 处理权限设置逻辑
            })
            
            // 底部确认文字
            Text('权限已设置完成，不再显示提示')
              .fontSize(16)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 16 })
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 点击空白区域不关闭
        })
      }
      
      // 专注时长打卡统计
      if (this.isClockInStatsShow) {
        Column() {
          Column() {
            // 顶部标题和按钮栏
            Row() {
              Text('打卡 | 保存')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#000000')
              
              Blank()
              
              Row({ space: 12 }) {
                Text('⚪').fontSize(24)
                Text('⬇️').fontSize(24)
                Text('🔄').fontSize(24)
                Text('🔄').fontSize(24)
                Text('✖️').fontSize(24).onClick(() => {
                  this.isClockInStatsShow = false;
                })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .border({ width: { bottom: 1 }, color: { bottom: '#EEEEEE' } })
            
            // 日期显示
            Column({ space: 8 }) {
              Text('2025年05月13日')
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#000000')
              
              Row() {
                Text('共专注99天')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#FF6B6B')
                  .borderRadius(16)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .margin({ right: 8 })
                
                Text('连续专注1天')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#FFD166')
                  .borderRadius(16)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            
            // 计时统计
            Row() {
              Column() {
                Text('当日专注')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ bottom: 8 })
                
                Text('次数')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ bottom: 4 })
                
                Text('0')
                  .fontSize(34)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#000000')
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)
              
              Column() {
                Text('时长')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ bottom: 4 })
                
                Row() {
                  Text('0')
                    .fontSize(34)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#000000')
                  Text('分钟')
                    .fontSize(14)
                    .fontColor('#999999')
                    .alignSelf(ItemAlign.End)
                    .margin({ bottom: 6 })
                }
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            
            // 分布图/时间轴切换
            Row() {
              Text('分布图')
                .fontSize(16)
                .fontColor('#8A2BE2')
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#F0E6FF')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                .width('50%')
                .textAlign(TextAlign.Center)
              
              Text('时间轴')
                .fontSize(16)
                .fontColor('#666666')
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#F5F5F5')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                .width('50%')
                .textAlign(TextAlign.Center)
            }
            .width('85%')
            .height(40)
            .margin({ top: 10, bottom: 10 })
            .backgroundColor('#EFEFEF')
            .borderRadius(20)
            
            // 时长分布统计标题
            Text('专注时长分布 2025-05-13')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ left: 16, top: 10, bottom: 10 })
            
            // 统计时间周期切换
            Row() {
              Text('日')
                .fontSize(16)
                .fontColor('#8A2BE2')
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#F0E6FF')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              
              Text('周')
                .fontSize(16)
                .fontColor('#666666')
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#F5F5F5')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                .margin({ left: 8, right: 8 })
              
              Text('月')
                .fontSize(16)
                .fontColor('#666666')
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#F5F5F5')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              
              Text('自定义')
                .fontSize(16)
                .fontColor('#666666')
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#F5F5F5')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .justifyContent(FlexAlign.Start)
            
            // 统计图表（这里用一个空的容器表示，实际项目中可替换为真实图表）
            Column() {
              Text('暂无专注数据，点击待办上的开始按钮来开始你的专注计时吧')
                .fontSize(14)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .margin(16)
            }
            .width('100%')
            .height(200)
            .backgroundColor('#F8F8F8')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            
            // 底部信息
            Text('处处留心皆学问.')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 16, bottom: 6 })
            
            Text('习惯养成 学霸必备-番茄TODO')
              .fontSize(12)
              .fontColor('#8A2BE2')
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding({ bottom: 16 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          // 点击空白区域关闭弹窗
          this.isClockInStatsShow = false;
        })
      }

      // 待办项操作菜单
      if (this.isOperationMenuShow) {
        Column() {
          Column() {
            // 顶部显示待办号码
            Row() {
              Text('22')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontColor('#000000')
                .margin({ left: 16 })
              
              Blank()
              
              Row({ space: 16 }) {
                Column() {
                  Text('⏰')
                    .fontSize(26)
                    .fontColor('#03A9F4')
                  Text('定时提醒/专注')
                    .fontSize(12)
                    .fontColor('#333333')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Center)
                
                Column() {
                  Text('🖼️')
                    .fontSize(26)
                    .fontColor('#03A9F4')
                  Text('更换背景')
                    .fontSize(12)
                    .fontColor('#333333')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Center)
                
                Column() {
                  Text('📋')
                    .fontSize(26)
                    .fontColor('#03A9F4')
                  Text('独立白名单')
                    .fontSize(12)
                    .fontColor('#333333')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Center)
                .margin({ right: 16 })
              }
            }
            .width('100%')
            .height(100)
            .backgroundColor('#FFFFFF')
            .padding({ top: 20 })
            
            // 操作按钮行
            Row() {
              Button('编辑')
                .fontSize(16)
                .fontColor('#03A9F4')
                .backgroundColor('#E1F5FE')
                .borderRadius(20)
                .height(40)
                .width('33.3%')
                .margin(5)
              
              Button('排序 | 移动')
                .fontSize(16)
                .fontColor('#03A9F4')
                .backgroundColor('#E1F5FE')
                .borderRadius(20)
                .height(40)
                .width('33.3%')
                .margin(5)
              
              Button('删除')
                .fontSize(16)
                .fontColor('#FF5252')
                .backgroundColor('#FFEBEE')
                .borderRadius(20)
                .height(40)
                .width('33.3%')
                .margin(5)
                .onClick(() => {
                  // 删除选中的待办项
                  if (this.selectedTodoId >= 0) {
                    const index = this.todoItems.findIndex(item => item.id === this.selectedTodoId);
                    if (index >= 0) {
                      this.todoItems.splice(index, 1);
                    }
                  }
                  this.isOperationMenuShow = false;
                })
            }
            .width('100%')
            .padding({ left: 10, right: 10, top: 10, bottom: 10 })
            
            // 功能区域
            Row() {
              Column() {
                Text('📊')
                  .fontSize(32)
                  .fontColor('#03A9F4')
                Text('专注历史记录')
                  .fontSize(14)
                  .fontColor('#03A9F4')
                  .margin({ top: 8 })
              }
              .width('50%')
              .backgroundColor('#E1F5FE')
              .borderRadius(8)
              .padding(20)
              .margin(5)
              
              Column() {
                Text('📈')
                  .fontSize(32)
                  .fontColor('#03A9F4')
                Text('数据统计')
                  .fontSize(14)
                  .fontColor('#03A9F4')
                  .margin({ top: 8 })
              }
              .width('50%')
              .backgroundColor('#E1F5FE')
              .borderRadius(8)
              .padding(20)
              .margin(5)
            }
            .width('100%')
            .padding({ left: 10, right: 10 })
            
            // 统计信息区域
            Column() {
              Text('累计专注')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 16, bottom: 16 })
              
              Row() {
                Text('0')
                  .fontSize(40)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#03A9F4')
                Text('次')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ left: 4, bottom: 8 })
                  .alignSelf(ItemAlign.End)
              }
              .justifyContent(FlexAlign.Center)
              .width('50%')
              
              Row() {
                Text('0')
                  .fontSize(40)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#03A9F4')
                Text('分钟')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ left: 4, bottom: 8 })
                  .alignSelf(ItemAlign.End)
              }
              .justifyContent(FlexAlign.Center)
              .width('50%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            
            // 定时提醒信息
            Column() {
              Text('定时提醒 | 定时学霸模式')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#03A9F4')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 16, bottom: 8 })
              
              Text('没有设置定时提醒或定时学霸')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 16 })
              
              Text('目标截止日期 2025-05-14 剩余 1天')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#03A9F4')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 16 })
              
              Row() {
                Column() {
                  Text('计划内已完成')
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ bottom: 4 })
                  
                  Row() {
                    Text('0')
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')
                    Text('分钟')
                      .fontSize(12)
                      .fontColor('#666666')
                      .alignSelf(ItemAlign.End)
                      .margin({ left: 4, bottom: 4 })
                  }
                }
                .width('33.3%')
                .alignItems(HorizontalAlign.Center)
                
                Column() {
                  Text('长期计划完成度')
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ bottom: 4 })
                  
                  Row() {
                    // 圆形进度条（简化表示）
                    Stack() {
                      Circle()
                        .width(50)
                        .height(50)
                        .fill('#EEEEEE')
                        .strokeWidth(5)
                        .stroke('#03A9F4')
                      
                      Text('0')
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')
                    }
                  }
                }
                .width('33.3%')
                .alignItems(HorizontalAlign.Center)
                
                Column() {
                  Text('计划总数')
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ bottom: 4 })
                  
                  Row() {
                    Text('1980')
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')
                    Text('分钟')
                      .fontSize(12)
                      .fontColor('#666666')
                      .alignSelf(ItemAlign.End)
                      .margin({ left: 4, bottom: 4 })
                  }
                }
                .width('33.3%')
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%')
              .padding({ left: 10, right: 10 })
              
              // 底部信息行
              Row() {
                Text('📅')
                  .fontSize(20)
                  .fontColor('#666666')
                Text('总共坚持天数')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 8 })
                
                Blank()
                
                Text('0 天')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              
              Row() {
                Text('🔄')
                  .fontSize(20)
                  .fontColor('#666666')
                Text('连续坚持天数')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 8 })
                
                Blank()
                
                Text('0 天')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              
              Row() {
                Text('📝')
                  .fontSize(20)
                  .fontColor('#666666')
                Text('创建日期')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 8 })
                
                Blank()
                
                Text('2025年05月13日')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 24 })
            }
            .width('100%')
            .backgroundColor('#F5F5F5')
            .margin({ top: 16 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 16, topRight: 16 })
        }
        .width('100%')
        .height('90%')
        .position({ x: 0, y: '10%' })
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.isOperationMenuShow = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}