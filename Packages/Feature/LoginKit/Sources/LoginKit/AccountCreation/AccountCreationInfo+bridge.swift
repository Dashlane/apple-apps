import Foundation
import DashTypes
import CorePersonalData
import CoreSync
import DashlaneCrypto
import SwiftTreats
import CoreSession
import DashlaneAPI

public extension AccountCreationInfo {
        init(email: DashTypes.Email,
         appVersion: String,
         cryptoEngine: SessionCryptoEngine,
         hasUserAcceptedEmailMarketing: Bool,
         origin: Origin,
         accountType: AccountAccountType) throws {
        let cryptoConfig = cryptoEngine.config
        let content =  try Settings(cryptoConfig: cryptoConfig, email: email.address)
            .makeTransactionContent()
            .encrypt(using: cryptoEngine)
            .base64EncodedString()

        let settings = CoreSessionSettings(content: content, time: Int(Timestamp.now.rawValue))
        let consents = [Consent(consentType: .emailsOffersAndTips, status: hasUserAcceptedEmailMarketing),
                        Consent(consentType: .privacyPolicyAndToS, status: true)]

        guard let sharingKeys = try? SharingKeys.makeAccountDefault(privateKeyCryptoEngine: cryptoEngine) else {
            throw AccountError.unknown
        }

        self.init(email: String(email.address),
                  appVersion: appVersion,
                  settings: settings,
                  consents: consents,
                  sharingKeys: sharingKeys,
                  origin: origin,
                  accountType: accountType)
    }
}

public extension AccountCreationInfo {

    enum Origin: String {
        case iOS
    }

    init(email: String,
         appVersion: String,
         settings: CoreSessionSettings,
         consents: [Consent],
         sharingKeys: SharingKeys,
         origin: Origin,
         accountType: AccountAccountType) {
        self.init(login: email,
                  contactEmail: email,
                  appVersion: appVersion,
                  platform: AccountCreateUserPlatform(rawValue: Platform.passwordManager.rawValue) ?? .serverIphone, 
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
