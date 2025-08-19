import Combine
import CoreFeature
import CorePremium
import CoreSession
import CoreTeamAuditLogs
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

extension TeamAuditLogsService {
  public init(
    premiumStatusProvider: PremiumStatusProvider,
    featureService: FeatureServiceProtocol,
    logsAPIClient: UserSecureNitroEncryptionAPIClient.Logs,
    cryptoEngine: CryptoEngine,
    session: Session,
    target: BuildTarget,
    logger: Logger
  ) throws {
    try self.init(
      team: premiumStatusProvider.status.b2bStatus?.currentTeam,
      featureService: featureService,
      logsAPIClient: logsAPIClient,
      cryptoEngine: cryptoEngine,
      session: session,
      target: target,
      logger: logger)
  }

  public init(
    team: CurrentTeam?,
    featureService: FeatureServiceProtocol,
    logsAPIClient: UserSecureNitroEncryptionAPIClient.Logs,
    cryptoEngine: CryptoEngine,
    session: Session,
    target: BuildTarget,
    logger: Logger
  ) throws {
    guard featureService.isEnabled(.auditLogsIsAvailable) else {
      self.init(
        space: nil,
        logsAPIClient: logsAPIClient,
        cryptoEngine: cryptoEngine,
        storeURL: try session.directory.storeURL(for: .teamAuditLogs, in: target),
        logger: logger)
      return
    }

    let space = team.map {
      SpaceInformation(
        id: String($0.teamId),
        collectSensitiveDataAuditLogsEnabled: $0.teamInfo.collectSensitiveDataAuditLogsEnabled
          == true)
    }

    self.init(
      space: space,
      logsAPIClient: logsAPIClient,
      cryptoEngine: cryptoEngine,
      storeURL: try session.directory.storeURL(for: .teamAuditLogs, in: target),
      logger: logger)
  }
}
