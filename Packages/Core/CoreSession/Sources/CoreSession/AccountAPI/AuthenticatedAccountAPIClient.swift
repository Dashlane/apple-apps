import Foundation
import DashTypes
import SwiftTreats

struct Empty: Codable { }

public protocol AuthenticatedAccountAPIClientProtocol {
    func accountInfo(completion: @escaping CompletionBlock<AccountInfo, Error>)
    func disableAuthenticator() async throws
}

public struct AuthenticatedAccountAPIClient: AuthenticatedAccountAPIClientProtocol {
    
        let apiClient: DeprecatedCustomAPIClient

    public init(apiClient: DeprecatedCustomAPIClient) {
        self.apiClient = apiClient
    }
    
    public func accountInfo(completion: @escaping CompletionBlock<AccountInfo, Error>) {
        apiClient.sendRequest(to: "/v1/account/AccountInfo", using: .post, input: Empty()) { (result: Result<AccountInfo, Error>) in
            switch result {
            case .failure(let error as APIErrorResponse):
                guard let apiError = error.errors.last else {
                    completion(result)
                    return
                }
                completion(.failure(apiError.accountError))
            default:
                completion(result)
            }
        }
    }
    
    public func twoFAStatus(completion: @escaping CompletionBlock<TwoFactorStatusResponse, Error>) {
        apiClient.sendRequest(to: "/v1/authentication/Get2FAStatus", using: .post, input: Empty()) { (result: Result<TwoFactorStatusResponse, Error>) in
            switch result {
            case .failure(let error as APIErrorResponse):
                guard let apiError = error.errors.last else {
                    completion(result)
                    return
                }
                completion(.failure(apiError.accountError))
            default:
                completion(result)
            }
        }
    }
    
    public func disableAuthenticator() async throws {
        let _: Empty =  try await apiClient.sendRequest(to: "/v1/authenticator/DisableAuthenticator", using: .post, input: Empty())
    }
}
