import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

public enum AccountCreationMethodAvailibility {
    case sso(SSOLoginInfo)
    case masterpassword

    init?(isLoginAvailable: Bool, shouldRegisterViaSSO: Bool, serviceProviderURL: String?, isNitroProvider: Bool, context: LoginContext?) {
        guard isLoginAvailable else { return nil }

        if shouldRegisterViaSSO, let serviceProviderURL = serviceProviderURL {
            if let context = context {
                self = .sso(SSOLoginInfo(serviceProviderURL: "\(serviceProviderURL)?redirect=\(context.origin.rawValue)&frag=true", isNitroProvider: isNitroProvider))
                return
            }
            self = .sso(SSOLoginInfo(serviceProviderURL: serviceProviderURL, isNitroProvider: isNitroProvider))
        } else {
            self = .masterpassword
        }
    }
}

public extension AppAPIClient.Account {
    func accountCreationMethodAvailibility(for login: Login, context: LoginContext? = nil) async throws -> AccountCreationMethodAvailibility? {
        let accountInfo = try await requestAccountCreation(login: login.email)
        switch accountInfo.emailValidity {
        case .invalid:
            throw AccountExistsError.invalidValue
        case .unlikely:
            throw AccountExistsError.unlikelyValue
        default:
            return AccountCreationMethodAvailibility(isLoginAvailable: !accountInfo.accountExists,
                                                     shouldRegisterViaSSO: accountInfo.sso,
                                                     serviceProviderURL: accountInfo.ssoServiceProviderUrl, isNitroProvider: accountInfo.ssoIsNitroProvider ?? false,
                                                     context: context)
        }
    }

    func createAccount(with accountInfo: AccountCreationInfo) async throws -> AppAPIClient.Account.CreateUser.Response {
        return try await createUser(
            login: accountInfo.login,
            appVersion: accountInfo.appVersion,
            platform: accountInfo.platform,
            settings: accountInfo.settings,
            deviceName: accountInfo.deviceName,
            country: accountInfo.country,
            osCountry: accountInfo.osCountry,
            language: accountInfo.language,
            osLanguage: accountInfo.osLanguage,
            consents: accountInfo.consents,
            sharingKeys: accountInfo.sharingKeys.accountSharingKeys,
            accountType: accountInfo.accountType,
            contactEmail: accountInfo.contactEmail
        )
    }

    func createSSOAccount(with accountInfo: SSOAccountCreationInfos) async throws -> AppAPIClient.Account.CreateUserWithSSO.Response {
        try await createUserWithSSO(
            login: accountInfo.login,
            contactEmail: accountInfo.contactEmail,
            appVersion: accountInfo.appVersion,
            sdkVersion: accountInfo.sdkVersion,
            platform: accountInfo.platform,
            settings: accountInfo.settings,
            deviceName: accountInfo.deviceName,
            country: accountInfo.country,
            osCountry: accountInfo.osCountry,
            language: accountInfo.language,
            osLanguage: accountInfo.osLanguage,
            consents: accountInfo.consents,
            sharingKeys: accountInfo.sharingKeys.accountSharingKeys,
            ssoToken: accountInfo.ssoToken,
            ssoServerKey: accountInfo.ssoServerKey,
            remoteKeys: accountInfo.remoteKeys
        )
       }

}

public struct SSOLoginInfo {
    public let serviceProviderURL: String
    public let isNitroProvider: Bool
}

extension SharingKeys {
    var accountSharingKeys: AccountCreateUserSharingKeys {
        return AccountCreateUserSharingKeys(privateKey: encryptedPrivateKey, publicKey: publicKey)
    }
}
