import Foundation
import DashTypes
import SwiftTreats

public class ThirdPartyOTPDeviceRegistrationValidator: DeviceRegistrationValidator {
    
    public let login: Login
    public let option: ThirdPartyOTPOption
    private let accountAPIClient: AccountAPIClientProtocol
    weak public var delegate: DeviceRegistrationValidatorDelegate?
    private let deviceInfo: DeviceInfo
    
    init(login: Login, deviceInfo: DeviceInfo, option: ThirdPartyOTPOption, accountAPIClient: AccountAPIClientProtocol) {
        self.login = login
        self.deviceInfo = deviceInfo
        self.option = option
        self.accountAPIClient = accountAPIClient
    }
    
    
    public func validateOTP(_ otp: String) async throws {
        let verificationResponse = try await self.accountAPIClient.performVerification(with: PerformTOTPVerificationRequest(login: login.email, otp: otp))
        let deviceRegistrationResponse = try await self.accountAPIClient.registerDevice(with: CompleteDeviceRegistrationRequest(device: self.deviceInfo, login: self.login.email, authTicket: verificationResponse.authTicket))
        self.delegate?.deviceRegistrationValidatorDidFetch(
            DeviceRegistrationData(
                initialSettings: deviceRegistrationResponse.settings.content,
                deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
                deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
                analyticsIds: deviceRegistrationResponse.analyticsIds,
                serverKey: deviceRegistrationResponse.serverKey,
                remoteKeys: deviceRegistrationResponse.remoteKeys,
                authTicket: verificationResponse.authTicket))
    }
    
        public func validateUsingDUOPush() async throws {
        guard option == .duoPush else {
            throw ThirdPartyOTPError.duoPushNotEnabled
        }
        
        let verificationResponse = try await self.accountAPIClient.performVerification(with: PerformDuoPushVerificationRequest(login: login.email))
        let deviceRegistrationResponse = try await self.accountAPIClient.registerDevice(with: CompleteDeviceRegistrationRequest(device: self.deviceInfo, login: self.login.email, authTicket: verificationResponse.authTicket))
        self.delegate?.deviceRegistrationValidatorDidFetch(
            DeviceRegistrationData(
                initialSettings: deviceRegistrationResponse.settings.content,
                deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
                deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
                analyticsIds: deviceRegistrationResponse.analyticsIds,
                serverKey: deviceRegistrationResponse.serverKey,
                remoteKeys: deviceRegistrationResponse.remoteKeys,
                authTicket: verificationResponse.authTicket))
    }
    
        public func validateUsingAuthenticatorPush() async throws {
        let verificationResponse = try await self.accountAPIClient.performVerification(with: PerformAuthenticatorPushVerificationRequest(login: login.email))
        let deviceRegistrationResponse = try await self.accountAPIClient.registerDevice(with: CompleteDeviceRegistrationRequest(device: self.deviceInfo, login: self.login.email, authTicket: verificationResponse.authTicket))
        self.delegate?.deviceRegistrationValidatorDidFetch(
            DeviceRegistrationData(
                initialSettings: deviceRegistrationResponse.settings.content,
                deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
                deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
                analyticsIds: deviceRegistrationResponse.analyticsIds,
                serverKey: deviceRegistrationResponse.serverKey,
                remoteKeys: deviceRegistrationResponse.remoteKeys,
                authTicket: verificationResponse.authTicket))
    }
}
