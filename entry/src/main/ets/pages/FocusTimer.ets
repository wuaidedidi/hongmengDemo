import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import audioPlayer from '../common/AudioPlayer';
import { ApiService, TodoCollectionItem } from '../services/ApiService';

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

// 用于日志输出的简化任务信息接口
interface TaskLogInfo {
  id: number;
  title: string;
  completed?: boolean;
  index?: number;
}

// 下一个任务对话框组件
@CustomDialog
struct NextTaskDialog {
  @State countdown: number = 5;
  private countdownTimer: number = -1;
  controller: CustomDialogController;
  nextItem: TodoCollectionItem = { 
    id: 0, 
    title: '', 
    completed: false, 
    order: 0,
    collectionId: 0,
    createdAt: ''
  };
  nextIndex: number = 0;
  actualTotalTasks: number = 0;
  onStart: () => void = () => {};
  onCancel: () => void = () => {};

  aboutToAppear() {
    this.startCountdown();
  }

  aboutToDisappear() {
    this.clearCountdown();
  }

  startCountdown() {
    console.info('NextTaskDialog: 开始5秒倒计时');
    this.countdownTimer = setInterval(() => {
      this.countdown--;
      console.info(`NextTaskDialog: 倒计时剩余 ${this.countdown} 秒`);
      if (this.countdown <= 0) {
        console.info('NextTaskDialog: 倒计时结束，准备开始下一个任务');
        this.clearCountdown();
        this.onStart();
      }
    }, 1000);
  }

  clearCountdown() {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }
  }

  build() {
    Column() {
      // 标题区域
      Column() {
        Text('🎯')
          .fontSize(48)
          .margin({ top: 20, bottom: 10 })
        Text('准备下一个任务')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
      }
      .alignItems(HorizontalAlign.Center)

      // 任务信息区域
      Column({ space: 12 }) {
        Row() {
          Text('即将开始：')
            .fontSize(16)
            .fontColor('#666')
          Text(this.nextItem.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
            .layoutWeight(1)
            .textAlign(TextAlign.End)
        }
        .width('100%')

        Row() {
          Text('专注时长：')
            .fontSize(16)
            .fontColor('#666')
          Text('25分钟')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('进度：')
            .fontSize(16)
            .fontColor('#666')
          Text(`${this.nextIndex + 1}/${this.actualTotalTasks}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#007AFF')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor('#F8F9FA')
      .borderRadius(12)
      .margin({ left: 16, right: 16 })

      // 倒计时区域
      Column() {
        Text(`${this.countdown}`)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#007AFF')
        Text('秒后自动开始下一个任务')
          .fontSize(14)
          .fontColor('#666')
          .opacity(0.8)
      }
      .margin({ top: 20, bottom: 20 })
      .alignItems(HorizontalAlign.Center)

      // 操作按钮区域
      Row({ space: 12 }) {
        Button('结束序列')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor('#FF3B30')
          .backgroundColor('#FFF')
          .border({ width: 1, color: '#FF3B30' })
          .borderRadius(22)
          .onClick(() => {
            this.clearCountdown();
            this.onCancel();
          })

        Button(`立即开始`)
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor('#FFF')
          .backgroundColor('#007AFF')
          .borderRadius(22)
          .onClick(() => {
            this.clearCountdown();
            this.onStart();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('92%')
    .backgroundColor('#FFF')
    .borderRadius(20)
    .shadow({ radius: 16, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
  }
}

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
  @State time: number = 0;
  @State isRunning: boolean = false;
  @State title: string = '';
  @State taskTitle: string = '';
  @State todoId: number = 0;
  @State isSequence: boolean = false;
  @State isMusicDialogShow: boolean = false;
  @State selectedMusic: string = '无声';
  private timer: number = -1;
  private startTime: Date = new Date();
  private originalTime: number = 0;
  private musicOptions: string[] = ['无声', '轻柔钢琴', '自然雨声', '海浪声', '森林鸟鸣', '白噪音', '冥想音乐'];
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
  private apiService: ApiService = ApiService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as FocusTimerParams;
    console.info('FocusTimer received params: ' + JSON.stringify(params));

    if (params) {
      this.time = params.time !== undefined ? Number(params.time) : 25 * 60;
      this.taskTitle =
        params.taskTitle !== undefined ? String(params.taskTitle) : (params.title ? String(params.title) : '专注任务');
      this.title = params.title ? String(params.title) : '专注任务';
      this.todoId = params.todoId ? Number(params.todoId) : 0;
      this.isSequence = params.isSequence === true;
    }

    if (this.time <= 0) {
      this.time = 25 * 60;
    }

    this.originalTime = this.time;
    this.startTime = new Date();
    this.startTimer();
    if (this.selectedMusic !== '无声') {
      this.playSelectedMusic(this.selectedMusic);
    }
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    
    // 停止音乐播放
    audioPlayer.stop();
  }
  
  startTimer() {
    if (this.timer === -1) {
      this.isRunning = true;
      this.timer = setInterval(() => {
        if (this.time > 0) {
          this.time--;
        } else {
          this.stopTimer();
          this.handleSessionComplete();
        }
      }, 1000);
    }
  }
  
  stopTimer() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
      this.isRunning = false;
    }
  }
  
  restartTimer() {
    // 停止当前计时器
    this.stopTimer();
    
    // 重置时间到原始值
    this.time = this.originalTime;
    
    // 重新记录开始时间
    this.startTime = new Date();
    
    // 重新开始计时
    this.startTimer();
    
    // 显示提示
    promptAction.showToast({ message: '⏰ 重新开始计时' });
  }
  
  async handleSessionComplete() {
    try {
      const endTime = new Date();
      const actualDuration = Math.floor((endTime.getTime() - this.startTime.getTime()) / 1000);
      const durationMinutes = Math.round(actualDuration / 60);
      
      console.info('开始保存专注记录（正常完成）');
      console.info(`专注时长(秒): ${actualDuration}`);
      console.info(`专注时长(分钟): ${durationMinutes}`);
      console.info(`开始时间: ${this.startTime.toISOString()}`);
      console.info(`结束时间: ${endTime.toISOString()}`);
      console.info(`原始专注时间: ${this.originalTime}秒`);
      console.info(`剩余时间: ${this.time}秒`);
      
      // 如果计算出的时长太短，使用原始设定时间
      const finalDurationMinutes = durationMinutes > 0 ? durationMinutes : Math.round(this.originalTime / 60);
      console.info(`最终保存的时长(分钟): ${finalDurationMinutes}`);
      
      // 格式化时间为后端期望的格式 yyyy-MM-dd HH:mm:ss
      const formatDateTime = (date: Date): string => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const seconds = String(date.getSeconds()).padStart(2, '0');
        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
      };
      
      // 创建专注会话记录
      await this.apiService.createFocusSession({
        durationMinutes: finalDurationMinutes,
        startTime: formatDateTime(this.startTime),
        endTime: formatDateTime(endTime),
        taskDescription: '专注会话'
      });
      
      console.info('专注记录保存成功');
      
      // 显示庆祝提示
      promptAction.showToast({ message: '🎉 专注完成！太棒了！' });
      
      // 如果是序列任务，检查并处理下一个任务
      if (this.isSequence) {
        await this.handleSequenceProgress();
      } else {
        router.back();
      }
    } catch (error) {
      console.error('保存专注记录失败:', error);
      console.error('错误详情:', JSON.stringify(error));
      
      // 检查是否是认证问题
      if (error.message && error.message.includes('401')) {
        promptAction.showToast({ message: '登录已过期，请重新登录' });
      } else if (error.message && error.message.includes('网络')) {
        promptAction.showToast({ message: '网络连接失败，请检查网络' });
      } else {
        promptAction.showToast({ message: `保存专注记录失败: ${error.message || '未知错误'}` });
      }
    }
  }
  
  async handleEarlyCompletion() {
    try {
      const endTime = new Date();
      const actualDuration = Math.floor((endTime.getTime() - this.startTime.getTime()) / 1000);
      const durationMinutes = Math.round(actualDuration / 60);
      
      console.info('开始保存专注记录（提前完成）');
      console.info(`专注时长(秒): ${actualDuration}`);
      console.info(`专注时长(分钟): ${durationMinutes}`);
      console.info(`开始时间: ${this.startTime.toISOString()}`);
      console.info(`结束时间: ${endTime.toISOString()}`);
      console.info(`原始专注时间: ${this.originalTime}秒`);
      console.info(`剩余时间: ${this.time}秒`);
      
      // 提前完成时，使用实际时长，但至少1分钟
      const finalDurationMinutes = Math.max(1, durationMinutes);
      console.info(`最终保存的时长(分钟): ${finalDurationMinutes}`);
      
      // 格式化时间为后端期望的格式 yyyy-MM-dd HH:mm:ss
      const formatDateTime = (date: Date): string => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const seconds = String(date.getSeconds()).padStart(2, '0');
        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
      };
      
      // 创建专注会话记录（提前完成）
      await this.apiService.createFocusSession({
        durationMinutes: finalDurationMinutes,
        startTime: formatDateTime(this.startTime),
        endTime: formatDateTime(endTime),
        taskDescription: '专注会话（提前完成）'
      });
      
      console.info('专注记录保存成功');
      
      // 显示庆祝提示
      promptAction.showToast({ message: '🎉 提前完成！真是太棒了！' });
      
      // 如果是序列任务，检查并处理下一个任务
      if (this.isSequence) {
        await this.handleSequenceProgress();
      } else {
        router.back();
      }
    } catch (error) {
      console.error('保存专注记录失败:', error);
      console.error('错误详情:', JSON.stringify(error));
      
      // 检查是否是认证问题
      if (error.message && error.message.includes('401')) {
        promptAction.showToast({ message: '登录已过期，请重新登录' });
      } else if (error.message && error.message.includes('网络')) {
        promptAction.showToast({ message: '网络连接失败，请检查网络' });
      } else {
        promptAction.showToast({ message: `保存专注记录失败: ${error.message || '未知错误'}` });
      }
    }
  }
  
  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
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
  
  // 处理序列任务进度
  async handleSequenceProgress(): Promise<void> {
    const params = router.getParams() as FocusTimerParams;
    console.info('开始处理序列任务进度，参数:', JSON.stringify(params));
    
    if (!params.collectionId || params.currentSubTaskIndex === undefined || params.totalSubTasksInCollection === undefined) {
      console.error('序列任务参数不完整:', params);
      promptAction.showToast({ message: '序列任务参数错误' });
      router.back();
      return;
    }

    try {
      console.info(`开始处理序列任务 - 合集ID: ${params.collectionId}, 当前索引: ${params.currentSubTaskIndex}, 总数: ${params.totalSubTasksInCollection}`);
      
      // 先获取最新的子任务列表（在更新状态之前）
      console.info(`获取合集${params.collectionId}的所有子任务`);
      const collectionItems = await this.apiService.getCollectionItems(Number(params.collectionId));
      const taskLogInfos: TaskLogInfo[] = collectionItems.map((item: TodoCollectionItem): TaskLogInfo => {
        return { id: item.id, title: item.title, completed: item.completed };
      });
      console.info(`获取到${collectionItems.length}个子任务:`, taskLogInfos);
      
      // 验证当前任务索引是否有效
      if (params.currentSubTaskIndex >= collectionItems.length) {
        console.error(`当前任务索引${params.currentSubTaskIndex}超出范围，实际任务数: ${collectionItems.length}`);
        promptAction.showToast({ message: '当前任务索引超出范围' });
        router.back();
        return;
      }
      
      // 检查是否还有下一个任务
      const nextIndex = params.currentSubTaskIndex + 1;
      console.info(`下一个任务索引: ${nextIndex}, 总任务数: ${collectionItems.length}`);
      
      // 标记当前子任务为完成（在确认有效性后）
      if (params.subTaskId) {
        console.info(`标记子任务${params.subTaskId}为完成`);
        try {
          await this.apiService.toggleCollectionItemStatus(Number(params.collectionId), Number(params.subTaskId));
          console.info('子任务状态更新成功');
        } catch (statusError) {
          console.error('更新子任务状态失败:', statusError);
          // 状态更新失败不应该阻止序列继续
        }
      }
      
      if (nextIndex >= collectionItems.length) {
        // 所有任务都完成了，显示祝贺
        console.info('所有任务已完成，显示祝贺对话框');
        await this.showSequenceCompletionDialog();
        router.back();
        return;
      }
      
      const nextItem = collectionItems[nextIndex];
      const nextTaskLogInfo: TaskLogInfo = { 
        id: nextItem.id, 
        title: nextItem.title, 
        index: nextIndex, 
        completed: nextItem.completed 
      };
      console.info(`下一个任务:`, nextTaskLogInfo);
      
      if (!nextItem) {
        console.error('下一个任务为空');
        promptAction.showToast({ message: '找不到下一个任务' });
        router.back();
        return;
      }

      // 显示准备下一个任务的对话框
      console.info('显示下一个任务准备对话框');
      await this.showNextTaskDialog(nextItem, nextIndex, params, collectionItems.length);

    } catch (error) {
      console.error('处理序列任务进度失败，详细错误:', error);
      console.error('错误类型:', typeof error);
      console.error('错误消息:', (error as Error).message);
      console.error('错误堆栈:', (error as Error).stack);
      promptAction.showToast({ message: `处理下一个任务失败: ${(error as Error).message || '未知错误'}` });
      router.back();
    }
  }

  // 显示下一个任务对话框
  showNextTaskDialog(nextItem: TodoCollectionItem, nextIndex: number, currentParams: FocusTimerParams, actualTotalTasks: number): Promise<void> {
    return new Promise((resolve) => {
      const nextTaskDialogController = new CustomDialogController({
        builder: NextTaskDialog({
          nextItem: nextItem,
          nextIndex: nextIndex,
          actualTotalTasks: actualTotalTasks,
          onStart: () => {
            console.info('NextTaskDialog: onStart回调被触发');
            nextTaskDialogController.close();
            
            // 跳转到下一个任务的FocusTimer
            const nextParams: FocusTimerParams = {
              title: `${nextItem.title}`,
              taskTitle: nextItem.title,
              time: 25 * 60, // 默认25分钟，因为ApiService中的TodoCollectionItem没有durationMinutes属性
              isSequence: true,
              collectionId: currentParams.collectionId,
              subTaskId: nextItem.id.toString(),
              currentSubTaskIndex: nextIndex,
              totalSubTasksInCollection: actualTotalTasks // 使用实际的任务数量
            };

            console.info('NextTaskDialog: 准备跳转到下一个任务，参数:', JSON.stringify(nextParams));

            router.replaceUrl({
              url: 'pages/FocusTimer',
              params: nextParams
            }).then(() => {
              console.info('NextTaskDialog: router.replaceUrl 调用成功');
              resolve();
            }).catch((error: Error) => {
              console.error('NextTaskDialog: router.replaceUrl 调用失败:', error);
              resolve();
            });
          },
          onCancel: () => {
            console.info('用户选择结束序列');
            nextTaskDialogController.close();
            router.back();
            resolve();
          }
        }),
        autoCancel: false, // 禁止点击外部关闭
        alignment: DialogAlignment.Center
      });
      
      nextTaskDialogController.open();
    });
  }

  // 显示序列完成祝贺对话框
  showSequenceCompletionDialog(): Promise<void> {
    return new Promise((resolve) => {
      AlertDialog.show({
        title: '🎉 恭喜完成！',
        message: '你已经完成了整个待办合集的所有任务！\n\n坚持不懈的努力值得称赞！\n继续保持这种专注和毅力！',
        primaryButton: {
          value: '太棒了！',
          action: () => {
            promptAction.showToast({ message: '🏆 所有任务完成！你真是太厉害了！' });
            resolve();
          }
        }
      });
    });
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
          Text(this.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 10 })
          
          Blank()
          
          if (this.isSequence) {
            Text(`序列任务 ${this.time / 60}分钟`)
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
            Text(this.taskTitle)
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
            
            Text(this.formatTime(this.time))
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
          
          Text(`${this.isRunning ? '进行中' : '已暂停'} · ${this.selectedMusic}`)
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
            Text(this.isRunning ? '⏸' : '▶')
              .fontSize(30)
              .fontColor('#FFFFFF')
          }
          .width(70)
          .height(70)
          .backgroundColor('rgba(255, 255, 255, 0.3)')
          .margin({ left: 16, right: 16 })
          .onClick(() => {
            if (this.isRunning) {
              this.stopTimer();
            } else {
              this.startTimer();
            }
          })
          
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('✓')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(50)
          .height(50)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .onClick(() => {
            this.stopTimer();
            this.handleEarlyCompletion();
          })
          
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text('🔄')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(50)
          .height(50)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .onClick(() => {
            this.restartTimer();
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

interface FocusTimerRouterParams {
  title: string;
  taskTitle: string;
  time: number;
  todoId: number;
  isSequence: boolean;
}