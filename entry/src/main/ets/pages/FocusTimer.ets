import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import audioPlayer from '../common/AudioPlayer';

// 定义FocusTimer接收的路由参数接口
interface FocusTimerParams {
  time?: number;
  taskTitle?: string;
  title?: string; // 兼容旧的
  isSequence?: boolean;
  collectionId?: string;
  subTaskId?: string;
  todoId?: string | number;
  currentSubTaskIndex?: number;
  totalSubTasksInCollection?: number;
}

// 定义FocusTimer返回给调用页面的参数接口
interface FocusCompletionParams {
  action?: 'focusCompleted';
  sequenceAction?: 'taskCompleted' | 'sequenceAborted' | 'sequenceCompleted';
  collectionId?: string;
  subTaskId?: string;
  todoId?: string | number;
  currentSubTaskIndex?: number;
}

// 类型用于实际传递给router的参数
type RouterParamsObject = Record<string, string | number | boolean>;

@CustomDialog
struct MusicSelectionDialog {
  @State selectedMusic: string = '';
  controller: CustomDialogController;
  musicOptions: string[] = [];
  onSelectMusic: (music: string) => void = () => {};

  build() {
    Column({ space: 0 }) {
      // 顶部音乐图标
      Column() {
        Text('🎶')
          .fontSize(48)
          .margin({ top: 18, bottom: 6 })
        Text('选择背景音乐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .margin({ bottom: 10 })
      }
      .align(Alignment.Center)

      // 音乐选项卡片
      Column({ space: 10 }) {
        ForEach(this.musicOptions, (music: string) => {
          Row() {
            Text(music)
              .fontSize(17)
              .fontColor(music === this.selectedMusic ? '#8A2BE2' : '#333')
              .fontWeight(music === this.selectedMusic ? FontWeight.Bold : FontWeight.Normal)
            Blank()
            if (music === this.selectedMusic) {
              Text('✔').fontSize(20).fontColor('#8A2BE2')
            }
          }
          .padding({ left: 20, right: 20, top: 14, bottom: 14 })
          .backgroundColor(music === this.selectedMusic ? '#F3EFFF' : '#FFF')
          .borderRadius(16)
          .shadow(music === this.selectedMusic ? { radius: 8, color: '#8A2BE220', offsetX: 0, offsetY: 2 } : undefined)
          .onClick(() => {
            this.onSelectMusic(music);
            this.controller.close();
          })
          .margin({ left: 8, right: 8 })
        })
      }
      .width('100%')
      .margin({ top: 8, bottom: 8 })

      // 底部操作区
      Row() {
        Button('取消')
          .width('100%')
          .height(44)
          .fontSize(17)
          .fontColor('#8A2BE2')
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .onClick(() => {
            this.controller.close();
          })
      }
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    }
    .width('92%')
    .backgroundColor('#FFF')
    .borderRadius(22)
    .shadow({ radius: 16, color: 'rgba(138,43,226,0.10)', offsetX: 0, offsetY: 4 })
    .padding({ bottom: 8 })
  }
}

@Entry
@Component
struct FocusTimer {
  @State minutes: number = 0;
  @State seconds: number = 0;
  @State totalSeconds: number = 0;
  @State isPaused: boolean = false;
  @State quote: string = '专注的时光，价值非凡。';
  @State displayTaskTitle: string = '专注任务';
  @State isMusicDialogShow: boolean = false;
  @State selectedMusic: string = '无声';
  private timerId: number = -1;
  private musicOptions: string[] = ['无声', '轻柔钢琴', '自然雨声', '海浪声', '森林鸟鸣', '白噪音', '冥想音乐'];
  // Router an CustomDialogController should be initialized with proper parameters.
  // Ensure selectedMusic is properly linked if it's meant to be.
  private musicDialogController: CustomDialogController = new CustomDialogController({
    builder: MusicSelectionDialog({
      selectedMusic: $selectedMusic, // 使用 $ 进行双向绑定
      musicOptions: this.musicOptions,
      onSelectMusic: (music: string) => {
        this.playSelectedMusic(music);
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });
  @State private isSequence: boolean = false;
  @State private collectionId: string | undefined = undefined;
  @State private subTaskId: string | undefined = undefined;
  @State private todoId: string | number | undefined = undefined;
  @State private currentSubTaskIndex: number = -1;
  @State private totalSubTasksInCollection: number = 0;
  private initialTotalSeconds: number = 25 * 60; // 用于进度条的总时长

  aboutToAppear() {
    const params = router.getParams() as FocusTimerParams;
    console.info('FocusTimer received params: ' + JSON.stringify(params));

    if (params) {
      this.initialTotalSeconds = params.time !== undefined ? Number(params.time) : 25 * 60;
      this.totalSeconds = this.initialTotalSeconds;
      this.displayTaskTitle =
        params.taskTitle !== undefined ? String(params.taskTitle) : (params.title ? String(params.title) : '专注任务');

      this.isSequence = params.isSequence === true;
      this.collectionId = params.collectionId ? String(params.collectionId) : undefined;
      this.subTaskId = params.subTaskId ? String(params.subTaskId) : undefined;
      this.todoId = params.todoId ? params.todoId : undefined;
      this.currentSubTaskIndex = params.currentSubTaskIndex !== undefined ? Number(params.currentSubTaskIndex) : -1;
      this.totalSubTasksInCollection =
        params.totalSubTasksInCollection !== undefined ? Number(params.totalSubTasksInCollection) : 0;
    }

    if (this.totalSeconds <= 0) {
      this.initialTotalSeconds = 25 * 60;
      this.totalSeconds = this.initialTotalSeconds;
    }
    this.minutes = Math.floor(this.totalSeconds / 60);
    this.seconds = this.totalSeconds % 60;

    this.startTimer();
    if (this.selectedMusic !== '无声') {
      this.playSelectedMusic(this.selectedMusic);
    }
  }

  aboutToDisappear() {
    // 清除计时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    
    // 停止音乐播放
    audioPlayer.stop();
  }
  
  startTimer() {
    // 确保只有一个计时器在运行
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    
    this.timerId = setInterval(() => {
      if (!this.isPaused) {
        if (this.totalSeconds > 0) {
          this.totalSeconds--;
          this.minutes = Math.floor(this.totalSeconds / 60);
          this.seconds = this.totalSeconds % 60;
        } else {
          // 计时结束
          clearInterval(this.timerId);
          this.timerId = -1;
          // 计时结束时停止音乐
          audioPlayer.stop();
          
          if (this.isSequence) {
            // 如果是序列模式，自动启动下一个任务
            this.startNextTask();
          } else {
            // 非序列模式，显示普通完成提示
            promptAction.showToast({
              message: '专注时间结束！',
              duration: 3000
            });
          }
        }
      }
    }, 1000);
  }
  
  // 播放选择的音乐
  playSelectedMusic(music: string) {
    this.selectedMusic = music;
    try {
      if (music === '无声') {
        audioPlayer.stop();
        promptAction.showToast({
          message: '已切换到静音模式',
          duration: 2000
        });
      } else {
        audioPlayer.play(music); // 直接传音乐名
        promptAction.showToast({
          message: `正在播放: ${music}`,
          duration: 2000
        });
      }
    } catch (error) {
      console.error(`播放音乐失败: ${error}`);
      promptAction.showToast({
        message: '播放音乐失败，请重试',
        duration: 2000
      });
    }
  }
  
  // 修改startNextTask方法
  private startNextTask() {
    if (this.isSequence && this.currentSubTaskIndex >= 0 && this.totalSubTasksInCollection > 0) {
      const nextIndex = this.currentSubTaskIndex + 1;
      if (nextIndex < this.totalSubTasksInCollection) {
        // 构建下一个任务的参数
        const nextTaskParams: FocusTimerParams = {
          isSequence: true,
          collectionId: this.collectionId,
          currentSubTaskIndex: nextIndex,
          totalSubTasksInCollection: this.totalSubTasksInCollection
        };
        
        // 使用router.push跳转到下一个任务
        router.pushUrl({
          url: 'pages/FocusTimer',
          params: nextTaskParams
        });
      } else {
        // 所有任务完成，显示恭喜提示
        promptAction.showToast({
          message: '恭喜！所有待办事项已完成！',
          duration: 3000
        });
        // 返回主页面
        router.back({
          url: 'pages/Index',
          params: {
            action: 'focusCompleted',
            sequenceAction: 'sequenceCompleted'
          }
        });
      }
    }
  }
  
  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['#333355', 0.0], ['#503060', 0.3], ['#803070', 0.7], ['#8A2BE2', 1.0]]
        })
      
      // 主内容
      Column() {
        // 顶部区域
        Row() {
          Text('17:06')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .margin({ left: 16 })
          
          Blank()
          
          if (this.isSequence) {
            Text(`序列任务 ${this.currentSubTaskIndex + 1}/${this.totalSubTasksInCollection}`)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .opacity(0.8)
              .margin({ right: 16 })
          }
          
          Row({ space: 4 }) {
            Text('📷')
              .fontSize(24)
              .fontColor('#FFFFFF')
            Text('⧉')
              .fontSize(24)
              .fontColor('#FFFFFF')
            Text('↗')
              .fontSize(24)
              .fontColor('#FFFFFF')
            Text('⬇')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .margin({ right: 16 })
        }
        .width('100%')
        .height(60)
        
        // 引用区域
        Row() {
          Text('"')
            .fontSize(60)
            .fontColor('#FFFFFF')
            .opacity(0.5)
            .margin({ top: -30 })
          
          Column() {
            Text(this.quote)
              .fontSize(22)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .margin({ top: 30 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 16, bottom: 32 })
        .padding({ left: 16, right: 16 })
        
        // 倒计时区域
        Column() {
          Stack() {
            Circle()
              .width(300)
              .height(300)
              .fill('transparent')
              .stroke('#FFFFFF')
              .strokeWidth(8)
              .opacity(0.5)
            
            Text(`${this.minutes.toString().padStart(2, '0')}:${this.seconds.toString().padStart(2, '0')}`)
              .fontSize(80)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ top: 40, bottom: 40 })
          
          // 提示文本
          Text('点击开始按钮来专注计时')
            .fontSize(18)
            .fontColor('#FFFFFF')
            .opacity(0.8)
          
          Text(`${this.isPaused ? '已暂停' : '进行中'} · ${this.selectedMusic}`)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .opacity(0.6)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        
        // 底部控制栏
        Row() {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('🌙')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(50)
          .height(50)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('🎵')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(50)
          .height(50)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .onClick(() => {
            this.isMusicDialogShow = true;
          })
          
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text(this.isPaused ? '▶' : '⏸')
              .fontSize(30)
              .fontColor('#FFFFFF')
          }
          .width(70)
          .height(70)
          .backgroundColor('rgba(255, 255, 255, 0.3)')
          .margin({ left: 16, right: 16 })
          .onClick(() => {
            this.isPaused = !this.isPaused;
            
            // 处理音乐的暂停和恢复
            if (this.isPaused) {
              audioPlayer.pause();
            } else {
              // 只有在非"无声"模式下恢复播放
              if (this.selectedMusic !== '无声') {
                audioPlayer.resume();
              }
            }
          })
          
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('↻')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(50)
          .height(50)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .onClick(() => {
            // 重置计时器
            this.isPaused = true;
            this.totalSeconds = 25 * 60; // 重置为25分钟
            this.minutes = 25;
            this.seconds = 0;
            
            // 停止音乐
            audioPlayer.pause();
          })
          
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('■')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(50)
          .height(50)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .onClick(() => {
            // 提前完成计时
            audioPlayer.stop();
            
            if (this.isSequence) {
              // 如果是序列模式，自动启动下一个任务
              this.startNextTask();
            } else {
              // 非序列模式，显示普通完成提示
              promptAction.showToast({
                message: '专注已提前完成！',
                duration: 2000
              });
              
              // 构建返回参数
              const params: FocusCompletionParams = {
                action: 'focusCompleted',
                sequenceAction: 'taskCompleted'
              };
              
              // 添加可选参数
              if (this.collectionId) {
                params.collectionId = this.collectionId;
              }
              if (this.subTaskId) {
                params.subTaskId = this.subTaskId;
              }
              if (this.todoId) {
                params.todoId = this.todoId;
              }
              if (this.currentSubTaskIndex >= 0) {
                params.currentSubTaskIndex = this.currentSubTaskIndex;
              }
              
              // 返回上一页并传递参数
              router.back({
                url: 'pages/Index',
                params: params
              });
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 30 })
        
        Text('↓')
          .fontSize(24)
          .fontColor('#FFFFFF')
          .margin({ bottom: 24 })
          .onClick(() => {
            // 停止音乐
            audioPlayer.stop();
            router.back();
          })
      }
      .width('100%')
      .height('100%')
      
      // 音乐选择对话框
      if (this.isMusicDialogShow) {
        Column() {
          Column() {
            // 标题
            Text('选择背景音乐')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 16 })
            
            // 音乐选项列表
            List() {
              ForEach(this.musicOptions, (music: string) => {
                ListItem() {
                  Row() {
                    Text(music)
                      .fontSize(18)
                      .fontColor(this.selectedMusic === music ? '#8A2BE2' : '#333333')
                      .fontWeight(this.selectedMusic === music ? FontWeight.Bold : FontWeight.Normal)
                    
                    Blank()
                    
                    if (this.selectedMusic === music) {
                      Text('✓')
                        .fontSize(18)
                        .fontColor('#8A2BE2')
                    }
                  }
                  .width('100%')
                  .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                  .onClick(() => {
                    this.playSelectedMusic(music);
                    this.isMusicDialogShow = false;
                  })
                }
              })
            }
            .width('100%')
            .margin({ bottom: 20 })
            
            // 取消按钮
            Button('取消')
              .width('80%')
              .height(45)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#8A2BE2')
              .borderRadius(22)
              .margin({ bottom: 20 })
              .onClick(() => {
                this.isMusicDialogShow = false;
              })
          }
          .width('85%')
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 点击背景关闭对话框
          this.isMusicDialogShow = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
} 