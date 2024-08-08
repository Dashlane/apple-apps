import Combine
import CoreActivityLogs
import CoreFeature
import CorePremium
import DashTypes
import DashlaneAPI
import Foundation

extension ActivityLogsService {
  public convenience init(
    premiumStatusProvider: PremiumStatusProvider,
    featureService: FeatureServiceProtocol,
    apiClient: UserDeviceAPIClient.Teams.StoreActivityLogs,
    cryptoEngine: CryptoEngine,
    logger: Logger
  ) {
    self.init(
      team: premiumStatusProvider.status.b2bStatus?.currentTeam,
      featureService: featureService,
      apiClient: apiClient,
      cryptoEngine: cryptoEngine,
      logger: logger)
  }

  public convenience init(
    team: CurrentTeam?,
    featureService: FeatureServiceProtocol,
    apiClient: UserDeviceAPIClient.Teams.StoreActivityLogs,
    cryptoEngine: CryptoEngine,
    logger: Logger
  ) {
    guard featureService.isEnabled(.auditLogsIsAvailable) else {
      self.init(
        space: nil,
        apiClient: apiClient,
        cryptoEngine: cryptoEngine,
        logger: logger)
      return
    }

    let space = team.map {
      SpaceInformation(
        id: String($0.teamId),
        collectSensitiveDataActivityLogsEnabled: $0.teamInfo.collectSensitiveDataAuditLogsEnabled
          == true)
    }

    self.init(
      space: space,
      apiClient: apiClient,
      cryptoEngine: cryptoEngine,
      logger: logger)
  }
}
