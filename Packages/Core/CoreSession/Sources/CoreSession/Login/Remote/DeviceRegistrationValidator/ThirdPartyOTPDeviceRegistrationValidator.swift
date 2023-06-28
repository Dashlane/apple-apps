import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

public class ThirdPartyOTPDeviceRegistrationValidator: DeviceRegistrationValidator {

    public let login: Login
    public let option: ThirdPartyOTPOption
    private let apiClient: AppAPIClient
    private let deviceInfo: DeviceInfo
    public var deviceRegistrationValidatorDidFetch: ((DeviceRegistrationData) -> Void)?

    init(login: Login, deviceInfo: DeviceInfo, option: ThirdPartyOTPOption, apiClient: AppAPIClient, deviceRegistrationValidatorDidFetch: ((DeviceRegistrationData) -> Void)? = nil) {
        self.login = login
        self.deviceInfo = deviceInfo
        self.option = option
        self.apiClient = apiClient
        self.deviceRegistrationValidatorDidFetch = deviceRegistrationValidatorDidFetch
    }

    public func validateOTP(_ otp: String) async throws {
        let verificationResponse = try await apiClient.authentication.performTotpVerification(login: login.email, otp: otp)
        let deviceRegistrationResponse = try await apiClient.authentication.completeDeviceRegistrationWithAuthTicket(device: deviceInfo, login: login.email, authTicket: verificationResponse.authTicket)
        self.deviceRegistrationValidatorDidFetch?(DeviceRegistrationData(
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

        let verificationResponse = try await apiClient.authentication.performDuoPushVerification(login: login.email)
        let deviceRegistrationResponse = try await apiClient.authentication.completeDeviceRegistrationWithAuthTicket(device: deviceInfo, login: login.email, authTicket: verificationResponse.authTicket)
        self.deviceRegistrationValidatorDidFetch?(DeviceRegistrationData(
            initialSettings: deviceRegistrationResponse.settings.content,
            deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
            deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
            analyticsIds: deviceRegistrationResponse.analyticsIds,
            serverKey: deviceRegistrationResponse.serverKey,
            remoteKeys: deviceRegistrationResponse.remoteKeys,
            authTicket: verificationResponse.authTicket))
    }

        public func validateUsingAuthenticatorPush() async throws {
        let verificationResponse = try await apiClient.authentication.performDashlaneAuthenticatorVerification(login: login.email)
        let deviceRegistrationResponse = try await apiClient.authentication.completeDeviceRegistrationWithAuthTicket(device: deviceInfo, login: login.email, authTicket: verificationResponse.authTicket)
        self.deviceRegistrationValidatorDidFetch?( DeviceRegistrationData(
            initialSettings: deviceRegistrationResponse.settings.content,
            deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
            deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
            analyticsIds: deviceRegistrationResponse.analyticsIds,
            serverKey: deviceRegistrationResponse.serverKey,
            remoteKeys: deviceRegistrationResponse.remoteKeys,
            authTicket: verificationResponse.authTicket))
    }
}

public extension ThirdPartyOTPDeviceRegistrationValidator {
    static var mock: ThirdPartyOTPDeviceRegistrationValidator {
        ThirdPartyOTPDeviceRegistrationValidator(login: Login("_"), deviceInfo: .mock, option: .authenticatorPush, apiClient: .mock({

        }))
    }
}
