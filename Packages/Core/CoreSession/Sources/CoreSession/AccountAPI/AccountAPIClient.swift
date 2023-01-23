import Foundation
import DashTypes
import SwiftTreats

public struct AccountAPIClient: AccountAPIClientProtocol {
    
    let apiClient: DeprecatedCustomAPIClient
    
    public init(apiClient: DeprecatedCustomAPIClient) {
        self.apiClient = apiClient
    }
    
        public func create(with accountInfo: AccountCreationInfo, completion: @escaping CompletionBlock<AccountCreationResponse, Error>) {
        apiClient.sendRequest(to: "/v1/account/CreateUser", using: .post, input: accountInfo) { (result: Result<AccountCreationResponse, Error>) in
            switch result {
            case .failure(let error as APIErrorResponse):
                guard let apiError = error.errors.last else {
                    completion(result)
                    return
                }
                completion(.failure(apiError.accountCreationError))
            default:
                completion(result)
            }
            
        }
    }
    
        public func createSSOUser(with accountInfo: SSOAccountCreationInfos, completion: @escaping CompletionBlock<AccountCreationResponse, Error>) {
        apiClient.sendRequest(to: "/v1/account/CreateUserWithSSO", using: .post, input: accountInfo) { (result: Result<AccountCreationResponse, Error>) in
            switch result {
            case .failure(let error as APIErrorResponse):
                guard let apiError = error.errors.last else {
                    completion(result)
                    return
                }
                completion(.failure(apiError.accountCreationError))
            default:
                completion(result)
            }
            
        }
    }
    
            public func verifyExistence(of login: Login, completion: @escaping CompletionBlock<AccountAvailabilityResponse, Error>) {
        apiClient.sendRequest(to: "/v1/account/RequestAccountCreation", using: .post, input: LoginInfo(login: login.email)) { (result: Result<AccountAvailabilityResponse, Error>) in
            switch result {
            case .success(let response):
                switch response.exists {
                case .invalid:
                    completion(.failure(AccountExistsError.invalidValue))
                case .unlikely:
                    completion(.failure(AccountExistsError.unlikelyValue))
                default:
                    completion(result)
                }
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
    
            public func requestToken(for login: Login) async throws {
        let _: Empty = try await apiClient.sendRequest(to: "/v1/authentication/RequestEmailTokenVerification", using: .post, input: LoginInfo(login: login.email))
    }
    
            public func requestDeviceRegistration(for login: Login) async throws -> LoginResponse {
        do {
            let result: LoginResponse = try await apiClient.sendRequest(to: "v1/authentication/GetAuthenticationMethodsForDevice", using: .post, input: DeviceRegistrationInfo(login: login.email, methods: [.token, .authenticator, .duoPush, .totp]))
            return result
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        }
    }
    
            public func registerDevice(with deviceRegistrationInfo: CompleteDeviceRegistrationRequest) async throws -> CompleteDeviceRegistrationResponse {
        do {
            let result: CompleteDeviceRegistrationResponse = try await apiClient.sendRequest(to: "v1/authentication/CompleteDeviceRegistrationWithAuthTicket", using: .post, input: deviceRegistrationInfo)
            return result
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        }
    }
    
    public func requestLogin(with loginInfo: LoginRequestInfo) async throws -> LoginResponse {
        return try await requestLogin(with: loginInfo, timeout: nil)
    }
    
    public func requestLogin(with loginInfo: LoginRequestInfo, timeout: TimeInterval?) async throws -> LoginResponse {
        let result: LoginResponse = try await apiClient.sendRequest(to: "v1/authentication/GetAuthenticationMethodsForLogin",
                                                                    using: .post,
                                                                    input: loginInfo,
                                                                    timeout: timeout)
        return result
    }
    
    public func performVerification<T: PerformVerificationRequest>(with verificationInfo: T) async throws -> PerformVerificationResponse {
        do {
            let result: PerformVerificationResponse = try await apiClient.sendRequest(to: T.endPoint, using: .post, input: verificationInfo)
            return result
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        } catch let error as URLError where error.code == .timedOut {
            throw AccountError.verificationtimeOut
        }
    }
    
    public func login(with loginInfo: CompleteLoginRequestInfo) async throws -> String {
        do {
            let result: ServerKeyResponse = try await apiClient.sendRequest(to: "v1/authentication/CompleteLoginWithAuthTicket", using: .post, input: loginInfo)
            return result.serverKey
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        }
    }
    
    public func loginForRemoteKey(with loginInfo: CompleteLoginRequestInfo) async throws -> RemoteKeyResponse {
        do {
            let result: RemoteKeyResponse = try await apiClient.sendRequest(to: "/v1/authentication/CompleteLoginWithAuthTicket", using: .post, input: loginInfo)
            return result
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        }
    }
    
    public func requestTOTPActivation(with request: TOTPActivationRequest) async throws -> TOTPActivationResponse {
        do {
            let result: TOTPActivationResponse = try await apiClient.sendRequest(to: "/v1/authentication/RequestTOTPActivation", using: .post, input: request)
            return result
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        }
    }
    
    public func completeTOTPActivation(withAuthTicket authticket: String) async throws {
        do {
            let _: Empty = try await apiClient.sendRequest(to: "/v1/authentication/CompleteTOTPActivation", using: .post, input: AuthTicket(authTicket: authticket))
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        }
    }
    
    public func deactivateTOTP(withAuthTicket authTicket: String) async throws {
        do {
            let _: Empty = try await apiClient.sendRequest(to: "/v1/authentication/DeactivateTOTP", using: .post, input: AuthTicket(authTicket: authTicket))
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        }
    }
    
    public func twoFAStatus() async throws -> TwoFAStatus {
        do {
            let result: TwoFAStatus = try await apiClient.sendRequest(to: "/v1/authentication/Get2FAStatus", using: .post, input: Empty())
            return result
        } catch let error as APIErrorResponse {
            guard let apiError = error.errors.last else {
                throw error
            }
            throw apiError.accountError
        }
    }
}

private extension Date {
    var timeStamp: String {
        return String(self.timeIntervalSince1970)
    }
}

private struct LoginInfo: Encodable {
    let login: String
}

private struct DeviceRegistrationInfo: Encodable {
    let login: String
    let methods: [Login2FAOption]
}

private struct ServerKeyResponse: Codable {
    let serverKey: String
}

private extension APIError {
    var accountCreationError: AccountCreationError {
        return AccountCreationError(rawValue: code) ?? .unknown
    }
}

public struct RemoteKeyResponse: Decodable {
    public let ssoServerKey: String
    public let remoteKeys: [RemoteKey]
}

extension Array where Element == RemoteKey {
    func ssoRemoteKey() -> RemoteKey? {
        return self.first(where: { key in
            if let type = key.type, type == .sso {
                return true
            }
            return false
        })
    }
    
    func masterPasswordRemoteKey() -> RemoteKey? {
        return self.first(where: { key in
            if let type = key.type, type == .masterPassword {
                return true
            }
            return false
        })
    }
}

private struct AuthTicket: Encodable {
    let authTicket: String
}
