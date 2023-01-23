import Foundation
import DashTypes
import SwiftTreats

public typealias ServerKey = String

@MainActor
public protocol ThirdPartyOTPLocalLoginValidatorDelegate: AnyObject {
    func thirdPartyOTPLocalLoginValidatorDidRetrieveServerKey(_ serverKey: String, authTicket: String?) async
}

public class ThirdPartyOTPLocalLoginValidator {
    public let login: Login

    public let option: ThirdPartyOTPOption
    private let deviceInfo: DeviceInfo
    private let deviceAccessKey: String
    private let accountAPIClient: AccountAPIClientProtocol
    public weak var delegate: ThirdPartyOTPLocalLoginValidatorDelegate?

    init(login: Login, deviceInfo: DeviceInfo, deviceAccessKey: String, option: ThirdPartyOTPOption, accountAPIClient: AccountAPIClientProtocol) {
        self.login = login
        self.deviceInfo = deviceInfo
        self.option = option
        self.accountAPIClient = accountAPIClient
        self.deviceAccessKey = deviceAccessKey
    }

    public init(login: Login, deviceInfo: DeviceInfo, deviceAccessKey: String, option: ThirdPartyOTPOption, apiClient: DeprecatedCustomAPIClient) {
        self.login = login
        self.deviceInfo = deviceInfo
        self.option = option
        self.accountAPIClient = AccountAPIClient(apiClient: apiClient)
        self.deviceAccessKey = deviceAccessKey
    }

        public func validateOTP(_ otp: String) async throws -> ServerKey {
        let verificationResponse = try await self.accountAPIClient.performVerification(with: PerformTOTPVerificationRequest(login: login.email, otp: otp))
        let serverKey = try await self.accountAPIClient.login(with: CompleteLoginRequestInfo(login: self.login.email, deviceAccessKey: self.deviceAccessKey, authTicket: verificationResponse.authTicket))
        await self.delegate?.thirdPartyOTPLocalLoginValidatorDidRetrieveServerKey(serverKey, authTicket: verificationResponse.authTicket)
        return serverKey
    }

        public func validateUsingDUOPush() async throws {
        guard option == .duoPush else {
            throw ThirdPartyOTPError.duoPushNotEnabled
        }
        
        let verificationResponse = try await self.accountAPIClient.performVerification(with: PerformDuoPushVerificationRequest(login: login.email))
        let serverKey = try await self.accountAPIClient.login(with: CompleteLoginRequestInfo(login: self.login.email, deviceAccessKey: self.deviceAccessKey, authTicket: verificationResponse.authTicket))
        await self.delegate?.thirdPartyOTPLocalLoginValidatorDidRetrieveServerKey(serverKey, authTicket: verificationResponse.authTicket)
    }

        public func validateUsingAuthenticatorPush() async throws {
        let verificationResponse = try await self.accountAPIClient.performVerification(with: PerformAuthenticatorPushVerificationRequest(login: login.email))
        let serverKey = try await self.accountAPIClient.login(with: CompleteLoginRequestInfo(login: self.login.email, deviceAccessKey: self.deviceAccessKey, authTicket: verificationResponse.authTicket))
        await self.delegate?.thirdPartyOTPLocalLoginValidatorDidRetrieveServerKey(serverKey, authTicket: verificationResponse.authTicket)
    }
}
