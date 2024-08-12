import DashTypes
import Foundation
import UIKit

protocol NotificationInfoContainer {
  var userInfo: [AnyHashable: Any] { get }
}

extension UNNotification: NotificationInfoContainer {
  var userInfo: [AnyHashable: Any] {
    return request.content.userInfo
  }
}

extension RemoteNotification: NotificationInfoContainer {}

extension NotificationInfoContainer {
  subscript<T, Key: RawRepresentable>(infoKey infoKey: Key, type type: T.Type) -> T?
  where Key.RawValue == String {
    return userInfo[infoKey.rawValue] as? T
  }

  func hasCode(_ code: NotificationCode) -> Bool {
    guard let rawCode = self[infoKey: NotificationInfoKey.code, type: Int.self],
      let infoCode = NotificationCode(rawValue: rawCode)
    else {
      return false
    }

    return code == infoCode
  }

  func hasName(_ name: NotificationName) -> Bool {
    guard let rawName = self[infoKey: NotificationInfoKey.name, type: String.self],
      let infoName = NotificationName(rawValue: rawName)
    else {
      return false
    }

    return infoName == name
  }

  func hasLogin(_ login: Login) -> Bool {
    guard let notificationLogin = self[infoKey: NotificationInfoKey.login, type: String.self] else {
      return true
    }

    return notificationLogin == login.email
  }
}
