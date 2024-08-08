import Combine
import CoreCategorizer
import CorePersonalData
import CoreSession
import DashTypes
import DomainParser
import Foundation
import UIKit
import VaultKit

class AddPrefilledCredentialViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var searchCriteria: String = ""

  let onboardingItems: [Credential]

  @Published
  var websites: [String] = []

  let iconViewModelProvider: (VaultItem) -> VaultItemIconViewModel
  let didChooseCredential: (Credential, Bool) -> Void
  let session: Session
  let personalDataURLDecoder: PersonalDataURLDecoderProtocol
  let allDomains: [String]

  private var cancellables = Set<AnyCancellable>()

  init(
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    session: Session,
    categorizer: CategorizerProtocol,
    personalDataURLDecoder: PersonalDataURLDecoderProtocol,
    prefilledCredentialsProvider: PrefilledCredentialsProviderProtocol,
    didChooseCredential: @escaping (Credential, Bool) -> Void
  ) {
    self.iconViewModelProvider = iconViewModelProvider
    self.session = session
    self.personalDataURLDecoder = personalDataURLDecoder
    self.didChooseCredential = didChooseCredential
    self.onboardingItems = prefilledCredentialsProvider.prefilledCredentials.map { $0.recreate() }
    allDomains = (try? categorizer.getAllDomains()) ?? []
    setupSearch()
  }

  func makeIconViewModel(for item: VaultItem) -> VaultItemIconViewModel {
    return iconViewModelProvider(item)
  }

  func validate() {
    didChooseCredential(makeCredential(from: searchCriteria), false)
  }

  func select(website: String) {
    didChooseCredential(makeCredential(from: website), false)
  }

  private func makeCredential(from url: String) -> Credential {
    var credential = Credential()
    credential.email = session.login.email
    if let url = try? personalDataURLDecoder.decodeURL(url) {
      credential.url = url
      if let domain = url.domain {
        credential.title = domain.name.removingPercentEncoding ?? domain.name
      }
    } else {
      credential.editableURL = url
    }
    return credential
  }

  private func setupSearch() {
    $searchCriteria
      .throttle(
        for: .milliseconds(200), scheduler: DispatchQueue.global(qos: .userInitiated), latest: true
      )
      .map { [allDomains] searchCriteria in
        let domains =
          allDomains
          .filter { $0.hasPrefix(searchCriteria) }
          .prefix(10)
        return [searchCriteria] + domains
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$websites)

    $websites
      .receive(on: DispatchQueue.global())
      .map { $0.joined(separator: ", ") }
      .receive(on: DispatchQueue.main)
      .sink { websites in
        UIAccessibility.fiberPost(.announcement, argument: websites)
      }
      .store(in: &cancellables)
  }
}

extension AddPrefilledCredentialViewModel {
  static var mock: AddPrefilledCredentialViewModel {
    .init(
      iconViewModelProvider: { item in .mock(item: item) },
      session: .mock,
      categorizer: CategorizerMock(),
      personalDataURLDecoder: PersonalDataURLDecoder(domainParser: FakeDomainParser()),
      prefilledCredentialsProvider: .mock(),
      didChooseCredential: { _, _ in }
    )
  }
}

extension Credential {
  fileprivate func recreate() -> Credential {
    var newCredential = Credential()
    newCredential.email = self.email
    newCredential.title = self.title
    newCredential.url = self.url
    return newCredential
  }
}
