import Combine
import CorePersonalData
import CoreSharing
import CoreUserTracking
import DashTypes

public protocol VaultCollectionDatabaseProtocol {
  func collectionsPublisher() -> AnyPublisher<[VaultCollection], Never>

  @discardableResult func createPrivateCollection(
    _ collection: VaultCollection,
    named: String
  ) async throws -> VaultCollection

  func delete(_ collection: VaultCollection) async throws
  func dispatchDelete(_ collection: VaultCollection)

  func save(_ collection: VaultCollection) async throws -> VaultCollection

  func share(
    _ collections: [VaultCollection],
    teamId: Int?,
    recipients: [String],
    userGroupIds: [Identifier],
    permission: SharingPermission
  ) async throws
}

extension VaultCollectionDatabaseProtocol where Self == VaultCollectionDatabase {
  static func mock(
    driver: DatabaseDriver = InMemoryDatabaseDriver(),
    sharingService: SharingServiceProtocol = SharingServiceMock()
  ) -> VaultCollectionDatabase {
    return .init(
      logger: LoggerMock(),
      database: .mock(driver: driver),
      sharingService: sharingService,
      userSpacesService: .mock(),
      activityReporter: ActivityReporterMock(),
      activityLogsService: .mock()
    )
  }
}
