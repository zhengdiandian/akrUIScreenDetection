import { router, Prompt } from '@kit.ArkUI';
import { advertising, identifier } from '@kit.AdsKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { TAG } from '@ohos/hypium/src/main/Constant';

@Entry
@Component
export struct Index {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private oaid: string = '';
  // 超时时间(单位毫秒)，开发者可根据实际情况修改
  private timeOutDuration: number = 1 * 1000;
  // 超时index
  private timeOutIndex: number = -1;
  // 广告展示参数
  private adDisplayOptions: advertising.AdDisplayOptions = {
    // 是否静音，默认不静音
    mute: false
  }
  // 广告配置
  private adOptions: advertising.AdOptions = {
    // 是否允许流量下载0：不允许，1：允许，不设置以广告主设置为准
    allowMobileTraffic: 0,
    // 是否希望根据 COPPA 的规定将您的内容视为面向儿童的内容: -1默认值，不确定 0不希望 1希望
    tagForChildProtection: -1,
    // 是否希望按适合未达到法定承诺年龄的欧洲经济区 (EEA) 用户的方式处理该广告请求： -1默认值，不确定 0不希望 1希望
    tagForUnderAgeOfPromise: -1,
    // 设置广告内容分级上限: W: 3+,所有受众 PI: 7+,家长指导 J:12+,青少年 A: 16+/18+，成人受众
    adContentClassification: 'A'
  }
  // 开屏视频广告请求参数
  private splashVideoAdReqParams: advertising.AdRequestParams = {
    // 'testd7c5cewoj6'为测试专用的广告位ID，App正式发布时需要改为正式的广告位ID
    adId: 'testd7c5cewoj6',
    adType: AdType.SPLASH_AD,
    adCount: 1,
    oaid: this.oaid
  }
  // 开屏图片广告请求参数
  private splashImageAdReqParams: advertising.AdRequestParams = {
    // 'testq6zq98hecj'为测试专用的广告位ID，App正式发布时需要改为正式的广告位ID
    adId: 'testq6zq98hecj',
    adType: AdType.SPLASH_AD,
    adCount: 1,
    oaid: this.oaid
  }

  aboutToAppear() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Start to aboutToAppear');
    try {
      // 使用Promise回调方式获取OAID
      identifier.getOAID().then((data: string) => {
        this.oaid = data;
        hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded in getting adsIdentifierInfo by promise');
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'testTag', '%{public}s',
          `Failed to get adsIdentifierInfo, code: ${error.code}, message: ${error.message}`);
      })
    } catch (error) {
      hilog.error(0x0000, 'testTag', '%{public}s', `Catch err, code: ${error.code}, message: ${error.message}`);
    }
  }

  build() {
    Column() {
      Column() {
        // 跳转到开屏全屏视频广告展示页面
        CustomButton({
          mText: 'splash full screen request', mOnClick: () => {
            this.requestAd(this.splashVideoAdReqParams, this.adOptions);
          }
        });

        // 跳转到开屏半屏图片广告展示页面
        CustomButton({
          mText: 'splash half screen request', mOnClick: () => {
            this.requestAd(this.splashImageAdReqParams, this.adOptions);
          }
        });
      }.width('100%').height('80%').justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  private requestAd(adReqParams: advertising.AdRequestParams, adOptions: advertising.AdOptions): void {
    // 广告请求回调监听
    const adLoaderListener: advertising.AdLoadListener = {
      // 广告请求失败回调
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        clearTimeout(this.timeOutIndex);
        hilog.error(0x0000, 'testTag', '%{public}s',
          `Failed to request ad. errorCode is: ${errorCode}, errorMsg is: ${errorMsg}`);
        Prompt.showToast({
          message: `Failed to request ad, code is:  ${errorCode} , errorMsg is: ${errorMsg}`,
          duration: 1000
        });
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        clearTimeout(this.timeOutIndex);
        hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded in requesting ad!');
        // 保存请求到的广告内容用于展示
        hilog.info(0x0000, 'testTag', '%{public}s', `ads[0].adType is : ${ads[0].adType}`);
        if (canIUse("SystemCapability.Advertising.Ads")) {
          if (ads[0].adType === AdType.SPLASH_AD) {
            // 调用开屏广告展示页面
            if (ads[0]?.isFullScreen === true) {
              routePage('pages/SplashFullScreenAdPage', ads, this.adDisplayOptions);
            } else {
              routePage('pages/SplashHalfScreenAdPage', ads, this.adDisplayOptions);
            }
          } else {
            hilog.error(0x0000, 'testTag', '%{public}s', 'Error adType');
          }
        }
      }
    };
    // 创建AdLoader广告对象
    const load: advertising.AdLoader = new advertising.AdLoader(this.context);
    // 调用广告请求接口
    hilog.info(0x0000, 'testTag', '%{public}s', 'Request ad!');
    adReqParams.oaid = this.oaid;
    this.timeOutHandler();
    load.loadAd(adReqParams, adOptions, adLoaderListener);

  }
  private timeOutHandler(): void {
    // 超时处理
    this.timeOutIndex = setTimeout(() => {
      const options: router.RouterOptions = {
        // 开发者可根据项目实际情况修改超时之后要跳转的目标页面
        url: 'pages/Index',
      }
      router.pushUrl(options);
      hilog.error(0x0000, TAG, '%{public}s', 'load ad time out');
    }, this.timeOutDuration);
  }
}



async function routePage(pageUri: string, ads: Array<advertising.Advertisement | null>,
  displayOptions: advertising.AdDisplayOptions) {
  let options: router.RouterOptions = {
    url: pageUri,
    params: {
      ads: ads,
      displayOptions: displayOptions
    }
  }
  try {
    hilog.info(0x0000, 'testTag', '%{public}s', `RoutePage: ${pageUri}`);
    router.pushUrl(options);
  } catch (error) {
    hilog.error(0x0000, 'testTag', '%{public}s',
      `Failed to routePage callback, code: ${error.code}, msg: ${error.message}`);
  }
}

export enum AdType {
  // 开屏广告的类型
  SPLASH_AD = 1
}

@Component
export struct CustomButton {
  private mText: string | Resource = '';
  private mHeight: number = 40;
  private mOnClick: (event?: ClickEvent) => void = (): void => {
  };

  build() {
    Column() {
      Button(this.mText)
        .backgroundColor('#d3d4d6')
        .fontSize(20)
        .fontColor('#000')
        .fontWeight(FontWeight.Normal)
        .align(Alignment.Center)
        .type(ButtonType.Capsule)
        .width('90%')
        .height(this.mHeight)
        .margin({ top: 10, bottom: 5 })
        .onClick(this.mOnClick);
    }
  }
}