import Combine
import CoreSession
import CoreSettings
import CoreSpotlight
import Foundation

final class VaultItemsSpotlightService: VaultKitServicesInjecting {

  private let vaultItemsStore: VaultItemsStore
  private let userSettings: UserSettings
  private let spotlightIndexer: SpotlightIndexer?

  private var itemsSubcriptions: Set<AnyCancellable> = []

  init(
    vaultItemsStore: VaultItemsStore,
    userSettings: UserSettings,
    spotlightIndexer: SpotlightIndexer?
  ) {
    self.vaultItemsStore = vaultItemsStore
    self.userSettings = userSettings
    self.spotlightIndexer = spotlightIndexer

    configureSpotlightIndexation()
  }

  func unload(reason: SessionServicesUnloadReason) {
    if case .userLogsOut = reason {
      spotlightIndexer?.deleteAll()
    }
  }

  private func spotlightPublisher() -> AnyPublisher<[SpotLightSearchable & VaultItem], Never> {
    let credentials = vaultItemsStore.$credentials
      .map { $0 as [SpotLightSearchable & VaultItem] }
      .eraseToAnyPublisher()

    let creditCards = vaultItemsStore.$creditCards
      .map { $0 as [SpotLightSearchable & VaultItem] }
      .eraseToAnyPublisher()

    let bankAccount = vaultItemsStore.$bankAccounts
      .map { $0 as [SpotLightSearchable & VaultItem] }
      .eraseToAnyPublisher()

    let passports = vaultItemsStore.$passports
      .map { $0 as [SpotLightSearchable & VaultItem] }
      .eraseToAnyPublisher()

    let driverLicenses = vaultItemsStore.$drivingLicenses
      .map { $0 as [SpotLightSearchable & VaultItem] }
      .eraseToAnyPublisher()

    let ids = vaultItemsStore.$idCards
      .map { $0 as [SpotLightSearchable & VaultItem] }
      .eraseToAnyPublisher()

    let fiscalInformation = vaultItemsStore.$fiscalInformation
      .map { $0 as [SpotLightSearchable & VaultItem] }
      .eraseToAnyPublisher()

    return [
      credentials,
      creditCards,
      bankAccount,
      passports,
      driverLicenses,
      ids,
      fiscalInformation,
    ]
    .combineLatest()
    .map { $0.flatMap { $0 } }
    .eraseToAnyPublisher()
  }

  func configureSpotlightIndexation() {
    guard let indexer = spotlightIndexer else { return }

    userSettings
      .publisher(for: .advancedSystemIntegration)
      .filter { $0 == true }
      .flatMap { [weak self] _ -> AnyPublisher<[SpotLightSearchable & VaultItem], Never> in
        guard let self else {
          return Just([]).eraseToAnyPublisher()
        }
        return self.spotlightPublisher()
      }
      .debounce(
        for: .seconds(2), scheduler: DispatchQueue(label: "com.dashlane.SpotlightIndexation")
      )
      .map { vaultItems in
        return vaultItems.compactMap(CSSearchableItem.init)
      }
      .receive(on: DispatchQueue.main)
      .sink { items in
        indexer.deleteIndexedItems(for: .vaultItem) {
          indexer.index(items)
        }
      }
      .store(in: &itemsSubcriptions)

    userSettings
      .publisher(for: .advancedSystemIntegration)
      .filter { $0 == false }
      .sink { _ in
        indexer.deleteIndexedItems(for: .vaultItem)
      }
      .store(in: &itemsSubcriptions)
  }
}
