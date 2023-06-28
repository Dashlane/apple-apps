import Foundation
import CoreActivityLogs
import CorePremium
import Combine
import CoreFeature
import DashTypes
import DashlaneAPI

public extension ActivityLogsService {
    convenience init(premiumService: PremiumServiceProtocol,
                     featureService: FeatureServiceProtocol,
                     apiClient: UserDeviceAPIClient.Teams.StoreActivityLogs,
                     cryptoEngine: CryptoEngine,
                     logger: Logger) {
        self.init(spaces: premiumService.status?.spaces ?? [],
                  featureService: featureService,
                  apiClient: apiClient,
                  cryptoEngine: cryptoEngine,
                  logger: logger)
    }

    convenience init(spaces: [Space],
                     featureService: FeatureServiceProtocol,
                     apiClient: UserDeviceAPIClient.Teams.StoreActivityLogs,
                     cryptoEngine: CryptoEngine,
                     logger: Logger) {
        guard featureService.isEnabled(.auditLogsIsAvailable) else {
            self.init(spaces: [],
                      apiClient: apiClient,
                      cryptoEngine: cryptoEngine,
                      logger: logger)
            return
        }

        let spaces = spaces
            .filter({ $0.info.collectSensitiveDataAuditLogsEnabled ?? false })
            .map({
                CoreActivityLogs.SpaceInformation(id: $0.teamId,
                                                  collectSensitiveDataActivityLogsEnabled: $0.info.collectSensitiveDataAuditLogsEnabled ?? false)
            })
        self.init(spaces: spaces,
                  apiClient: apiClient,
                  cryptoEngine: cryptoEngine,
                  logger: logger)
    }
}
