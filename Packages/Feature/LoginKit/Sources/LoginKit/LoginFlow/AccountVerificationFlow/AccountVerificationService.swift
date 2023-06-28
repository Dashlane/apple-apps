import Foundation
import DashlaneAPI
import CoreSession
import SwiftTreats

public class AccountVerificationService {

    let login: String
    private let appAPIClient: AppAPIClient
    private let deviceInfo: DeviceInfo

    init(login: String,
         appAPIClient: AppAPIClient,
         deviceInfo: DeviceInfo) {
        self.login = login
        self.appAPIClient = appAPIClient
        self.deviceInfo = deviceInfo
    }

    public func requestToken() async throws {
        _ = try await appAPIClient.authentication.requestEmailTokenVerification(login: login)
    }

    public func qaToken() async throws -> String {
        return try await appAPIClient.authenticationQa.getDeviceRegistrationTokenForTestLogin(login: login).token
    }

        public func validateToken(_ token: String) async throws -> AuthTicket {
        let verificationResponse = try await self.appAPIClient.authentication.performEmailTokenVerification(login: login, token: token)
        return AuthTicket(value: verificationResponse.authTicket)
    }

        public func validateUsingAuthenticatorPush() async throws -> AuthTicket {
        let verificationResponse = try await self.appAPIClient.authentication.performDashlaneAuthenticatorVerification(login: login)
        return AuthTicket(value: verificationResponse.authTicket)
    }

        public func validateOTP(_ otp: String) async throws -> AuthTicket {
        let verificationResponse = try await self.appAPIClient.authentication.performTotpVerification(login: login, otp: otp)
        return AuthTicket(value: verificationResponse.authTicket)
    }

        public func validateUsingDUOPush() async throws -> AuthTicket {
        let verificationResponse = try await self.appAPIClient.authentication.performDuoPushVerification(login: login)
        return AuthTicket(value: verificationResponse.authTicket)
    }

    public func registerDevice(withAuthTicket authTicket: AuthTicket) async throws -> DeviceRegistrationData {
        let deviceRegistrationResponse = try await appAPIClient.authentication.completeDeviceRegistrationWithAuthTicket(device: deviceInfo, login: login, authTicket: authTicket.value)
        return DeviceRegistrationData(
            initialSettings: deviceRegistrationResponse.settings.content,
            deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
            deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
            analyticsIds: deviceRegistrationResponse.analyticsIds,
            serverKey: deviceRegistrationResponse.serverKey,
            remoteKeys: deviceRegistrationResponse.remoteKeys,
            authTicket: authTicket.value)
    }

    public func login(withAuthTicket authTicket: AuthTicket, deviceAccessKey: String) async throws -> (String?, AuthTicket) {
        let response = try await appAPIClient.authentication.completeLoginWithAuthTicket(login: login, deviceAccessKey: deviceAccessKey, authTicket: authTicket.value)
        return (response.serverKey, authTicket)
    }
}

extension AccountVerificationService {
    static var mock: AccountVerificationService {
        AccountVerificationService(login: "_", appAPIClient: .fake, deviceInfo: .mock)
    }
}
