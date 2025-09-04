import CorePersonalData
import CoreSession
import CoreTypes
import Foundation
import SwiftTreats

extension HistoryUserInfo {
  public init(session: Session) {
    self.init(
      platform: System.systemName,
      deviceName: Device.name,
      user: session.login.email)
  }
}
