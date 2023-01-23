import Foundation

public struct AuthenticationCompleteWithTOPVerification: Codable, Equatable {

        public let otp: String

    public init(otp: String) {
        self.otp = otp
    }
}
