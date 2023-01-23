import Foundation
import DashTypes

struct AuthenticatorAPIClient {
    let apiClient: DeprecatedCustomAPIClient
    
    init(apiClient: DeprecatedCustomAPIClient) {
        self.apiClient = apiClient
    }
    
    func validateRequest(with info: ValidateRequestInfo) async throws {
        let _: Empty = try await apiClient.sendRequest(to: "v1/authenticator/ValidateRequest",
                               using: .post,
                               input: info)
    }
}

fileprivate struct Empty: Codable {}

struct ValidateRequestInfo: Encodable {
    let requestId: String
    let approval: Approval
    let deviceAccessKey: String
}

struct Approval: Encodable {
    enum Status: String, Encodable {
        case approved
        case rejected
    }
    let status: Status
    let isSuspicious: Bool?
}

