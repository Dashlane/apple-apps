import Foundation

public struct SSOKeys {
    public let remoteKey: Data 
    public let ssoKey: Data 
    public let authTicket: String
    
    init(remoteKey: Data, ssoKey: Data, authTicket: String) {
        self.remoteKey = remoteKey
        self.ssoKey = ssoKey
        self.authTicket = authTicket
    }
}
