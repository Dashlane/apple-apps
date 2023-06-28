import Foundation
import SwiftTreats
import DashTypes

public struct TestAccountAPIClient {
    private static let tokenEndpoint = "/v1/authentication-qa/GetDeviceRegistrationTokenForTestLogin"
    private static let allTokensEndpoint = "/v1/authentication-qa/GetAllTokensForTestLogin"

    private struct TokenRequest: Encodable {
        let login: String
    }

    public struct TokenResponse: Decodable {
        public let token: String
    }

    public struct AllTokensResponse: Decodable {
        public let teamInviteTokens: [TokenResponse]
        public let teamFreeTrialTokens: [TokenResponse]
        public let emailSubscriptionTokens: [TokenResponse]
    }

    let engine: DeprecatedCustomAPIClient

    public init(engine: DeprecatedCustomAPIClient) {
        self.engine = engine
    }

        public func token(for login: Login) async throws -> String {
        let response: TokenResponse = try await engine.sendRequest(to: Self.tokenEndpoint,
                                                                   using: .post,
                                                                   input: TokenRequest(login: login.email))

        return response.token
    }

        public func allTeamTokens(for login: Login) async throws -> AllTokensResponse {
        let response: AllTokensResponse = try await engine.sendRequest(to: Self.allTokensEndpoint,
                                                                       using: .post,
                                                                       input: TokenRequest(login: login.email))

        return response
    }
}
