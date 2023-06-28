import Foundation
import CoreSession
import CorePersonalData
import DashTypes
import DomainParser
import DashlaneAppKit
import VaultKit
import CoreCategorizer

class AddPrefilledCredentialViewModel: ObservableObject, SessionServicesInjecting {
    @Published
    var searchCriteria: String = ""

    let onboardingItems: [Credential]

    @Published
    var websites: [String] = []

    let iconViewModelProvider: (VaultItem) -> VaultItemIconViewModel
    let didChooseCredential: (Credential, Bool) -> Void
    let session: Session
    let vaultItemsService: VaultItemsServiceProtocol
    let personalDataURLDecoder: PersonalDataURLDecoderProtocol
    let allDomains: [String]

    init(iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
         session: Session,
         categorizer: CategorizerProtocol,
         personalDataURLDecoder: PersonalDataURLDecoderProtocol,
         vaultItemsService: VaultItemsServiceProtocol,
         didChooseCredential: @escaping (Credential, Bool) -> Void) {
        self.iconViewModelProvider = iconViewModelProvider
        self.session = session
        self.personalDataURLDecoder = personalDataURLDecoder
        self.vaultItemsService = vaultItemsService
        self.didChooseCredential = didChooseCredential
        self.onboardingItems = vaultItemsService.prefilledCredentials.map({ $0.recreate() })
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
            .throttle(for: .milliseconds(200), scheduler: RunLoop.main, latest: true)
            .map { [allDomains] searchCriteria in
                Array(allDomains
                    .filter { $0.hasPrefix(searchCriteria) }
                    .prefix(10))
            }
            .assign(to: &$websites)
    }
}

extension AddPrefilledCredentialViewModel {
    static var mock: AddPrefilledCredentialViewModel {
        .init(iconViewModelProvider: { item in .mock(item: item) },
              session: .mock,
              categorizer: CategorizerMock(),
              personalDataURLDecoder: PersonalDataURLDecoder(domainParser: FakeDomainParser(), linkedDomainService: LinkedDomainService()),
              vaultItemsService: MockServicesContainer().vaultItemsService,
              didChooseCredential: { _, _ in })
    }
}

private extension Credential {
        func recreate() -> Credential {
        var newCredential = Credential()
        newCredential.email = self.email
        newCredential.title = self.title
        newCredential.url = self.url
        return newCredential
    }
}
