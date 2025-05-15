import promptAction from '@ohos.promptAction';
import audioPlayer from '../common/AudioPlayer';
import router from '@ohos.router';

@Entry
@Component
struct AudioTest {
  @State musicOptions: string[] = ['无声', '轻柔钢琴', '自然雨声', '海浪声', '森林鸟鸣', '白噪音', '冥想音乐'];
  @State currentPlaying: string = '无声';
  @State volume: number = 0.5;
  @State logs: string[] = [];

  aboutToDisappear() {
    // 停止音乐播放
    audioPlayer.stop();
  }
  
  // 播放选择的音乐
  playMusic(music: string) {
    this.addLog(`尝试播放: ${music}`);
    
    try {
      // 播放选中的音乐
      audioPlayer.play(music).then(() => {
        this.addLog(`开始播放成功: ${music}`);
        this.currentPlaying = music;
      }).catch((error) => {
        this.addLog(`播放失败: ${error}`);
      });
      
      promptAction.showToast({
        message: music === '无声' ? '已切换到静音模式' : `正在播放: ${music}`,
        duration: 2000
      });
    } catch (error) {
      this.addLog(`播放异常: ${error}`);
      promptAction.showToast({
        message: '播放音乐失败，请重试',
        duration: 2000
      });
    }
  }
  
  // 添加日志
  addLog(message: string) {
    this.logs.push(`${new Date().toLocaleTimeString()}: ${message}`);
    // 最多保留50条日志
    if (this.logs.length > 50) {
      this.logs = this.logs.slice(this.logs.length - 50);
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('音频播放测试')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .linearGradient({
        angle: 90,
        colors: [['#8A2BE2', 0.0], ['#FF1493', 1.0]]
      })
      
      // 当前播放状态
      Row() {
        Text('当前播放:')
          .fontSize(18)
          .fontColor('#666666')
        
        Text(this.currentPlaying)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
      
      // 音量控制
      Row() {
        Text('音量:')
          .fontSize(18)
          .fontColor('#666666')
        
        Slider({
          value: this.volume * 100,
          min: 0,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('60%')
          .onChange((value: number) => {
            this.volume = value / 100;
            audioPlayer.setVolume(this.volume);
            this.addLog(`设置音量: ${this.volume}`);
          })
        
        Text(`${Math.floor(this.volume * 100)}%`)
          .fontSize(16)
          .fontColor('#333333')
          .width(50)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
      .justifyContent(FlexAlign.Center)
      
      // 音乐选择按钮
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.musicOptions, (music: string) => {
            Button(music)
              .width('80%')
              .height(50)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .backgroundColor(this.currentPlaying === music ? '#8A2BE2' : '#9370DB')
              .borderRadius(25)
              .onClick(() => {
                this.playMusic(music);
              })
          })
          
          // 控制按钮
          Row({ space: 16 }) {
            Button('暂停')
              .width(100)
              .height(50)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF6B6B')
              .borderRadius(25)
              .onClick(() => {
                audioPlayer.pause();
                this.addLog('暂停播放');
              })
            
            Button('恢复')
              .width(100)
              .height(50)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .backgroundColor('#4CAF50')
              .borderRadius(25)
              .onClick(() => {
                audioPlayer.resume();
                this.addLog('恢复播放');
              })
            
            Button('停止')
              .width(100)
              .height(50)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF9800')
              .borderRadius(25)
              .onClick(() => {
                audioPlayer.stop();
                this.addLog('停止播放');
                this.currentPlaying = '无声';
              })
          }
          .margin({ top: 16, bottom: 16 })
          .justifyContent(FlexAlign.Center)
          
          // 返回按钮
          Button('返回')
            .width('80%')
            .height(50)
            .fontSize(18)
            .fontColor('#FFFFFF')
            .backgroundColor('#666666')
            .borderRadius(25)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .padding(16)
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      
      // 日志区域
      Column() {
        Text('操作日志')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .padding(8)
        
        List() {
          ForEach(this.logs, (log: string, index: number) => {
            ListItem() {
              Text(log)
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .padding(4)
            }
          })
        }
        .width('100%')
        .height(200)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
} 