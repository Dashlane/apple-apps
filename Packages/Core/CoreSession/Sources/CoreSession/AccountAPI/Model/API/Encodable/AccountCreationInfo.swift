import DashTypes
import DashlaneAPI
import Foundation

public struct AccountCreationInfo: Encodable, Sendable {
  public let login: String
  public let contactEmail: String
  public let contactPhone: String?
  public let appVersion: String
  public let sdkVersion: String
  public let platform: AccountCreateUserPlatform
  public let settings: CoreSessionSettings
  public let consents: [Consent]
  public let deviceName: String
  public let origin: String
  public let abTestingVersion: String
  public let country: String
  public let osCountry: String
  public let language: String
  public let osLanguage: String
  public let askM2dToken: Bool
  public let sharingKeys: AccountCreateUserSharingKeys
  public let accountType: DashlaneAPI.AccountType

  public init(
    login: String,
    contactEmail: String,
    contactPhone: String? = nil,
    appVersion: String,
    sdkVersion: String = "1.0.0.0",
    platform: AccountCreateUserPlatform,
    settings: CoreSessionSettings,
    deviceName: String,
    origin: String,
    abTestingVersion: String,
    country: String,
    language: String,
    askM2dToken: Bool = true,
    sharingKeys: AccountCreateUserSharingKeys,
    consents: [Consent],
    accountType: DashlaneAPI.AccountType
  ) {

    self.login = login.lowercased()
    self.contactEmail = contactEmail.lowercased()
    self.contactPhone = contactPhone
    self.appVersion = appVersion
    self.sdkVersion = sdkVersion
    self.platform = platform
    self.settings = settings
    self.deviceName = deviceName
    self.origin = origin
    self.abTestingVersion = abTestingVersion
    self.country = country
    self.osCountry = country
    self.language = language
    self.osLanguage = language
    self.askM2dToken = askM2dToken
    self.sharingKeys = sharingKeys
    self.consents = consents
    self.accountType = accountType
  }
}
