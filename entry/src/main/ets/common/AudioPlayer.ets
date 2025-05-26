import media from '@ohos.multimedia.media';
import resourceManager from '@ohos.resourceManager';

/**
 * 音频播放器类
 * 用于管理专注计时器背景音乐的播放
 */
export class AudioPlayer {
  private player: media.AVPlayer | null = null;
  private playingId: string = ''; // 当前播放的音乐ID
  private volume: number = 0.5; // 音量，0.0-1.0

  /**
   * 音乐映射表，存储音乐名称对应的音频文件路径
   */
  private musicMap: Record<string, string> = {
    '无声': '',
    '轻柔钢琴': 'rawfile/sounds/piano.mp3',
    '自然雨声': 'rawfile/sounds/rain.mp3',
    '海浪声': 'rawfile/sounds/waves.mp3',
    '森林鸟鸣': 'rawfile/sounds/forest.mp3',
    '白噪音': 'rawfile/sounds/whitenoise.mp3',
    '冥想音乐': 'rawfile/sounds/meditation.mp3'
  };

  /**
   * 单例模式 - 保存实例
   */
  private static instance: AudioPlayer;

  /**
   * 获取AudioPlayer的单例实例
   */
  public static getInstance(): AudioPlayer {
    if (!AudioPlayer.instance) {
      AudioPlayer.instance = new AudioPlayer();
    }
    return AudioPlayer.instance;
  }

  /**
   * 构造函数 - 私有，通过getInstance获取实例
   */
  private constructor() {
    // 初始化播放器
    this.initPlayer();
  }

  /**
   * 初始化播放器
   */
  private initPlayer(): void {
    if (this.player === null) {
      try {
        // 创建异步方式，等待Promise
        media.createAVPlayer().then((player: media.AVPlayer) => {
          this.player = player;
          
          if (this.player) {
            this.player.on('stateChange', (state: string) => {
              console.info(`播放器状态变化: ${state}`);
              
              if (state === 'idle') {
                // 空闲状态，可以设置源
              } else if (state === 'initialized') {
                // 已初始化，可以准备播放
                this.player?.prepare();
              } else if (state === 'prepared') {
                // 准备完成，可以开始播放
                if (this.player) {
                  this.player.setVolume(this.volume);
                  this.player.loop = true; // 设置循环播放
                  this.player.play();
                }
              } else if (state === 'playing') {
                // 正在播放
                console.info('音频正在播放中');
              } else if (state === 'paused') {
                // 已暂停
                console.info('音频已暂停');
              } else if (state === 'completed') {
                // 播放完成
                console.info('音频播放完成');
              } else if (state === 'stopped') {
                // 已停止
                console.info('音频已停止');
              } else if (state === 'error') {
                // 错误状态
                console.error('播放器发生错误');
              }
            });
          }
        }).catch(() => {
          console.error('创建播放器失败');
        });
      } catch {
        console.error('创建播放器异常');
      }
    }
  }

  /**
   * 播放指定的音乐
   * @param musicId 音乐ID（名称）
   */
  public async play(musicId: string): Promise<void> {
    // 如果是无声，则停止播放
    if (musicId === '无声') {
      this.stop();
      this.playingId = musicId;
      return;
    }

    // 先停止当前播放（无论是否同一首）
    this.stop();

    try {
      if (!this.player) {
        // 初始化播放器并等待一段时间
        this.initPlayer();
        // 使用超时等待播放器初始化
        const delay = (ms: number): Promise<void> => {
          return new Promise<void>((resolve) => {
            setTimeout(resolve, ms);
          });
        };
        await delay(500);
        if (!this.player) {
          throw new Error('播放器初始化失败');
        }
      }

      // 获取对应的音频文件路径
      const soundPath = this.musicMap[musicId];
      if (!soundPath) {
        console.error(`找不到音乐: ${musicId}`);
        return;
      }

      console.info(`准备加载音频文件: ${soundPath}`);

      // 设置音频源
      try {
        const context = getContext(this);
        
        // 创建资源管理器
        const resourceMgr = context.resourceManager;
        
        try {
          // 获取原始文件描述符
          const rawFd: resourceManager.RawFileDescriptor = await resourceMgr.getRawFd(soundPath);
          console.info(`成功获取文件描述符: ${soundPath}, fd: ${rawFd.fd}`);
          
          if (this.player) {
            // 设置文件描述符作为音频源
            this.player.fdSrc = {
              fd: rawFd.fd,
              offset: rawFd.offset,
              length: rawFd.length
            };
            
            this.playingId = musicId;
            console.info(`音频源设置成功: ${musicId}`);
            // 播放操作会在stateChange事件中根据状态自动处理
          }
        } catch {
          console.error('获取文件描述符失败');
          
          // 尝试使用媒体资源作为备选方案
          try {
            if (this.player && resourceMgr) {
              // 由于API限制，使用替代方法加载资源
              this.player.reset();
              
              // 尝试使用URI方式设置音频源
              const rawFileUri: string = `internal://app/${soundPath}`;
              this.player.url = rawFileUri;
              this.playingId = musicId;
              console.info(`使用URL方式设置音频源: ${musicId}, url: ${rawFileUri}`);
            }
          } catch {
            console.error('使用URL方式设置音频源失败');
            throw new Error(`无法加载音频: ${musicId}`);
          }
        }
      } catch {
        console.error('设置音频源失败');
        throw new Error(`设置音频源失败: ${musicId}`);
      }
    } catch {
      console.error('播放音乐出错');
      this.playingId = '';
      throw new Error(`播放音乐失败: ${musicId}`);
    }
  }

  /**
   * 停止播放
   */
  public stop(): void {
    if (this.player) {
      try {
        if (this.isPlaying() || this.isPaused()) {
          this.player.stop();
          this.player.reset();
          console.info('音频播放已停止');
        }
        this.playingId = '';
      } catch {
        console.error('停止播放出错');
      }
    }
  }

  /**
   * 暂停播放
   */
  public pause(): void {
    if (this.player && this.isPlaying()) {
      try {
        this.player.pause();
        console.info('音频播放已暂停');
      } catch {
        console.error('暂停播放出错');
      }
    }
  }

  /**
   * 恢复播放
   */
  public resume(): void {
    if (this.player && this.isPaused()) {
      try {
        this.player.play();
        console.info('音频播放已恢复');
      } catch {
        console.error('恢复播放出错');
      }
    }
  }

  /**
   * 设置音量
   * @param volume 音量值，范围0.0-1.0
   */
  public setVolume(volume: number): void {
    if (volume < 0) volume = 0;
    if (volume > 1) volume = 1;
    
    this.volume = volume;
    if (this.player) {
      try {
        this.player.setVolume(volume);
        console.info(`音量已设置为: ${volume}`);
      } catch {
        console.error('设置音量出错');
      }
    }
  }

  /**
   * 判断是否正在播放
   */
  private isPlaying(): boolean {
    return this.player?.state === 'playing';
  }

  /**
   * 判断是否已暂停
   */
  private isPaused(): boolean {
    return this.player?.state === 'paused';
  }

  /**
   * 释放资源
   */
  public release(): void {
    if (this.player) {
      try {
        this.player.release();
        this.player = null;
        this.playingId = '';
        console.info('播放器资源已释放');
      } catch {
        console.error('释放播放器资源出错');
      }
    }
  }

  /**
   * 获取当前播放的音乐ID
   */
  public getCurrentMusic(): string {
    return this.playingId;
  }
}

export default AudioPlayer.getInstance(); 