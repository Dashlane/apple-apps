import Foundation
import DashTypes
import SwiftTreats

public class TokenDeviceRegistrationValidator: DeviceRegistrationValidator {
    public enum Error: Swift.Error, Equatable {
        case wrongToken
    }

    private let accountAPIClient: AccountAPIClientProtocol
    public let login: Login
    weak public var delegate: DeviceRegistrationValidatorDelegate?
    private let deviceInfo: DeviceInfo
    
    public init(login: Login, deviceInfo: DeviceInfo, accountAPIClient: AccountAPIClientProtocol) {
        self.login = login
        self.accountAPIClient = accountAPIClient
        self.deviceInfo = deviceInfo
    }

        public func requestToken() async throws {
        try await accountAPIClient.requestToken(for: login)
    }

        public func validateToken(_ token: String, completion: @escaping CompletionBlock<Void, Swift.Error>) {
        Task {
            do {
              let verificationResponse = try await self.accountAPIClient.performVerification(with: PerformTokenVerificationRequest(login: login.email, token: token))
                let deviceRegistrationResponse = try await self.accountAPIClient.registerDevice(with: CompleteDeviceRegistrationRequest(device: self.deviceInfo, login: self.login.email, authTicket: verificationResponse.authTicket))
                self.delegate?.deviceRegistrationValidatorDidFetch(
                    DeviceRegistrationData(
                        initialSettings: deviceRegistrationResponse.settings.content,
                        deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
                        deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
                        analyticsIds: deviceRegistrationResponse.analyticsIds,
                        serverKey: deviceRegistrationResponse.serverKey,
                        remoteKeys: deviceRegistrationResponse.remoteKeys))
                await MainActor.run {
                    completion(.success(Void()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
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
