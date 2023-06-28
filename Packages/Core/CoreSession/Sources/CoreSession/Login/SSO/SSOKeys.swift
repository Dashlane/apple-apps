import Foundation

public struct SSOKeys {
    public let remoteKey: Data 
    public let ssoKey: Data 
    public let authTicket: AuthTicket

    init(remoteKey: Data, ssoKey: Data, authTicket: AuthTicket) {
        self.remoteKey = remoteKey
        self.ssoKey = ssoKey
        self.authTicket = authTicket
    }
}
