import Foundation
extension AppAPIClient.Authentication {
        public struct PerformU2FVerification {
        public static let endpoint: Endpoint = "/authentication/PerformU2FVerification"

        public let api: AppAPIClient

                public func callAsFunction(login: String, challengeAnswer: ChallengeAnswer, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, challengeAnswer: challengeAnswer)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var performU2FVerification: PerformU2FVerification {
        PerformU2FVerification(api: api)
    }
}

extension AppAPIClient.Authentication.PerformU2FVerification {
        struct Body: Encodable {

                public let login: String

                public let challengeAnswer: ChallengeAnswer
    }

        public struct ChallengeAnswer: Codable, Equatable {

                public let challenge: String

                public let clientData: String

                public let signatureData: String

        public init(challenge: String, clientData: String, signatureData: String) {
            self.challenge = challenge
            self.clientData = clientData
            self.signatureData = signatureData
        }
    }
}

extension AppAPIClient.Authentication.PerformU2FVerification {
    public typealias Response = AuthenticationPerformVerificationResponse
}
