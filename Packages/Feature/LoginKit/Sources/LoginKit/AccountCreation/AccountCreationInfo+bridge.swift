import CorePersonalData
import CoreSession
import CoreSync
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

extension AccountCreationInfo {
  public init(
    email: DashTypes.Email,
    appVersion: String,
    cryptoEngine: SessionCryptoEngine,
    hasUserAcceptedEmailMarketing: Bool,
    origin: Origin,
    accountType: DashlaneAPI.AccountType
  ) throws {
    let cryptoConfig = cryptoEngine.config
    let content = try Settings(cryptoConfig: cryptoConfig, email: email.address)
      .makeTransactionContent()
      .encrypt(using: cryptoEngine)
      .base64EncodedString()

    let settings = CoreSessionSettings(content: content, time: Int(Timestamp.now.rawValue))
    let consents = [
      Consent(consentType: .emailsOffersAndTips, status: hasUserAcceptedEmailMarketing),
      Consent(consentType: .privacyPolicyAndToS, status: true),
    ]

    guard
      let sharingKeys = try? AccountCreateUserSharingKeys.makeAccountDefault(
        privateKeyCryptoEngine: cryptoEngine)
    else {
      throw AccountError.unknown
    }

    self.init(
      email: String(email.address),
      appVersion: appVersion,
      settings: settings,
      consents: consents,
      sharingKeys: sharingKeys,
      origin: origin,
      accountType: accountType)
  }
}

extension AccountCreationInfo {

  public enum Origin: String {
    case iOS
  }

  public init(
    email: String,
    appVersion: String,
    settings: CoreSessionSettings,
    consents: [Consent],
    sharingKeys: AccountCreateUserSharingKeys,
    origin: Origin,
    accountType: DashlaneAPI.AccountType
  ) {
    self.init(
      login: email,
      contactEmail: email,
      appVersion: appVersion,
      platform: AccountCreateUserPlatform(rawValue: Platform.passwordManager.rawValue)
        ?? .serverIphone,
      settings: settings,
      deviceName: Device.name,
      origin: origin.rawValue,
      abTestingVersion: "0.0.0.0",
      country: System.country,
      language: System.language,
      sharingKeys: sharingKeys,
      consents: consents,
      accountType: accountType)
  }
}
