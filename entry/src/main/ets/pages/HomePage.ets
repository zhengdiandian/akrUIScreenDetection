import { HcNavBar } from '../commons/components';

@Entry
@Component
struct HomePage {
  @State message: string = 'Hello World';
  @StorageProp('topHeight') topHeight: number = 0
  @StorageProp('bottomHeight') bottomHeight: number = 0

  build() {
    Column(){
      Text()

      HcNavBar({ title: '隐私政策' })
    }
    .height('100%')
    .width('100%')
    .padding({ top: this.topHeight, bottom: this.bottomHeight })
  }
}