import { HcNavBar } from '../commons/components';
import { webview } from '@kit.ArkWeb';
import { fullScreen } from '../commons/utils';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct PrivacyAgreementPage {
  @StorageProp('topHeight') topHeight: number = 0
  @StorageProp('bottomHeight') bottomHeight: number = 0
  webController :WebviewController = new webview.WebviewController();
  onPageShow(): void {

  }
  aboutToAppear(): void {
    // fullScreen.disable()

  }
  onPageHide(): void {
    // fullScreen.enable()

  }
  build() {

    Column(){
      // Text(this.topHeight.toString())
      HcNavBar({ title: '隐私政策' })

      Stack() {
        Web({src: $rawfile('privacy.html'), controller: this.webController})

        Button() {
          Text('开始')
            .fontSize(16)
            .fontColor('#ffffff')
            .fontWeight(800)

        }
        .width(60)
        .height(60)
        .position({x: '80%', y: 600})
        .shadow({radius: 10})
        .onClick(() => {
          // 需要执行的操作
          router.pushUrl({
            url: 'pages/Index'
          })
        })
      }
    }
    // .height('100%')
    .height('100%')
    .width('100%')
    .padding({ top: this.topHeight, bottom: this.bottomHeight })


  }

}