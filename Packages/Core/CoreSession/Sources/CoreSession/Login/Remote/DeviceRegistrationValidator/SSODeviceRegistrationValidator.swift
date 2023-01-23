import Foundation
import DashTypes
import SwiftTreats

public class SSODeviceRegistrationValidator: DeviceRegistrationValidator, SSOValidator {
    public let cryptoEngineProvider: CryptoEngineProvider
    public let accountAPIClient: AccountAPIClientProtocol
    public let login: Login
    weak public var delegate: DeviceRegistrationValidatorDelegate?
    private let deviceInfo: DeviceInfo
    public let serviceProviderUrl: URL
    public let isNitroProvider: Bool
    
    public init(login: Login, serviceProviderUrl: URL, deviceInfo: DeviceInfo, accountAPIClient: AccountAPIClientProtocol, cryptoEngineProvider: CryptoEngineProvider, isNitroProvider: Bool) {
        self.login = login
        self.accountAPIClient = accountAPIClient
        self.deviceInfo = deviceInfo
        self.serviceProviderUrl = serviceProviderUrl
        self.cryptoEngineProvider = cryptoEngineProvider
        self.isNitroProvider = isNitroProvider
    }

    public func validateSSOTokenAndGetKeys(_ token: String, serviceProviderKey: String) async throws -> SSOKeys {
        let verificationResponse = try await self.accountAPIClient.performVerification(with: PerformSSOVerificationRequest(login: login.email, ssoToken: token))

        let deviceRegistrationResponse = try await  self.accountAPIClient.registerDevice(with: CompleteDeviceRegistrationRequest(device: self.deviceInfo, login: self.login.email, authTicket: verificationResponse.authTicket))
        let deviceRegistrationData = DeviceRegistrationData(
            initialSettings: deviceRegistrationResponse.settings.content,
            deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
            deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
            analyticsIds: deviceRegistrationResponse.analyticsIds,
            serverKey: deviceRegistrationResponse.serverKey,
            remoteKeys: deviceRegistrationResponse.remoteKeys,
            ssoServerKey: deviceRegistrationResponse.ssoServerKey,
            authTicket: verificationResponse.authTicket
        )
        self.delegate?.deviceRegistrationValidatorDidFetch(deviceRegistrationData)
        let ssoKeys = try self.decipherRemoteKey(serviceProviderKey: serviceProviderKey, remoteKey: deviceRegistrationData.remoteKeys?.ssoRemoteKey(), ssoServerKey: deviceRegistrationResponse.ssoServerKey, authTicket: verificationResponse.authTicket)
        return ssoKeys
    }
}

public struct SSOCallbackInfos {
    public let ssoToken: String
    public let serviceProviderKey: String
    public let exists: Bool

    public init?(url: URL) {
                if let fragments = url.fragments(),
            let ssoToken = fragments["ssoToken"],
            let key = fragments["key"],
            let exists = fragments["exists"]?.boolValue {
            self.ssoToken = ssoToken
            self.serviceProviderKey = key
            self.exists = exists
        } else {
            guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
            let ssoToken = queryItems.filter({ $0.name == "ssoToken" }).first?.value,
            let serviceProviderKey = queryItems.filter({ $0.name == "key" }).first?.value else {
                return nil
            }
            self.ssoToken = ssoToken
            self.serviceProviderKey = serviceProviderKey
            self.exists = queryItems.filter({ $0.name == "exists" }).first?.value?.boolValue ?? false
        }
    }
    
    public init(ssoToken: String, serviceProviderKey: String, exists: Bool) {
        self.ssoToken = ssoToken
        self.serviceProviderKey = serviceProviderKey
        self.exists = exists
    }
}

extension URL {
    func fragments() -> [String: String]? {
        var result = [String:String]()
        guard let fragments = self.fragment?.components(separatedBy: "&") else {
            return nil
        }
        for fragment in fragments {
            let  keyValueFragment = fragment.components(separatedBy: "=")
            if keyValueFragment.count == 2 {
                result[keyValueFragment[0]] = keyValueFragment[1].removingPercentEncoding
            }
        }
        return result
    }
}
