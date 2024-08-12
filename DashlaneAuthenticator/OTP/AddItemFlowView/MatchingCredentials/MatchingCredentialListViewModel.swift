import AuthenticatorKit
import Combine
import CorePersonalData
import DashTypes
import Foundation
import VaultKit

typealias MatchingCredentialListViewModelCompletion = MatchingCredentialListViewModel.Completion

class MatchingCredentialListViewModel: ObservableObject, AuthenticatorServicesInjecting,
  AuthenticatorMockInjecting
{
  enum Completion {
    case createCredential
    case linkToCredential(Credential)
  }

  let matchingCredentials: [Credential]
  let issuer: String
  let credentialRowFactory: CredentialRowViewModel.Factory
  private let completion: (Completion) -> Void

  init(
    website: String,
    matchingCredentials: [Credential],
    credentialRowFactory: CredentialRowViewModel.Factory,
    completion: @escaping (MatchingCredentialListViewModelCompletion) -> Void
  ) {
    self.issuer = website
    self.matchingCredentials = matchingCredentials
    self.credentialRowFactory = credentialRowFactory
    self.completion = completion
  }

  func makeCredentialRowViewModel(credential: Credential) -> CredentialRowViewModel {
    credentialRowFactory.make(item: credential)
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
    completion: @escaping (MatchingCredentialListViewModelCompletion) -> Void = { _ in }
  ) -> MatchingCredentialListViewModel {
    AuthenticatorMockContainer().makeMatchingCredentialListViewModel(
      website: website, matchingCredentials: matchingCredentials, completion: completion)
  }
}
