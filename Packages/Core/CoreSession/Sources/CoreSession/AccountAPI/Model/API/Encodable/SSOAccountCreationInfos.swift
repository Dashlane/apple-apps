import CoreTypes
import DashlaneAPI
import Foundation

public struct SSOAccountCreationInfos: Encodable, Sendable {
  public let login: String
  public let contactEmail: String
  public let appVersion: String
  public let sdkVersion: String
  public let platform: AccountCreateUserPlatform
  public let settings: CoreSessionSettings
  public let consents: [Consent]
  public let deviceName: String
  public let country: String
  public let osCountry: String
  public let language: String
  public let osLanguage: String
  public let sharingKeys: AccountCreateUserSharingKeys
  public let ssoToken: String
  public let ssoServerKey: String
  public let remoteKeys: [AppAPIClient.Account.CreateUserWithSSO.Body.RemoteKeysElement]

  public init(
    login: String,
    contactEmail: String,
    contactPhone: String? = nil,
    appVersion: String,
    sdkVersion: String = "1.0.0.0",
    platform: AccountCreateUserPlatform,
    settings: CoreSessionSettings,
    deviceName: String,
    country: String,
    language: String,
    sharingKeys: AccountCreateUserSharingKeys,
    consents: [Consent],
    ssoToken: String,
    ssoServerKey: String,
    remoteKeys: [AppAPIClient.Account.CreateUserWithSSO.Body.RemoteKeysElement]
  ) {
    self.login = login.lowercased()
    self.contactEmail = contactEmail.lowercased()
    self.appVersion = appVersion
    self.sdkVersion = sdkVersion
    self.platform = platform
    self.settings = settings
    self.deviceName = deviceName
    self.country = country
    self.osCountry = country
    self.language = language
    self.osLanguage = language
    self.sharingKeys = sharingKeys
    self.consents = consents
    self.ssoToken = ssoToken
    self.ssoServerKey = ssoServerKey
    self.remoteKeys = remoteKeys
  }
}
