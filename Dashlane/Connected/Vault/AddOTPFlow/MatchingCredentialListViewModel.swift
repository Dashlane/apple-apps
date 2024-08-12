import Combine
import CorePersonalData
import DashTypes
import Foundation
import VaultKit

class MatchingCredentialListViewModel: ObservableObject, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  let matchingCredentials: [Credential]
  let issuer: String
  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  private let completion: (Completion) -> Void

  enum Completion {
    case createCredential
    case linkToCredential(Credential)
  }

  init(
    website: String,
    matchingCredentials: [Credential],
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void
  ) {
    self.issuer = website
    self.matchingCredentials = matchingCredentials
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.completion = completion
  }

  func createCredential() {
    self.completion(.createCredential)
  }

  func link(to credential: Credential) {
    self.completion(.linkToCredential(credential))
  }
}

extension MatchingCredentialListViewModel {
  static func mock(
    website: String = "facebook.com",
    matchingCredentials: [Credential] = [
      PersonalDataMock.Credentials.netflix, PersonalDataMock.Credentials.adobe,
    ],
    completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void = { _ in }
  ) -> MatchingCredentialListViewModel {
    MatchingCredentialListViewModel(
      website: website,
      matchingCredentials: matchingCredentials,
      vaultItemIconViewModelFactory: .init { item in .mock(item: item) },
      completion: completion
    )
  }
}
