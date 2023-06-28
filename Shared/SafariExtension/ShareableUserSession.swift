import Foundation
import CoreSession

public struct ShareableUserSession: Codable {

    let login: String
    let masterPassword: String?
    let remoteKey: Data?
    let serverKey: String?
    
    init(_ session: Session) {
        login = session.login.email

        switch session.authenticationMethod.sessionKey {
        case let .masterPassword(masterPassword, serverKey):
            self.masterPassword = masterPassword
            self.serverKey = serverKey
            self.remoteKey = nil
        case let .ssoKey(remoteKey):
            self.masterPassword = nil
            self.remoteKey = remoteKey
            self.serverKey = nil
        }
    }
}

extension ShareableUserSession: Equatable {
    public static func == (lhs: ShareableUserSession, rhs: ShareableUserSession) -> Bool {
        return lhs.login == rhs.login
            && lhs.masterPassword == rhs.masterPassword
            && lhs.remoteKey == rhs.remoteKey
            && lhs.serverKey == rhs.serverKey
    }
}
