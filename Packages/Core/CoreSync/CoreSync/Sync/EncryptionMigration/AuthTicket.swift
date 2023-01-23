import Foundation

public struct AuthTicket {
    public let token: String
    public let verification: Verification
    
    public init(token: String, verification: Verification) {
        self.token = token
        self.verification = verification
    }
}
