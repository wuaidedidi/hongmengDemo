import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import audioPlayer from '../common/AudioPlayer';

@Entry
@Component
export default struct FocusTimer {
  @State minutes: number = 0;
  @State seconds: number = 0;
  @State totalSeconds: number = 0;
  @State isPaused: boolean = false;
  @State quote: string = '纵然缓慢，驰而不息。';
  @State todoTitle: string = '';
  @State isMusicDialogShow: boolean = false; // 是否显示音乐选择对话框
  @State selectedMusic: string = '无声'; // 当前选择的音乐
  private timerId: number = -1;
  private musicOptions: string[] = ['无声', '轻柔钢琴', '自然雨声', '海浪声', '森林鸟鸣', '白噪音', '冥想音乐'];

  aboutToAppear() {
    const params = router.getParams();
    if (params) {
      const paramsObj = params as Record<string, string | number>;
      if (paramsObj.time !== undefined) {
        this.totalSeconds = paramsObj.time as number;
        this.minutes = Math.floor(this.totalSeconds / 60);
        this.seconds = this.totalSeconds % 60;
      }
      if (paramsObj.title !== undefined) {
        this.todoTitle = paramsObj.title as string;
      }
    }
    
    // 默认25分钟
    if (this.totalSeconds <= 0) {
      this.totalSeconds = 25 * 60;
      this.minutes = 25;
      this.seconds = 0;
    }
    
    // 启动计时器
    this.startTimer();
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
          promptAction.showToast({
            message: '专注时间结束！',
            duration: 3000
          });
        }
      }
    }, 1000);
  }
  
  // 播放选择的音乐
  playSelectedMusic(music: string) {
    this.selectedMusic = music;
    
    try {
      // 播放选中的音乐
      audioPlayer.play(music);
      
      promptAction.showToast({
        message: music === '无声' ? '已切换到静音模式' : `正在播放: ${music}`,
        duration: 2000
      });
    } catch (error) {
      console.error(`播放音乐失败: ${error}`);
      promptAction.showToast({
        message: '播放音乐失败，请重试',
        duration: 2000
      });
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
            // 停止音乐
            audioPlayer.stop();
            router.back();
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