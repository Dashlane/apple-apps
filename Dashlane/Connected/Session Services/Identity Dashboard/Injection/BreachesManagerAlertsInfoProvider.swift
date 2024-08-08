import CoreFeature
import CorePremium
import Foundation
import SecurityDashboard

class BreachAlertsInfoProvider: SecurityDashboard.BreachesManagerAlertsInfoProvider {
  let capabilityService: CapabilityServiceProtocol
  let premiumStatusProvider: any PremiumStatusProvider
  let featureService: FeatureServiceProtocol

  init(
    capabilityService: CapabilityServiceProtocol, premiumStatusProvider: any PremiumStatusProvider,
    featureService: FeatureServiceProtocol
  ) {
    self.capabilityService = capabilityService
    self.premiumStatusProvider = premiumStatusProvider
    self.featureService = featureService
  }

  var requestInformation: AlertGenerator.RequestInformation {
    let format = AlertFormat(
      hiddenDataLeakForFreeUsersEnabled: isFreeUserHiddenAlertsFeatureEnabled)
    return AlertGenerator.RequestInformation(
      format: format, premiumInformation: premiumStatusProvider.status)
  }

  private var isFreeUserHiddenAlertsFeatureEnabled: Bool {
    capabilityService.capabilities[.dataLeak]?.enabled == false
  }
}

extension CorePremium.Status: PremiumInformation {
  public var isPremium: Bool {
    return b2bStatus?.statusCode == .inTeam || b2cStatus.statusCode == .subscribed
      || b2cStatus.statusCode == .legacy
  }
}
