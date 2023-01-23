import Foundation
import CoreSession
import CorePersonalData
import DashTypes
import SwiftTreats

public extension HistoryUserInfo {
    init(session: Session) {
        self.init(platform: System.systemName,
                  deviceName: Device.name,
                  user: session.login.email)
    }
}
