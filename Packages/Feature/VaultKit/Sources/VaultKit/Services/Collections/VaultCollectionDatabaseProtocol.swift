import Combine
import CorePersonalData
import CoreSharing
import CoreTypes
import LogFoundation
import UserTrackingFoundation

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
  public static func mock(
    driver: DatabaseDriver = InMemoryDatabaseDriver(),
    sharingService: SharingServiceProtocol = SharingServiceMock()
  ) -> VaultCollectionDatabase {
    return .init(
      logger: .mock,
      database: .mock(driver: driver),
      sharingService: sharingService,
      userSpacesService: .mock(),
      activityReporter: ActivityReporterMock(),
      teamAuditLogsService: .mock()
    )
  }
}
