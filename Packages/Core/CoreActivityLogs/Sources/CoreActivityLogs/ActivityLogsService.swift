import Foundation
import DashlaneAPI
import Combine
import DashTypes

public protocol ActivityLogsServiceProtocol {

            var isCollectionEnabled: Bool { get }

                                func makeActivityLog(dataType: ActivityLogDataType, spaceId: String?) throws -> AuditLogDetails

                                    func report(_ action: ActivityLogsService.ItemAction, for info: ActivityLogReportableInfo) throws
}

public class ActivityLogsService: ActivityLogsServiceProtocol {

    private let spacesUsingActivityLogsCollection: [SpaceInformation]
    private let reportService: ActivityLogsReportService

    public var isCollectionEnabled: Bool {
        return !spacesUsingActivityLogsCollection.isEmpty
    }

    public init(spaces: [SpaceInformation],
                apiClient: UserDeviceAPIClient.Teams.StoreActivityLogs,
                cryptoEngine: CryptoEngine,
                logger: Logger) {
        self.spacesUsingActivityLogsCollection = spaces.filter({ $0.collectSensitiveDataActivityLogsEnabled })
        self.reportService = ActivityLogsReportService(apiClient: apiClient,
                                                       cryptoEngine: cryptoEngine,
                                                       logger: logger)
    }

    private func validateShouldSendActivityLogs(forSpaceID spaceId: String?) throws {
        guard let spaceId, !spaceId.isEmpty else {
            throw ActivityLogError.nonBusinessItem
        }
        guard spacesUsingActivityLogsCollection.isActivityLogsCollectionEnabled(forTeamWithId: spaceId) else {
            throw ActivityLogError.noBusinessTeamEnabledCollection
        }
    }

    public func makeActivityLog(dataType: ActivityLogDataType, spaceId: String?) throws -> AuditLogDetails {
        try validateShouldSendActivityLogs(forSpaceID: spaceId)
        return dataType.makeActivityLog()
    }

    private func isActivityLogsCollectionEnabled(forTeamWithId spaceId: String) -> Bool {
        return spacesUsingActivityLogsCollection.first(where: { $0.id == spaceId }) != nil
    }

    public func report(_ action: ItemAction, for info: ActivityLogReportableInfo) throws {
        try validateShouldSendActivityLogs(forSpaceID: info.spaceId)
        Task {
            let log = ActivityLog(logType: info.logType(for: action),
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

public extension ActivityLogsServiceProtocol where Self == ActivityLogsServiceMock {
    static func mock(isActivityLogEnabled: Bool = true) -> ActivityLogsServiceMock {
        ActivityLogsServiceMock(isActivityLogEnabled: isActivityLogEnabled)
    }
}

extension ActivityLogsService {
        public enum ItemAction {
        case creation
        case update
        case deletion
    }
}
