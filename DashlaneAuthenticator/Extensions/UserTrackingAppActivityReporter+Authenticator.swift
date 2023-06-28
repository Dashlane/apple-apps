import Foundation
import CoreUserTracking
import SwiftTreats
import UIKit
import DashTypes

extension UserTrackingAppActivityReporter {
    enum AuthenticatorKey: String {
        case authenticatorAnalyticsInstallationId
    }

    static var authenticatorAnalyticsInstallationId: LowercasedUUID {
        var sharedDefault = SharedUserDefault<String?, String>(key: AuthenticatorKey.authenticatorAnalyticsInstallationId.rawValue, userDefaults: ApplicationGroup.authenticatorUserDefaults)

        if let storedInstallationId = sharedDefault.wrappedValue,
           let uuid = LowercasedUUID(uuidString: storedInstallationId) {
            return uuid
        }
        let installationId = LowercasedUUID()
        sharedDefault.wrappedValue = installationId.uuidString
        return installationId
    }
}

extension AnonymousEvent.OtherAuthenticatorsInstalledReport {
    static var other2FAappsInstalled: [Definition.AuthenticatorNames] {
        var installedApps = [Definition.AuthenticatorNames]()
        for competitor in CompetitorsApplicationSchemeURL.allCases where UIApplication.shared.canOpenURL(competitor.url) {
            installedApps.append(competitor.userTrackingDefinition)
        }
        return installedApps
    }
}

private extension CompetitorsApplicationSchemeURL {
    var userTrackingDefinition: Definition.AuthenticatorNames {
        switch self {
        case .authy: return .authy
        case .duo: return .duo
        case .googleAuthenticator: return .google
        case .lastPassAuthenticator: return .lastpass
        case .microsoftAuthenticator: return .microsoft
        }
    }
}
