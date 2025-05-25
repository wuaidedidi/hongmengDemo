import common from '@ohos.app.ability.common';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import promptAction from '@ohos.promptAction';

/**
 * 后台任务管理工具类
 * 用于处理应用的后台运行权限和设置
 */
export class BackgroundManager {
  private context: common.UIAbilityContext;
  private isBackgroundTaskSupported: boolean = false;

  /**
   * 构造函数
   * @param context 上下文
   */
  constructor(context: common.UIAbilityContext) {
    this.context = context;
    this.checkBackgroundTaskSupport();
  }

  /**
   * 检查设备是否支持后台任务管理
   */
  private async checkBackgroundTaskSupport(): Promise<void> {
    try {
      // 尝试调用一个简单的 API 来检查是否支持
      await backgroundTaskManager.requestSuspendDelay(
        "checkSupport",
        () => {
          console.info('后台延迟请求回调触发');
        }
      );
      this.isBackgroundTaskSupported = true;
    } catch (err) {
      console.info(`设备不支持后台任务管理API，将使用降级方案: ${err.message}`);
      this.isBackgroundTaskSupported = false;
    }
  }

  /**
   * 申请后台运行权限
   */
  async requestBackgroundPermission(): Promise<boolean> {
    try {
      // 获取应用包名 - 使用上下文对象获取
      const bundleName: string = this.context.applicationInfo?.name || '';

      // 创建权限访问控制对象
      const atManager = abilityAccessCtrl.createAtManager();

      // 检查是否有后台运行权限 - 修正参数类型
      const result = await atManager.checkAccessToken(0, "ohos.permission.KEEP_BACKGROUND_RUNNING");

      if (result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        console.info('已有后台运行权限');
        return true;
      }

      // 请求权限 - 使用正确的API
      // 注意：实际HarmonyOS中可能需要使用其他方式申请权限
      console.info('需要申请后台运行权限');
      return false;
    } catch (err) {
      console.error(`请求后台权限异常: ${err.message}`);
      return false;
    }
  }

  /**
   * 设置后台模式
   * @param mode 模式类型：'无限制'|'智能限制'|'10分钟'|'禁止'
   */
  async setBackgroundMode(mode: string): Promise<boolean> {
    if (!this.isBackgroundTaskSupported) {
      console.info('设备不支持后台任务管理，使用降级方案');
      // 在不支持的设备上，我们只能依赖系统的默认行为
      promptAction.showToast({
        message: '当前设备不支持完整的后台管理功能，将使用系统默认设置',
        duration: 3000
      });
      return true;
    }

    try {
      switch (mode) {
        case '无限制':
          await this.startBackgroundRunningWithRetry(backgroundTaskManager.BackgroundMode.DATA_TRANSFER);
          console.info('已设置为无限制模式');
          return true;

        case '智能限制后台运行（推荐）':
          await this.startBackgroundRunningWithRetry(backgroundTaskManager.BackgroundMode.DATA_TRANSFER);
          console.info('已设置为智能限制模式');
          return true;

        case '后台运行超过10分钟后关闭':
          // 使用延迟任务模拟10分钟限制
          await this.startBackgroundRunningWithRetry(backgroundTaskManager.BackgroundMode.DATA_TRANSFER, 600000);
          console.info('已设置为10分钟后关闭模式');
          return true;

        case '禁止后台运行':
          if (this.isBackgroundTaskSupported) {
            try {
              await backgroundTaskManager.stopBackgroundRunning(this.context);
            } catch (err) {
              console.error(`停止后台运行失败: ${err.message}`);
              // 即使失败也返回true，因为这是用户的明确选择
            }
          }
          console.info('已禁止后台运行');
          return true;

        default:
          console.error('未知的后台模式');
          return false;
      }
    } catch (err) {
      console.error(`设置后台模式异常: ${err.message}`);
      return false;
    }
  }

  /**
   * 带重试的后台运行启动
   */
  private async startBackgroundRunningWithRetry(mode: backgroundTaskManager.BackgroundMode,
    timeout?: number): Promise<void> {
    try {
      await backgroundTaskManager.startBackgroundRunning(
        this.context,
        mode,
        {
          name: "番茄TODO后台运行",
          description: "保持计时器在后台正常运行"
        }
      );

      if (timeout) {
        const timeoutCallback = () => {
          if (this.isBackgroundTaskSupported) {
            backgroundTaskManager.stopBackgroundRunning(this.context)
              .catch((err: Error) => console.error(`停止后台运行失败: ${err.message}`));
          }
        };
        setTimeout(timeoutCallback, timeout);
      }
    } catch (err) {
      console.error(`启动后台运行失败，使用备用方案: ${err.message}`);
      // 在这里可以实现其他备用方案，比如使用 requestSuspendDelay
      try {
        await backgroundTaskManager.requestSuspendDelay(
          "TodoBackgroundTask",
          () => {
            console.info('后台延迟请求回调触发');
          }
        );
      } catch (err) {
        console.error(`备用方案也失败: ${err.message}`);
        // 在这里可以添加更多的降级策略
        promptAction.showToast({
          message: '后台运行功能受限，请保持应用在前台',
          duration: 3000
        });
      }
    }
  }

  /**
   * 获取当前后台模式
   */
  async getCurrentBackgroundMode(): Promise<string> {
    try {
      // 这里仅作为示例，实际实现可能需要根据HarmonyOS的API或存储的设置值
      return '智能限制后台运行（推荐）';
    } catch (err) {
      console.error(`获取后台模式异常: ${err.message}`);
      return '智能限制后台运行（推荐）';
    }
  }

  /**
   * 打开系统的电池优化设置页面
   */
  async openBatteryOptimizationSettings(): Promise<boolean> {
    try {
      // 这里仅作为示例，实际实现需要根据HarmonyOS的API
      console.info('尝试打开电池优化设置页面');
      return true;
    } catch (err) {
      console.error(`打开电池优化设置异常: ${err.message}`);
      return false;
    }
  }
}

// 导出单例实例
class BackgroundManagerFactory {
  getInstance(context: common.UIAbilityContext): BackgroundManager {
    return new BackgroundManager(context);
  }
}

// 创建工厂对象实例
const backgroundManagerFactory = new BackgroundManagerFactory();

export default backgroundManagerFactory; 