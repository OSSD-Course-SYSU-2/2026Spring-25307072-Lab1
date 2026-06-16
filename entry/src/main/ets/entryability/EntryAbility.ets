import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 接收从其他设备迁移过来的游戏状态
    if (want.parameters && want.parameters.gameState) {
      AppStorage.setOrCreate('migrateState', want.parameters.gameState);
    } else {
      AppStorage.setOrCreate('migrateState', null);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 当页面已存在，又收到新的迁移数据时
    if (want.parameters && want.parameters.gameState) {
      AppStorage.setOrCreate('migrateState', want.parameters.gameState);
    }
  }

  onContinue(wantParam: Record<string, Object>) {
    // 取出页面保存的最新游戏状态，放入迁移数据
    let state = AppStorage.get('saveState') as string;
    if (state) {
      wantParam.gameState = state;
    }
    return AbilityConstant.OnContinueResult.AGREE;
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded in loading the content. Data: ' + JSON.stringify(data));
    });
  }
}