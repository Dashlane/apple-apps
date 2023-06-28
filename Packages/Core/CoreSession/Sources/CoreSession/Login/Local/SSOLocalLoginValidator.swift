import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

public class SSOLocalLoginValidator: SSOValidator {
    public let cryptoEngineProvider: CryptoEngineProvider
    public let apiClient: AppAPIClient
    public let login: Login
    private let deviceAccessKey: String
    public let serviceProviderUrl: URL
    public let isNitroProvider: Bool

    public init(login: Login, deviceAccessKey: String, apiClient: AppAPIClient, serviceProviderUrl: URL, cryptoEngineProvider: CryptoEngineProvider, isNitroProvider: Bool) {
        self.login = login
        self.apiClient = apiClient
        self.deviceAccessKey = deviceAccessKey
        self.serviceProviderUrl = serviceProviderUrl
        self.cryptoEngineProvider = cryptoEngineProvider
        self.isNitroProvider = isNitroProvider
    }

    public func validateSSOTokenAndGetKeys(_ token: String, serviceProviderKey: String) async throws -> SSOKeys {
        let verificationResponse = try await apiClient.authentication.performSsoVerification(login: login.email, ssoToken: token)
        let response = try await self.apiClient.authentication.completeLoginWithAuthTicket(
            login: self.login.email,
            deviceAccessKey: self.deviceAccessKey,
            authTicket: verificationResponse.authTicket)
        let ssoKeys = try self.decipherRemoteKey(serviceProviderKey: serviceProviderKey, remoteKey: response.remoteKeys!.ssoRemoteKey(), ssoServerKey: response.ssoServerKey, authTicket: AuthTicket(value: verificationResponse.authTicket))
        return ssoKeys
    }
}
