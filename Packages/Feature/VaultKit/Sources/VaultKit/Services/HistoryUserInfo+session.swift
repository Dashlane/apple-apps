import CorePersonalData
import CoreSession
import DashTypes
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
