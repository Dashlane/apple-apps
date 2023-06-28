import Foundation
import Adjust
import DashTypes
import CoreUserTracking
import SwiftTreats

struct AdjustService {
    static func startTracking(installationID: LowercasedUUID) {
        let identifier = AdjustTrackingIdentifier(installationID: installationID)
        let appToken = ApplicationSecrets.Adjust.key
        let environment = BuildEnvironment.current == .appstore ? ADJEnvironmentProduction : ADJEnvironmentSandbox

        let config = ADJConfig(appToken: appToken, environment: environment)
        #if DEBUG
        config?.logLevel = ADJLogLevelError
        #else
        config?.logLevel = ADJLogLevelSuppress
        #endif
        Adjust.addSessionCallbackParameter(identifier.keyName, value: identifier.value)
        Adjust.appDidLaunch(config)
        let event = ADJEvent(eventToken: "vtgpe3")
        event?.addCallbackParameter(identifier.keyName, value: identifier.value)
        Adjust.trackEvent(event)
    }
}

struct AdjustTrackingIdentifier: Equatable {
    let keyName: String = AdjustKeyIdentifier.installationIdKey.rawValue
    let value: String

    init(installationID: LowercasedUUID) {
        value = installationID.uuidString
    }
}

enum AdjustKeyIdentifier: String {
    case installationIdKey = "installation_id"
}
