import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public enum AccountCreationMethodAvailibility: Sendable {
  case sso(SSOLoginInfo)
  case masterpassword(_ isB2BAccount: Bool)

  init?(
    isLoginAvailable: Bool, shouldRegisterViaSSO: Bool, serviceProviderURL: String?,
    isNitroProvider: Bool, isB2BAccount: Bool
  ) {
    guard isLoginAvailable else { return nil }

    if shouldRegisterViaSSO, let serviceProviderURL = serviceProviderURL {
      self = .sso(
        SSOLoginInfo(
          serviceProviderURL: "\(serviceProviderURL)?redirect=mobile&frag=true",
          isNitroProvider: isNitroProvider))
      return
    } else {
      self = .masterpassword(isB2BAccount)
    }
  }
}

extension AppAPIClient.Account {
  public func accountCreationMethodAvailibility(for login: Login) async throws
    -> AccountCreationMethodAvailibility?
  {
    let accountInfo = try await requestAccountCreation(login: login.email)
    switch accountInfo.emailValidity {
    case .invalid:
      throw AccountExistsError.invalidValue
    case .unlikely:
      throw AccountExistsError.unlikelyValue
    default:
      return AccountCreationMethodAvailibility(
        isLoginAvailable: !accountInfo.accountExists,
        shouldRegisterViaSSO: accountInfo.sso,
        serviceProviderURL: accountInfo.ssoServiceProviderUrl,
        isNitroProvider: accountInfo.ssoIsNitroProvider ?? false,
        isB2BAccount: accountInfo.isB2BAccount)
    }
  }

  public func createAccount(with accountInfo: AccountCreationInfo) async throws
    -> AppAPIClient.Account.CreateUser.Response
  {
    return try await createUser(
      login: accountInfo.login,
      appVersion: accountInfo.appVersion,
      platform: accountInfo.platform,
      settings: accountInfo.settings,
      consents: accountInfo.consents,
      deviceName: accountInfo.deviceName,
      country: accountInfo.country,
      osCountry: accountInfo.osCountry,
      language: accountInfo.language,
      osLanguage: accountInfo.osLanguage,
      sharingKeys: accountInfo.sharingKeys,
      accountType: accountInfo.accountType,
      contactEmail: accountInfo.contactEmail
    )
  }

  public func createSSOAccount(with accountInfo: SSOAccountCreationInfos) async throws
    -> AppAPIClient.Account.CreateUserWithSSO.Response
  {
    try await createUserWithSSO(
      login: accountInfo.login,
      contactEmail: accountInfo.contactEmail,
      appVersion: accountInfo.appVersion,
      sdkVersion: accountInfo.sdkVersion,
      platform: accountInfo.platform,
      settings: accountInfo.settings,
      consents: accountInfo.consents,
      deviceName: accountInfo.deviceName,
      country: accountInfo.country,
      osCountry: accountInfo.osCountry,
      language: accountInfo.language,
      osLanguage: accountInfo.osLanguage,
      sharingKeys: accountInfo.sharingKeys,
      ssoToken: accountInfo.ssoToken,
      ssoServerKey: accountInfo.ssoServerKey,
      remoteKeys: accountInfo.remoteKeys
    )
  }
}

public struct SSOLoginInfo: Sendable {
  public let serviceProviderURL: String
  public let isNitroProvider: Bool
}

extension AppAPIClient.Account.RequestAccountCreation.Response {
  var isB2BAccount: Bool {
    isAccepted || isProposed
  }
}
