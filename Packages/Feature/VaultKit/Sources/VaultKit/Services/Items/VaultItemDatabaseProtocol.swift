import Combine
import CorePersonalData
import CoreTypes
import DashlaneAPI
import LogFoundation

public protocol VaultItemDatabaseProtocol {
  func itemsPublisher<Output: VaultItem>(for output: Output.Type) -> AnyPublisher<[Output], Never>
  func itemPublisher<Output: VaultItem>(for vaultItem: Output) -> AnyPublisher<Output, Never>

  func fetchedPersonalData<Output: VaultItem>(for output: Output.Type) -> FetchedPersonalData<
    Output
  >
  func fetch<Output: VaultItem>(with identifier: Identifier, type: Output.Type) throws -> Output?

  func delete(_ vaultItem: VaultItem) async throws
  func dispatchDelete(_ vaultItem: VaultItem)

  func save<Item: VaultItem>(_ item: Item) throws -> Item
  func save<Item: VaultItem>(_ items: [Item]) throws -> [Item]

  func count<Item: VaultItem>(for type: Item.Type) throws -> Int
  func link(_ generatedPassword: GeneratedPassword, to credential: Credential) throws
    -> GeneratedPassword

  func updateLastUseDate(of items: [VaultItem], origin: Set<LastUseUpdateOrigin>)
  func sharedItem(with id: Identifier) -> VaultItem?
}

extension VaultItemDatabaseProtocol where Self == VaultItemDatabase {
  public static func mock(driver: DatabaseDriver = InMemoryDatabaseDriver()) -> VaultItemDatabase {
    return .init(
      logger: .mock,
      database: .mock(driver: driver),
      sharingService: SharedVaultHandlerMock(),
      featureService: .mock(),
      userSpacesService: .mock(),
      teamAuditLogsService: .mock(),
      cloudPasskeyService: .fake
    )
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys {
  public static var fake: UserSecureNitroEncryptionAPIClient.Passkeys {
    UserSecureNitroEncryptionAPIClient.fake.passkeys
  }
}
