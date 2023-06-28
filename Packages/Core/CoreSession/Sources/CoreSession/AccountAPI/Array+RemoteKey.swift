import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

extension Array where Element == RemoteKey {
    func ssoRemoteKey() -> RemoteKey? {
        return self.first(where: { key in
            if key.type == .sso {
                return true
            }
            return false
        })
    }

    func masterPasswordRemoteKey() -> RemoteKey? {
        return self.first(where: { key in
            if key.type == .masterPassword {
                return true
            }
            return false
        })
    }
}
