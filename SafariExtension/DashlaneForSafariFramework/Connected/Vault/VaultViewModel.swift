import Foundation
import Combine
import CorePersonalData
import Combine

class VaultViewModel: TabActivable {
    
    var scene: VaultViewScenes
    
    var cancellables = Set<AnyCancellable>()
    
    var isActive: CurrentValueSubject<Bool, Never> = .init(true)

    init(sessionServicesContainer: SessionServicesContainer) {
        let factory = sessionServicesContainer.viewModelFactory
        let credentialsList = factory.makeCredentialsListViewModel(makeCredentialsRowViewModels: { $0.makeCredentialsRowViewModels(viewModelFactory: factory) })
        self.scene = .credentialsList(credentialsList)
        
        credentialsList.$credentials.sink { [weak self] credentials in
            guard let self = self else { return }
            if credentials.isEmpty {
                self.scene = .emptyVault(EmptyVaultViewModel(safariExtensionService: sessionServicesContainer.appServices.safariExtensionService))
            } else {
                self.scene = .credentialsList(credentialsList)
            }
        }.store(in: &cancellables)
    }
}

private extension Array where Element == Credential {
    func makeCredentialsRowViewModels(viewModelFactory: ViewModelFactory) -> Array<CredentialRowViewModel> {
        self
            .alphabeticallySorted()
            .compactMap { viewModelFactory.makeCredentialRowViewModel(item: $0) }
    }
}
