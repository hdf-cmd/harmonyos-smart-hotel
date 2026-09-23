// "记住我的信息"持久化存储：把 preferences 的读写隔离在这一层
//
// 【为什么要单独一层】preferences 是系统 API（依赖设备环境），
// 隔离后 LoginViewModel 的校验逻辑可以在本地单测里用替身对象跑，不碰系统 API。
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { LoginInfo } from '../model/LoginInfo'

const STORE_NAME: string = 'login_remember'
const KEY_ROOM_NO: string = 'roomNo'
const KEY_USER_NAME: string = 'userName'
const KEY_REMEMBER: string = 'rememberMe'

export class RememberMeStore {
  /**
   * 读取上次保存的登录信息；
   * 从未保存过（首次启动）返回 undefined，由调用方决定默认值
   */
  async load(context: common.Context): Promise<LoginInfo | undefined> {
    const store = preferences.getPreferencesSync(context, { name: STORE_NAME })
    if (!store.hasSync(KEY_ROOM_NO)) {
      return undefined
    }
    const info = new LoginInfo()
    info.roomNo = store.getSync(KEY_ROOM_NO, '') as string
    info.userName = store.getSync(KEY_USER_NAME, '') as string
    info.rememberMe = store.getSync(KEY_REMEMBER, true) as boolean
    return info
  }

  /**
   * 保存登录信息（未勾选"记住"时保存的是空值，保证下次打开是空的）
   */
  async save(context: common.Context, info: LoginInfo): Promise<void> {
    const store = preferences.getPreferencesSync(context, { name: STORE_NAME })
    store.putSync(KEY_ROOM_NO, info.roomNo)
    store.putSync(KEY_USER_NAME, info.userName)
    store.putSync(KEY_REMEMBER, info.rememberMe)
    await store.flush()
  }
}
