import Combine
import DashTypes
import DashlaneAPI
import Foundation

public protocol ActivityLogsServiceProtocol {

  var isEnabled: Bool { get }

  func makeActivityLog(dataType: ActivityLogDataType, spaceId: String?) throws -> AuditLogDetails

  func report(_ action: ActivityLogsService.ItemAction, for info: ActivityLogReportableInfo) throws

  func report(
    _ action: ActivityLogsService.CollectionAction, for info: ActivityLogReportableInfoCollection)
    throws
}

public class ActivityLogsService: ActivityLogsServiceProtocol {
  public var isEnabled: Bool {
    return spaceIdWithActivtyLogsEnabled != nil
  }

  private let spaceIdWithActivtyLogsEnabled: String?
  private let reportService: ActivityLogsReportService

  public init(
    space: SpaceInformation?,
    apiClient: UserDeviceAPIClient.Teams.StoreActivityLogs,
    cryptoEngine: CryptoEngine,
    logger: Logger
  ) {

    if let space, space.collectSensitiveDataActivityLogsEnabled {
      spaceIdWithActivtyLogsEnabled = space.id
    } else {
      spaceIdWithActivtyLogsEnabled = nil
    }

    self.reportService = ActivityLogsReportService(
      apiClient: apiClient,
      cryptoEngine: cryptoEngine,
      logger: logger)
  }

  private func validateShouldSendActivityLogs(forSpaceID spaceId: String?) throws {
    guard let spaceId, !spaceId.isEmpty else {
      throw ActivityLogError.nonBusinessItem
    }
    guard spaceIdWithActivtyLogsEnabled == spaceId else {
      throw ActivityLogError.noBusinessTeamEnabledCollection
    }
  }

  public func makeActivityLog(dataType: ActivityLogDataType, spaceId: String?) throws
    -> AuditLogDetails
  {
    try validateShouldSendActivityLogs(forSpaceID: spaceId)
    return dataType.makeActivityLog()
  }

  public func report(_ action: ItemAction, for info: ActivityLogReportableInfo) throws {
    try validateShouldSendActivityLogs(forSpaceID: info.spaceId)
    Task {
      let log = ActivityLog(
        logType: info.logType(for: action),
        properties: info.properties)
      await self.reportService.report(log)
    }
  }

  public func report(_ action: CollectionAction, for info: ActivityLogReportableInfoCollection)
    throws
  {
    try validateShouldSendActivityLogs(forSpaceID: info.spaceId)
    Task {
      let log = ActivityLog(
        logType: info.logType(for: action),
        properties: info.properties)
      await self.reportService.report(log)
    }
  }
}

extension [SpaceInformation] {
  func isActivityLogsCollectionEnabled(forTeamWithId spaceId: String) -> Bool {
    return first(where: { $0.id == spaceId }) != nil
  }
}

extension ActivityLogsServiceProtocol where Self == ActivityLogsServiceMock {
  public static func mock(isEnabled: Bool = true) -> ActivityLogsServiceMock {
    ActivityLogsServiceMock(isEnabled: isEnabled)
  }
}

extension ActivityLogsService {
  public enum ItemAction {
    case creation
    case update
    case deletion
  }

  public enum CollectionAction {
    case creation
    case update
    case deletion
    case importCollection
    case addCredential
    case deleteCredential
  }
}
