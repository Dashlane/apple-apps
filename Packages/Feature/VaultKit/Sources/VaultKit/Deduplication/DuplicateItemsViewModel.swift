import Combine
import CorePersonalData
import CorePremium
import Foundation

public class DuplicateItemsViewModel: ObservableObject, VaultKitServicesInjecting {

  enum State {
    case loading
    case foundDuplicates(items: [VaultItem])
    case noDuplicates
  }

  @Published
  var state: State = .loading

  var cancellables = Set<AnyCancellable>()

  let vaultItemDatabase: VaultItemDatabaseProtocol
  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  let userSpacesService: UserSpacesService

  @Published
  var userSpacesConfiguration: UserSpacesService.SpacesConfiguration

  public init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    userSpacesService: UserSpacesService
  ) {
    self.vaultItemDatabase = vaultItemDatabase
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.userSpacesService = userSpacesService

    self.userSpacesConfiguration = userSpacesService.configuration
    userSpacesService.$configuration.assign(to: &$userSpacesConfiguration)

    loadDuplicatedItems()
  }

  func loadDuplicatedItems() {
    vaultItemDatabase.duplicatedItems()
      .receive(on: DispatchQueue.main)
      .sink { items in
        if items.isEmpty {
          self.state = .noDuplicates
        } else {
          self.state = .foundDuplicates(items: items)
        }
      }.store(in: &cancellables)
  }

  func confirmDeduplication(for items: [VaultItem]) {
    for item in items {
      vaultItemDatabase.dispatchDelete(item)
    }
  }
}

extension VaultItemDatabaseProtocol {

  fileprivate func duplicatedItems() -> AnyPublisher<[VaultItem], Never> {
    let credentialPublisher = itemsPublisher(for: Credential.self)
    let secureNotesPublisher = itemsPublisher(for: SecureNote.self)
    let creditCardsPublisher = itemsPublisher(for: CreditCard.self)
    let bankAccountsPublisher = itemsPublisher(for: BankAccount.self)
    let publishers = credentialPublisher.combineLatest(
      secureNotesPublisher,
      creditCardsPublisher,
      bankAccountsPublisher)
    return
      publishers
      .receive(on: DispatchQueue.global())
      .map { credentials, secureNotes, creditCards, bankAccounts -> [VaultItem] in
        var duplicates: [VaultItem] = []
        duplicates.append(contentsOf: credentials.duplicates())
        duplicates.append(contentsOf: secureNotes.duplicates())
        duplicates.append(contentsOf: creditCards.duplicates())
        duplicates.append(contentsOf: bankAccounts.duplicates())
        return duplicates
      }
      .map { duplicates in
        return duplicates.itemsWithoutAttachments()
      }
      .eraseToAnyPublisher()
  }

}

extension [VaultItem] {
  fileprivate func itemsWithoutAttachments() -> [VaultItem] {
    self.filter({ !$0.hasAttachments })
  }
}

extension DuplicateItemsViewModel {
  public static func mock() -> DuplicateItemsViewModel {
    DuplicateItemsViewModel(
      vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
      vaultItemIconViewModelFactory: .init { item in .mock(item: item) },
      userSpacesService: .mock()
    )
  }
}
