import Foundation
import CorePersonalData
import Combine
import SwiftUI
import DashlaneAppKit
import VaultKit
import DashTypes

class CredentialsListViewModel: ObservableObject, SessionServicesInjecting {
    
    enum CredentialsListSubScene {
        case credentialDetails(CredentialDetailsViewModel)
    }
    
    private var rawCredentials: [Credential] = [] {
        didSet {
            filterCredentials(using: currentSearch)
        }
    }
    
    @Published
    private(set) var credentials: [CredentialRowViewModel] = []
    
    @Published var currentSearch: String = "" {
        didSet {
            filterCredentials(using: currentSearch)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    let vaultItemsService: VaultItemsServiceProtocol
    let syncService: SyncServiceProtocol
    let iconService: IconServiceProtocol
    let popoverOpeningService: PopoverOpeningService
    let makeCredentialsRowViewModels: ([Credential]) -> [CredentialRowViewModel]
    let makeCredentialDetailsViewModel: (Credential, VaultItemIconViewModel) -> CredentialDetailsViewModel

    init(vaultItemsService: VaultItemsServiceProtocol,
         syncService: SyncServiceProtocol,
         iconService: IconServiceProtocol,
         popoverOpeningService: PopoverOpeningService,
         makeCredentialsRowViewModels: @escaping ([Credential]) -> [CredentialRowViewModel],
         makeCredentialDetailsViewModel: @escaping (Credential, VaultItemIconViewModel) -> CredentialDetailsViewModel) {
        self.vaultItemsService = vaultItemsService
        self.syncService = syncService
        self.iconService = iconService
        self.popoverOpeningService = popoverOpeningService
        self.makeCredentialsRowViewModels = makeCredentialsRowViewModels
        self.makeCredentialDetailsViewModel = makeCredentialDetailsViewModel
        vaultItemsService.$credentials
            .sink(receiveValue: { items in
                self.rawCredentials = items
        }).store(in: &cancellables)
        
        popoverOpeningService.publisher.sink { opening in
            guard opening == .afterTimeLimit else { return }
            self.currentSearch = ""
        }.store(in: &cancellables)
    }
    
    private func filterCredentials(using criteria: String) {
        guard !criteria.isEmpty else {
            credentials = makeCredentialsRowViewModels(self.rawCredentials)
            return
        }
        let lowercasedCriteria = criteria.lowercased()
        let filtered = self.rawCredentials
            .filter { $0.match(lowercasedCriteria) != nil }
        self.credentials = makeCredentialsRowViewModels(filtered)
    }
    
    func makeDetailsViewModel(for viewModel: CredentialRowViewModel) -> CredentialDetailsViewModel {
        makeCredentialDetailsViewModel(viewModel.item, viewModel.iconViewModel)
    }
}

extension CredentialsListViewModel {
    static func mock(emptyList: Bool) -> CredentialsListViewModel {

        let container = MockServicesContainer()

        if emptyList {
            container.vaultItemsService.credentials = []
        }
        
        return CredentialsListViewModel(vaultItemsService: container.vaultItemsService,
                                 syncService: container.syncService,
                                 iconService: container.iconService,
                                 popoverOpeningService: PopoverOpeningService(),
                                 makeCredentialsRowViewModels: { $0.map({ credential in CredentialRowViewModel.mock(credential: credential) }) },
                                 makeCredentialDetailsViewModel: { credential,_  in CredentialDetailsViewModel.mock(credential: credential) })

    }
}
