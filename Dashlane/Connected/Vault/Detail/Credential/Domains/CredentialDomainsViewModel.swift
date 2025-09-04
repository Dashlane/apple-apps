import Combine
import CorePersonalData
import CoreTypes
import Foundation
import Network
import UIComponents
import UserTrackingFoundation
import VaultKit

@MainActor
final class CredentialDomainsViewModel: ObservableObject {
  var item: Credential
  var linkedDomains: [String] {
    item.url?.domain?.linkedDomains ?? []
  }
  let canAddDomain: Bool
  let isAdditionMode: Bool
  let initialMode: DetailMode

  @Published
  var addedDomains: [EditableDomain]
  private var addedDomainsChanged = false

  @Published
  var duplicatedCredential: DuplicatePrompt?

  private let vaultItemsStore: VaultItemsStore
  private let activityReporter: ActivityReporterProtocol
  private let updatePublisher:
    PassthroughSubject<CredentialDetailViewModel.LinkedServicesUpdate, Never>

  private var cancellables: [AnyCancellable] = []

  init(
    item: Credential,
    isAdditionMode: Bool,
    initialMode: DetailMode,
    isFrozen: Bool,
    vaultItemsStore: VaultItemsStore,
    activityReporter: ActivityReporterProtocol,
    updatePublisher: PassthroughSubject<CredentialDetailViewModel.LinkedServicesUpdate, Never>
  ) {
    self.item = item
    self.isAdditionMode = isAdditionMode
    self.initialMode = initialMode
    self.canAddDomain = item.canAddDomain && !isFrozen
    self.vaultItemsStore = vaultItemsStore
    self.activityReporter = activityReporter
    self.updatePublisher = updatePublisher
    addedDomains = item.linkedServices.associatedDomains.map({ EditableDomain(content: $0) })
    if isAdditionMode {
      addedDomains.append(
        EditableDomain(content: LinkedServices.AssociatedDomain(domain: "", source: .manual)))
    }

    self.$addedDomains
      .dropFirst()
      .sink { [weak self] _ in
        self?.addedDomainsChanged = true
      }
      .store(in: &self.cancellables)
  }

  func save() {
    guard self.addedDomainsChanged else {
      return
    }

    let addedDomains = self.addedDomains
      .compactMap {
        if let domain = validDomain($0.content.domain) {
          return EditableDomain(
            id: $0.id,
            content: LinkedServices.AssociatedDomain(domain: domain, source: $0.content.source))
        }
        return nil
      }
    self.addedDomains = addedDomains
    updatePublisher.send(
      .save(addedDomains: LinkedServices(associatedDomains: addedDomains.map({ $0.content }))))
  }

  private func validDomain(_ urlString: String) -> String? {
    let urlWithScheme = urlString.hasPrefix("http") ? urlString : "_\(urlString)"
    guard let url = URL(string: urlWithScheme),
      let host = url.host
    else {
      return nil
    }
    return host
  }

  private lazy var credentialDomainsPairs: [(credential: Credential, domain: String)] = Array(
    vaultItemsStore.credentials.map({ credential -> [(credential: Credential, domain: String)] in
      guard credential != self.item else {
        return []
      }

      let urls = credential.allDomains()

      return urls.map { (credential: credential, domain: $0.lowercased()) }
    }).joined())

  func hasDuplicate(for domain: String) -> Credential? {
    guard let createdUrl = domain.openableURL?.host?.lowercased() else {
      return nil
    }

    for keyPair in credentialDomainsPairs where keyPair.domain == createdUrl {
      return keyPair.credential
    }

    return nil
  }

  func checkDuplicate(of uuid: UUID, completion: @escaping () -> Void) {
    guard let addedDomain = addedDomains.first(where: { $0.id == uuid }),
      duplicatedCredential == nil
    else {
      completion()
      return
    }

    if let duplicate = hasDuplicate(for: addedDomain.content.domain) {
      duplicatedCredential = DuplicatePrompt(
        domain: addedDomain, title: duplicate.displayTitle, completion: completion)
      return
    }

    if addedDomains.filter({ $0.content.domain == addedDomain.content.domain }).count > 1 {
      duplicatedCredential = DuplicatePrompt(
        domain: addedDomain, title: item.displayTitle, completion: completion)
      return
    }

    if !linkedDomains.filter({ $0 == addedDomain.content.domain }).isEmpty {
      duplicatedCredential = DuplicatePrompt(
        domain: addedDomain, title: item.displayTitle, completion: completion)
      return
    }

    if duplicatedCredential == nil {
      completion()
    }
  }
}

extension CredentialDomainsViewModel {
  static var mock: CredentialDomainsViewModel {
    CredentialDomainsViewModel(
      item: PersonalDataMock.Credentials.amazon,
      isAdditionMode: false,
      initialMode: .viewing,
      isFrozen: false,
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      activityReporter: .mock,
      updatePublisher: PassthroughSubject<CredentialDetailViewModel.LinkedServicesUpdate, Never>())
  }
}

extension Credential {
  var canAddDomain: Bool {
    return !metadata.isShared || metadata.sharingPermission != .limited
  }
}
