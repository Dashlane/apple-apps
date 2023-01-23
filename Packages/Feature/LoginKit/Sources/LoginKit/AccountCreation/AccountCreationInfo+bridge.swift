import Foundation
import DashTypes
import CorePersonalData
import CoreSync
import DashlaneCrypto
import SwiftTreats
import CoreSession

public extension AccountCreationInfo {
        init(email: DashTypes.Email,
         appVersion: String,
         cryptoEngine: SessionCryptoEngine,
         hasUserAcceptedEmailMarketing: Bool,
         origin: Origin) throws {
        let cryptoConfig = cryptoEngine.config
        let content =  try Settings(cryptoConfig: cryptoConfig, email: email.address)
            .makeTransactionContent()
            .encrypt(using: cryptoEngine)
            .base64EncodedString()

        let settings = CoreSessionSettings(time: Timestamp.now.rawValue, content: content)
        let consents = [Consent(type: .emailsOffersAndTips, status: hasUserAcceptedEmailMarketing),
                        Consent(type: .privacyPolicyAndToS, status: true)]

        guard let sharingKeys = try? SharingKeys.makeAccountDefault(privateKeyCryptoEngine: cryptoEngine) else {
            throw AccountError.unknown
        }

        self.init(email: String(email.address),
                  appVersion: appVersion,
                  settings: settings,
                  consents: consents,
                  sharingKeys: sharingKeys,
                  origin: origin)
    }
}

public extension AccountCreationInfo {
    
    enum Origin: String {
        case iOS = "iOS"
    }
    
    init(email: String,
         appVersion: String,
         settings: CoreSessionSettings,
         consents: [Consent],
         sharingKeys: SharingKeys,
         origin: Origin) {
        self.init(login: email,
                  contactEmail: email,
                  appVersion: appVersion,
                  platform: Platform.passwordManager.rawValue, 
                  settings: settings,
                  deviceName: Device.name,
                  origin: origin.rawValue,
                  abTestingVersion: "0.0.0.0",
                  country: System.country,
                  language: System.language,
                  sharingKeys: sharingKeys,
                  consents: consents)
    }
}
