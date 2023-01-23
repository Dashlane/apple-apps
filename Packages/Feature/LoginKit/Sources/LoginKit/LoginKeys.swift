import Foundation
import CoreSession

public struct LoginKeys {
    public let remoteKey: CoreSession.RemoteKey?
    public let authTicket: String?

    public init(remoteKey: CoreSession.RemoteKey?, authTicket: String?) {
        self.remoteKey = remoteKey
        self.authTicket = authTicket
    }
}
