import { webview } from '@kit.ArkWeb';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fullScreen } from '../commons/utils';

@Entry
@Component
struct Index {
  webController :WebviewController = new webview.WebviewController();
  @State statusBarHeight: number = 0;
  @StorageProp('topHeight') topHeight: number = 0
  @StorageProp('bottomHeight') bottomHeight: number = 0
  // 改变设备横竖屏状态函数
  private changeOrientation(isLandscape: boolean) {
    // 获取UIAbility实例的上下文信息
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 调用该接口手动改变设备横竖屏状态
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
    });
  }
  onPageShow(): void {
    this.changeOrientation(false)
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 调用该接口手动改变设备横竖屏状态
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setWindowLayoutFullScreen(true);
    });
  }
  onPageHide(): void {
    this.changeOrientation(false)

    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 调用该接口手动改变设备横竖屏状态
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setWindowLayoutFullScreen(false);
    });
  }
  build() {
    Column(){

      // HcNavBar({ title: '用户协议', showRight: false })

      Web({src: $rawfile('index.html'), controller: this.webController})
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onFullScreenEnter((event) => {
          console.log("onFullScreenEnter...")
          this.changeOrientation(true);
        })
        .onFullScreenExit(() => {
          console.log("onFullScreenExit...")
          this.changeOrientation(false);
        })

    }
    .height('100%')
    .width('100%')
    .padding({ top: this.topHeight, bottom: this.bottomHeight })

  }
}