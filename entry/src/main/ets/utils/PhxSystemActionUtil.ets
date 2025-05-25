import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';

const SETTING_BUNDLE_NAME = 'com.huawei.hmos.settings';
const SETTING_ABILITY_NAME = 'com.huawei.hmos.settings.MainAbility';
const SETTING_LOCATION = 'location_manager_settings';
const SETTING_APP = 'application_info_entry';

export class PhxSystemActionUtil {
  private constructor() {}

  // 跳转应用详情页
  public static goAppInfoSetting(context: common.UIAbilityContext) {
    try {
      const want: Want = {
        bundleName: SETTING_BUNDLE_NAME,
        abilityName: SETTING_ABILITY_NAME,
        uri: SETTING_APP,
        parameters: { pushParams: context.applicationInfo.name }
      };
      context.startAbility(want);
    } catch (e) {
      console.error('跳转应用详情页失败: ' + (e as Error).message);
    }
  }

  // 跳转定位设置页
  public static goLocationSetting(context: common.UIAbilityContext) {
    try {
      const want: Want = {
        bundleName: SETTING_BUNDLE_NAME,
        abilityName: SETTING_ABILITY_NAME,
        uri: SETTING_LOCATION
      };
      context.startAbility(want);
    } catch (e) {
      console.error('跳转定位设置页失败: ' + (e as Error).message);
    }
  }
} 