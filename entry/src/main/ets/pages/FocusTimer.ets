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
  sequenceAction?: 'taskCompleted' | 'sequenceAborted';
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
  @State private collectionId: string | null = null;
  @State private subTaskId: string | null = null;
  @State private todoId: string | number | null = null;
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
      this.collectionId = params.collectionId ? String(params.collectionId) : null;
      this.subTaskId = params.subTaskId ? String(params.subTaskId) : null;
      this.todoId = params.todoId ? params.todoId : null;
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
      this.playSelectedMusic(this.selectedMusic, false);
    }
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    audioPlayer.stop();
  }

  startTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    this.isPaused = false;
    this.timerId = setInterval(() => {
      if (!this.isPaused) {
        if (this.totalSeconds > 0) {
          this.totalSeconds--;
          this.minutes = Math.floor(this.totalSeconds / 60);
          this.seconds = this.totalSeconds % 60;
        } else {
          clearInterval(this.timerId);
          this.timerId = -1;
          audioPlayer.stop();
          this.handleTimerCompletion();
        }
      }
    }, 1000);
  }

  handleTimerCompletion() {
    promptAction.showToast({ message: '专注时间圆满结束！' });
    let paramsToSend: RouterParamsObject = {};

    if (this.isSequence) {
      paramsToSend['sequenceAction'] = 'taskCompleted';
      if (this.collectionId !== null) {
        paramsToSend['collectionId'] = this.collectionId;
      }
      if (this.subTaskId !== null) {
        paramsToSend['subTaskId'] = this.subTaskId;
      }
      if (this.currentSubTaskIndex !== -1) {
        paramsToSend['currentSubTaskIndex'] = this.currentSubTaskIndex;
      }

      router.replaceUrl({ url: 'pages/TodoDetail', params: paramsToSend })
        .catch((err: Error) => console.error("Failed to navigate for sequence completion: " + JSON.stringify(err)));
    } else {
      paramsToSend['action'] = 'focusCompleted';
      if (this.todoId !== null) {
        paramsToSend['todoId'] = typeof this.todoId === 'number' ? this.todoId.toString() : this.todoId;
        router.replaceUrl({ url: 'pages/Index', params: paramsToSend })
          .catch((err: Error) => console.error("Failed to navigate to Index for completion: " + JSON.stringify(err)));
      } else if (this.collectionId !== null && this.subTaskId !== null) {
        if (this.collectionId !== null) {
          paramsToSend['collectionId'] = this.collectionId;
        }
        if (this.subTaskId !== null) {
          paramsToSend['subTaskId'] = this.subTaskId;
        }
        router.replaceUrl({ url: 'pages/TodoDetail', params: paramsToSend })
          .catch((err: Error) => console.error("Failed to navigate to TodoDetail for completion: " +
          JSON.stringify(err)));
      } else {
        router.back();
      }
    }
  }

  togglePause() {
    this.isPaused = !this.isPaused;
    if (this.isPaused) {
      promptAction.showToast({ message: "计时已暂停" });
    } else {
      promptAction.showToast({ message: "计时已恢复" });
    }
  }

  handleExitFocus() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    audioPlayer.stop();
    promptAction.showToast({ message: "专注已退出" });
    let paramsToSend: RouterParamsObject = {};

    if (this.isSequence) {
      paramsToSend['sequenceAction'] = 'sequenceAborted';
      if (this.collectionId !== null) {
        paramsToSend['collectionId'] = this.collectionId;
      }
      if (this.subTaskId !== null) {
        paramsToSend['subTaskId'] = this.subTaskId;
      }

      router.replaceUrl({ url: 'pages/TodoDetail', params: paramsToSend })
        .catch((err: Error) => console.error("Failed to navigate for sequence abort: " + JSON.stringify(err)));
    } else {
      router.back();
    }
  }

  playSelectedMusic(music: string, showToast: boolean = true) {
    this.selectedMusic = music;
    try {
      if (music === '无声') {
        audioPlayer.stop();
      } else {
        audioPlayer.play(music);
      }
      if (showToast) {
        promptAction.showToast({
          message: music === '无声' ? '已切换到静音模式' : `正在播放: ${music}`,
          duration: 2000
        });
      }
    } catch (error) { // Consider more specific error type if possible for audioPlayer
      console.error(`播放音乐 '${music}' 失败: ${JSON.stringify(error)}`);
      if (showToast) {
        promptAction.showToast({ message: '播放音乐失败' });
      }
    }
  }

  build() {
    Stack() {
      Column().width('100%').height('100%')
        .linearGradient({
          angle: 180,
          colors: [['#333355', 0.0], ['#503060', 0.3], ['#803070', 0.7], ['#8A2BE2', 1.0]]
        })

      Column() {
        Row() {
          Text(this.isSequence ? `序列 (${this.currentSubTaskIndex + 1}/${this.totalSubTasksInCollection})` :
            '专注模式')
            .fontSize(18).fontColor('#FFFFFF').margin({ left: 16 }).opacity(0.8)
          Blank()
          // Removed extra icons for now
        }.width('100%').height(50).padding({ top: 10 })

        Column() {
          Text(this.quote)
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 20 })
            .textAlign(TextAlign.Center)
            .padding({ left: 20, right: 20 }) // Changed paddingSymmetric
        }.width('100%').margin({ bottom: 30 })

        Column() {
          Text(this.displayTaskTitle)
            .fontSize(24)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })
            .padding({ left: 15, right: 15 })// Changed paddingSymmetric
            .textAlign(TextAlign.Center)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)

          Stack() {
            Circle()
              .width(280)
              .height(280)
              .fill('transparent')
              .stroke('#FFFFFF')
              .strokeWidth(6)
              .opacity(0.4)
            Progress({
              value: this.totalSeconds,
              total: this.initialTotalSeconds, // Use initialTotalSeconds for progress total
              type: ProgressType.Ring
            })
              .width(280).height(280).color(Color.White).style({ strokeWidth: 8 })
            Text(`${this.minutes.toString().padStart(2, '0')}:${this.seconds.toString().padStart(2, '0')}`)
              .fontSize(70).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          }
          .margin({ top: 20, bottom: 40 })

          Text(`${this.isPaused ? '已暂停' :
            (this.timerId === -1 && this.totalSeconds <= 0 ? '已完成' : '进行中')} · ${this.selectedMusic}`)
            .fontSize(16).fontColor('#FFFFFF').opacity(0.7).margin({ top: 8 })
        }
        .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center)

        Row({ space: 20 }) {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('🎵').fontSize(24)
          }.width(60).height(60).backgroundColor('rgba(255,255,255,0.2)')
          .onClick(() => {
            this.isMusicDialogShow = true;
            this.musicDialogController.open();
          })

          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text(this.isPaused ? '▶' : '❚❚').fontSize(28).fontColor("#800080")/* Purple */.fontWeight(FontWeight.Bold)
          }
          .width(80)
          .height(80)
          .backgroundColor(Color.White)
          .onClick(() => {
            this.togglePause();
          })
          .enabled(this.totalSeconds > 0 || this.timerId !== -1)

          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('✓').fontSize(24)
          }
          .width(60)
          .height(60)
          .backgroundColor('rgba(255,255,255,0.2)')
          .onClick(() => {
            if (this.timerId !== -1) {
              clearInterval(this.timerId);
              this.timerId = -1;
              this.totalSeconds = 0;
              this.minutes = 0;
              this.seconds = 0;
              audioPlayer.stop();
              promptAction.showToast({ message: "提前完成专注！" });
              this.handleTimerCompletion();
            }
          })
          .visibility(this.totalSeconds > 0 || this.timerId !== -1 ? Visibility.Visible : Visibility.Hidden)

          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('✕').fontSize(24)
          }
          .width(60)
          .height(60)
          .backgroundColor('rgba(255,255,255,0.2)')
          .onClick(() => {
            this.handleExitFocus();
          })
          .visibility(this.totalSeconds > 0 || this.timerId !== -1 ? Visibility.Visible : Visibility.Hidden)
        }
        .width('100%').padding(20).justifyContent(FlexAlign.Center).margin({ bottom: 30 })
      }
      .width('100%').height('100%').padding({ top: 10 })
    }
  }
} 