import Foundation
import SwiftTreats
import DashTypes

public protocol AccountAPIClientProtocol {
        func create(with loginInfo: AccountCreationInfo, completion: @escaping CompletionBlock<AccountCreationResponse, Error>)
    func createSSOUser(with accountInfo: SSOAccountCreationInfos, completion: @escaping CompletionBlock<AccountCreationResponse, Error>)
    func verifyExistence(of login: Login, completion: @escaping CompletionBlock<AccountAvailabilityResponse, Error>)

        func requestDeviceRegistration(for login: Login) async throws -> LoginResponse
    func requestToken(for login: Login) async throws
    
        func registerDevice(with deviceRegistrationInfo: CompleteDeviceRegistrationRequest) async throws -> CompleteDeviceRegistrationResponse

    func requestLogin(with loginInfo: LoginRequestInfo) async throws -> LoginResponse
    func requestLogin(with loginInfo: LoginRequestInfo, timeout: TimeInterval?) async throws -> LoginResponse


    func performVerification<T: PerformVerificationRequest>(with verificationInfo: T) async throws -> PerformVerificationResponse
    
    func login(with loginInfo: CompleteLoginRequestInfo) async throws -> String
    func loginForRemoteKey(with loginInfo: CompleteLoginRequestInfo) async throws -> RemoteKeyResponse
    
        func requestTOTPActivation(with request: TOTPActivationRequest) async throws -> TOTPActivationResponse
    func completeTOTPActivation(withAuthTicket authTicket: String) async throws
    func deactivateTOTP(withAuthTicket authTicket: String) async throws
    func twoFAStatus() async throws -> TwoFAStatus
}
