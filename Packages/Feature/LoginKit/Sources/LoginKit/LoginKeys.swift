import Foundation
import CoreSession

public struct LoginKeys {
    public let remoteKey: CoreSession.RemoteKey?
    public let authTicket: CoreSession.AuthTicket

    public init(remoteKey: CoreSession.RemoteKey?, authTicket: AuthTicket) {
        self.remoteKey = remoteKey
        self.authTicket = authTicket
    }
}
