import DashTypes
import Foundation

public enum LoginType {
  case localLogin(LocalLoginHandler)
  case remoteLogin(RemoteLoginType)
}

public enum RemoteLoginType: Hashable {
  case regularRemoteLogin(
    Login, deviceRegistrationMethod: LoginMethod,
    deviceInfo: DeviceInfo)
  case deviceToDeviceRemoteLogin(Login?, deviceInfo: DeviceInfo)
}
