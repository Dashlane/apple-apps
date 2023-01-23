import Foundation

public struct AuthenticationPerformVerificationResponse: Codable, Equatable {

        public let authTicket: String

    public init(authTicket: String) {
        self.authTicket = authTicket
    }
}
