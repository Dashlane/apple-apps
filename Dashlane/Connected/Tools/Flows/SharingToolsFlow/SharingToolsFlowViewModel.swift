import Foundation
import SwiftUI
import VaultKit
import Combine

@MainActor
class SharingToolsFlowViewModel: ObservableObject, SessionServicesInjecting {

    enum Step {
        case root
        case credentialDetails(VaultItem)
    }

    @Published
    var steps: [Step] = [.root]

    let accessControl: AccessControlProtocol
    let detailViewFactory: DetailView.Factory
    let sharingToolViewModelFactory: SharingToolViewModel.Factory
    var cancellables = Set<AnyCancellable>()

    init(accessControl: AccessControlProtocol,
         detailViewFactory: DetailView.Factory,
         sharingToolViewModelFactory: SharingToolViewModel.Factory) {
        self.accessControl = accessControl
        self.detailViewFactory = detailViewFactory
        self.sharingToolViewModelFactory = sharingToolViewModelFactory
    }

    func makeShowVaultItemAction() -> ShowVaultItemAction {
        .init { [weak self] item in
            self?.showDetail(for: item)
        }
    }

    func showDetail(for item: VaultItem) {
        if let secureItem = item as? SecureItem, secureItem.secured {
            accessControl.requestAccess().sink { [weak self] success in
                if success {
                    self?.steps.append(.credentialDetails(item))
                }
            }.store(in: &cancellables)
        } else {
            self.steps.append(.credentialDetails(item))
        }
    }
}

 extension SharingToolsFlowViewModel {
    static var mock: SharingToolsFlowViewModel {
        .init(accessControl: FakeAccessControl(accept: true),
              detailViewFactory: .init({ _, _ in fatalError() }),
              sharingToolViewModelFactory: .init({ .mock(itemsProvider: .mock(), teamSpacesService: .mock(), sharingService: SharingServiceMock())}))
    }
 }
