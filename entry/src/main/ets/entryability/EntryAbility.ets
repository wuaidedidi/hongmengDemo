/**
 * 🚀 应用入口能力类 (EntryAbility)
 * 
 * 这是鸿蒙应用的主入口，负责管理应用的生命周期
 * 继承自UIAbility，是应用与系统交互的核心组件
 * 
 * 主要职责：
 * - 应用启动和销毁管理
 * - 窗口创建和配置
 * - 前后台切换处理
 * - 系统事件响应
 */

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

// 日志域标识符，用于过滤和分类日志
const DOMAIN = 0x0000;

/**
 * 应用入口能力类
 * 
 * 🔥 核心概念：
 * - UIAbility：鸿蒙应用的基本运行单元
 * - 生命周期：onCreate → onWindowStageCreate → onForeground → onBackground → onDestroy
 * - Want：应用启动意图，包含启动信息
 */
export default class EntryAbility extends UIAbility {
  
  /**
   * 📱 应用创建回调
   * 
   * 当应用首次启动时调用，用于应用级别的初始化
   * 
   * @param want - 启动意图，包含启动应用的相关信息
   * @param launchParam - 启动参数，包含启动类型等信息
   */
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 设置应用的颜色模式为未设置状态，跟随系统
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', '✅ 应用创建成功 - Ability onCreate');
  }

  /**
   * 🗑️ 应用销毁回调
   * 
   * 当应用被系统销毁时调用，用于清理资源
   */
  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', '🔚 应用销毁 - Ability onDestroy');
  }

  /**
   * 🪟 窗口阶段创建回调
   * 
   * 当主窗口创建完成时调用，这是设置页面内容的最佳时机
   * 
   * @param windowStage - 窗口舞台对象，用于管理窗口和页面
   */
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', '🪟 窗口阶段创建 - onWindowStageCreate');

    // 加载主页面内容 - 这里指定了应用的入口页面
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', '❌ 页面加载失败: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', '%{public}s', '✅ 页面加载成功');
    });
  }

  /**
   * 🪟 窗口阶段销毁回调
   * 
   * 当主窗口销毁时调用，用于释放UI相关资源
   */
  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', '🪟 窗口阶段销毁 - onWindowStageDestroy');
  }

  /**
   * ⬆️ 应用前台回调
   * 
   * 当应用从后台切换到前台时调用
   */
  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', '⬆️ 应用切换到前台 - onForeground');
  }

  /**
   * ⬇️ 应用后台回调
   * 
   * 当应用从前台切换到后台时调用
   */
  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', '⬇️ 应用切换到后台 - onBackground');
  }
}