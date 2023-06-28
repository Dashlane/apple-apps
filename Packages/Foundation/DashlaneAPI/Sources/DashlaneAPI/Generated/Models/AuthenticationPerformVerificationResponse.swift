import Foundation

public struct AuthenticationPerformVerificationResponse: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case authTicket = "authTicket"
    }

        public let authTicket: String

    public init(authTicket: String) {
        self.authTicket = authTicket
    }
}
