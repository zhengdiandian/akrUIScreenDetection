import { promptAction, router } from '@kit.ArkUI'

export * from './Logger'
export * from './FullScreen'
export * from './StatusBar'
export  * from './Permission'
export  * from './AudioDB'

const day = 60 * 60 * 24
const hour = 60 * 60
const min = 60

export const formatTime = (second: number = 0) => {
  if (second > day) {
    return (second / day).toFixed(1) + '天'
  } else if (second > hour) {
    return (second / hour).toFixed(1) + '小时'
  } else {
    return (second / min).toFixed(0) + '分钟'
  }
}
interface ClockRes {
  clockinNumbers: number
}


export function assign(target: Record<string, Object>, ...source: Object[]): Record<string, Object> {
  for (const items of source) {
    for (const key of Object.keys(items)) {
      target[key] = Reflect.get(items, key)
    }
  }
  return target;
}