import Foundation
import CorePersonalData
import Combine
import SwiftUI

@MainActor
class PasswordGeneratorToolsFlowViewModel: ObservableObject, SessionServicesInjecting, TabCoordinator {

    enum Step {
        case root
        case history
    }

    @Published
    var steps: [Step] = [.root]

    let deepLinkingService: DeepLinkingServiceProtocol
    let passwordGeneratorViewModelFactory: PasswordGeneratorViewModel.ThirdFactory
    let passwordGeneratorHistoryViewModelFactory: PasswordGeneratorHistoryViewModel.Factory

    let deepLinkShowPasswordHistoryPublisher: AnyPublisher<Void, Never>

        let tabBarImage = NavigationImageSet(image: FiberAsset.tabPwcGenOff,
                                         selectedImage: FiberAsset.tabPwcGenOn)
    let sidebarImage = NavigationImageSet(image: FiberAsset.tabPwcGenOff,
                                          selectedImage: FiberAsset.tabPwcGenOn)
    let title: String = L10n.Localizable.tabGeneratorTitle
    let tag: Int = ConnectedCoordinator.Tab.passwordGenerator.tabBarIndexValue
    let id = UUID()
    func start() {}
    lazy var viewController: UIViewController = {

                        let view = NavigationView {
            PasswordGeneratorToolsFlow(viewModel: self)
        }
        return UIHostingController(rootView: view)
    }()

    init(deepLinkingService: DeepLinkingServiceProtocol,
         passwordGeneratorViewModelFactory: PasswordGeneratorViewModel.ThirdFactory,
         passwordGeneratorHistoryViewModelFactory: PasswordGeneratorHistoryViewModel.Factory) {
        self.deepLinkingService = deepLinkingService
        self.passwordGeneratorViewModelFactory = passwordGeneratorViewModelFactory
        self.passwordGeneratorHistoryViewModelFactory = passwordGeneratorHistoryViewModelFactory

        deepLinkShowPasswordHistoryPublisher = deepLinkingService.deepLinkPublisher
            .filter({ deepLink -> Bool in
                guard case let .tool(component, _) = deepLink else {
                    return false
                }

                guard case let .otherTool(other) = component else {
                    return false
                }

                switch other {
                case .history:
                    return true
                default:
                    return false
                }
            })
            .mapToVoid()

    }

    func makePasswordGeneratorViewModel() -> PasswordGeneratorViewModel {

        let action: (PasswordGeneratorMode.StandaloneAction) -> Void = { [weak self ] action in
            guard let self else { return }
            switch action {
            case .showHistory:
                self.steps.append(.history)
            case let .createCredential(password):
                self.deepLinkingService.handleLink(.prefilledCredential(password: password))
            }
        }

        return passwordGeneratorViewModelFactory.make(mode: .standalone(action))
    }

    func showHistory() {
        self.steps.append(.history)
    }
}

extension PasswordGeneratorToolsFlowViewModel {
    static var mock: PasswordGeneratorToolsFlowViewModel {
        .init(deepLinkingService: DeepLinkingService.fakeService,
              passwordGeneratorViewModelFactory: .init({ _ in .mock }),
              passwordGeneratorHistoryViewModelFactory: .init({ .mock() }))
    }
}
