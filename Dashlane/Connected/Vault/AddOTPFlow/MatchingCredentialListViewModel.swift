import Foundation
import CorePersonalData
import Combine
import DashlaneAppKit
import VaultKit
import DashTypes

class MatchingCredentialListViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {

    let matchingCredentials: [Credential]
    let issuer: String
    let vaultItemRowModelFactory: VaultItemRowModel.Factory
    private let completion: (Completion) -> Void

    enum Completion {
        case createCredential
        case linkToCredential(Credential)
    }

    init(website: String,
         matchingCredentials: [Credential],
         vaultItemRowModelFactory: VaultItemRowModel.Factory,
         completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void) {
        self.issuer = website
        self.matchingCredentials = matchingCredentials
        self.vaultItemRowModelFactory = vaultItemRowModelFactory
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
        matchingCredentials: [Credential] = [PersonalDataMock.Credentials.netflix, PersonalDataMock.Credentials.adobe],
        completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void = { _ in }
    ) -> MatchingCredentialListViewModel {
        MatchingCredentialListViewModel(
            website: website,
            matchingCredentials: matchingCredentials,
            vaultItemRowModelFactory: .init { .mock(configuration: $0, additionalConfiguration: $1) },
            completion: completion
        )
    }
}
