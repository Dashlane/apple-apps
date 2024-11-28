import Combine
import CorePersonalData
import CoreUserTracking
import Foundation
import Network
import UIComponents
import VaultKit

class CredentialDomainsViewModel {
  var item: Credential
  var linkedDomains: [String] {
    item.url?.domain?.linkedDomains ?? []
  }
  let canAddDomain: Bool
  let isAdditionMode: Bool
  let initialMode: DetailMode

  private let vaultItemsStore: VaultItemsStore
  private let activityReporter: ActivityReporterProtocol
  private let updatePublisher:
    PassthroughSubject<CredentialDetailViewModel.LinkedServicesUpdate, Never>

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
  }

  func commit(addedDomains: LinkedServices) {
    updatePublisher.send(.commit(addedDomains: addedDomains))
  }

  func save(addedDomains: LinkedServices) {
    updatePublisher.send(.save(addedDomains: addedDomains))
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
