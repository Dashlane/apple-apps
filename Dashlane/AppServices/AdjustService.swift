import CoreTypes
import Foundation
import SwiftTreats
import UserTrackingFoundation

#if canImport(Adjust)
  import Adjust
#endif

struct AdjustService {
  static func startTracking(installationID: LowercasedUUID) {
    #if canImport(Adjust)
      let identifier = AdjustTrackingIdentifier(installationID: installationID)
      let appToken = ApplicationSecrets.Adjust.key
      let environment =
        BuildEnvironment.current == .appstore ? ADJEnvironmentProduction : ADJEnvironmentSandbox

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
    #endif
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
