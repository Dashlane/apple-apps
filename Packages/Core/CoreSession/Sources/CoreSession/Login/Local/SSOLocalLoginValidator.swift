import Foundation
import DashTypes
import SwiftTreats

public class SSOLocalLoginValidator: SSOValidator {
    public let cryptoEngineProvider: CryptoEngineProvider
    public let accountAPIClient: AccountAPIClientProtocol
    public let login: Login
    private let deviceAccessKey: String
    public let serviceProviderUrl: URL
    public let isNitroProvider: Bool
    
    public init(login: Login, deviceAccessKey: String, accountAPIClient: AccountAPIClientProtocol, serviceProviderUrl: URL, cryptoEngineProvider: CryptoEngineProvider, isNitroProvider: Bool) {
        self.login = login
        self.accountAPIClient = accountAPIClient
        self.deviceAccessKey = deviceAccessKey
        self.serviceProviderUrl = serviceProviderUrl
        self.cryptoEngineProvider = cryptoEngineProvider
        self.isNitroProvider = isNitroProvider
    }

    public func validateSSOTokenAndGetKeys(_ token: String, serviceProviderKey: String) async throws -> SSOKeys {
        let verificationResponse = try await accountAPIClient.performVerification(with: PerformSSOVerificationRequest(login: login.email, ssoToken: token))
        let response = try await self.accountAPIClient.loginForRemoteKey(with: CompleteLoginRequestInfo(
            login: self.login.email,
            deviceAccessKey: self.deviceAccessKey,
            authTicket: verificationResponse.authTicket))
        let ssoKeys = try self.decipherRemoteKey(serviceProviderKey: serviceProviderKey, remoteKey: response.remoteKeys.ssoRemoteKey(), ssoServerKey: response.ssoServerKey, authTicket: verificationResponse.authTicket)
        return ssoKeys
    }
}
