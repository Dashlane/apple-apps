import Foundation
import Adjust
import DashTypes
import CoreUserTracking
import SwiftTreats

struct AdjustService {
    static func startTracking(usingAnonymousDeviceId anonymousDeviceId: String?,
                              installationID: LowercasedUUID,
                              isFirstLaunch: Bool) {
        guard let anonymousDeviceId = anonymousDeviceId else {
             return
        }

        let identifier = AdjustTrackingIdentifier(anonymousDeviceId: anonymousDeviceId,
                                                  installationID: installationID,
                                                  isFirstLaunch: isFirstLaunch,
                                                  cache: IdentifierSettings()).id
        let appToken = ApplicationSecrets.Adjust.key
        let environment = BuildEnvironment.current == .appstore ? ADJEnvironmentProduction : ADJEnvironmentSandbox

        let config = ADJConfig(appToken: appToken, environment: environment)
        Adjust.addSessionCallbackParameter(identifier.keyName, value: identifier.value)
        Adjust.appDidLaunch(config)
        let event = ADJEvent(eventToken: "vtgpe3")
        event?.addCallbackParameter(identifier.keyName, value: identifier.value)
        Adjust.trackEvent(event)
    }
}

struct AdjustTrackingIdentifier {

    struct Identifier: Equatable {
        let keyName: String
        let value: String
    }

    let id: Identifier

    init(anonymousDeviceId: String,
         installationID: LowercasedUUID,
         isFirstLaunch: Bool,
         cache: AdjustTrackingIdentifierCache) {

                let selector = IdentifierSelection(isFirstLaunch: isFirstLaunch,
                                           cache: cache)
        if selector.shouldUseInstallationID() {
            id = Identifier(keyName: AdjustKeyIdentifier.installationIdKey.rawValue, value: installationID.uuidString)
            cache.trackingUseInstallationID = true
        } else {
            id = Identifier(keyName: AdjustKeyIdentifier.anonymousComputerIdKey.rawValue, value: anonymousDeviceId)
        }
    }
}

enum AdjustKeyIdentifier: String {
    case installationIdKey = "installation_id"
    case anonymousComputerIdKey = "anonymousComputerId"
}

extension AdjustTrackingIdentifier {
    struct IdentifierSelection {
                        let selectionPercentage = 50

        let isFirstLaunch: Bool

        let cache: AdjustTrackingIdentifierCache

        func shouldUseInstallationID() -> Bool {
                                                            guard isFirstLaunch else {
                return cache.trackingUseInstallationID
            }
                                    let canUseInstallationID = Int.random(in: 0..<100) < selectionPercentage
            return canUseInstallationID
        }
    }
}

protocol AdjustTrackingIdentifierCache: AnyObject {
    var trackingUseInstallationID: Bool { get set }
}

private class IdentifierSettings: AdjustTrackingIdentifierCache {
            @SharedUserDefault(key: "TRACKING_USE_INSTALLATION_ID", default: false, userDefaults: .standard)
    var trackingUseInstallationID: Bool

    init() {}
}
