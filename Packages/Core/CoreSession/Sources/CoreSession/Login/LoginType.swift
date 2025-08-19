import CoreTypes
import Foundation

public enum LoginType {
  case localLogin(LocalLoginStateMachine)
  case remoteLogin(RemoteLoginType)
}

public enum RemoteLoginType: Hashable, Sendable {
  case regularRemoteLogin(Login, deviceRegistrationMethod: LoginMethod)
  case deviceToDeviceRemoteLogin(Login?, deviceInfo: DeviceInfo)
}
