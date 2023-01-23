import Combine
import CorePersonalData
import CoreSettings
import Foundation
import ImportKit
import SwiftUI

@MainActor
final class HomeFlowViewModel: ObservableObject, TabCoordinator, SessionServicesInjecting, OnboardingChecklistActionHandler {

    enum DisplayedScreen: Equatable {
        case onboardingChecklist(OnboardingChecklistFlowViewModel)
        case homeView(VaultFlowViewModel)

        static func == (lhs: DisplayedScreen, rhs: DisplayedScreen) -> Bool {
            switch (lhs, rhs) {
            case (.onboardingChecklist, .onboardingChecklist):
                return true
            case (.homeView, .homeView):
                return true
            default:
                return false
            }
        }
    }

        let tag: Int = 0
    let id: UUID = .init()

    let title: String = L10n.Localizable.mainMenuHomePage
    let tabBarImage = NavigationImageSet(
        image: FiberAsset.tabIconHomeOff,
        selectedImage: FiberAsset.tabIconHomeOn
    )
    let sidebarImage = NavigationImageSet(
        image: FiberAsset.sidebarHome,
        selectedImage: FiberAsset.sidebarHomeSelected
    )

    var viewController: UIViewController {
        let controller = UIHostingController(rootView: HomeFlow(viewModel: self))
        controller.tabBarItem.selectedImage = FiberAsset.tabIconHomeOn.image
        controller.tabBarItem.image = FiberAsset.tabIconHomeOff.image
        controller.tabBarItem.title = L10n.Localizable.mainMenuHomePage
        return controller
    }

        @Published
    var currentScreen: DisplayedScreen?

    @Published
    var genericSheet: GenericSheet?

    @Published
    var genericFullCover: GenericSheet?

        private var cancellables: Set<AnyCancellable> = []

        let sessionServices: SessionServicesContainer
    private let userSettings: UserSettings
    private let onboardingService: OnboardingService

    init(sessionServices: SessionServicesContainer) {
        self.sessionServices = sessionServices
        self.userSettings = sessionServices.spiegelUserSettings
        self.onboardingService = sessionServices.onboardingService
    }

    func start() {
        update()
    }

    private func update() {
        let nextScreen: DisplayedScreen
        if onboardingService.shouldDisplayOnboardingChecklistOnHome {
            nextScreen = .onboardingChecklist(makeOnboardingCheckListFlowViewModel())
        } else {
            nextScreen = .homeView(makeVaultFlowViewModel())
        }

        guard nextScreen != currentScreen else { return }

        self.currentScreen = nextScreen
        switch nextScreen {
        case .onboardingChecklist:
            setupSettingsSubscription()
        default:
            break
        }
    }

    private func setupSettingsSubscription() {
        userSettings.settingsChangePublisher
            .sink { [weak self] key in
                switch key {
                case .hasUserDismissedOnboardingChecklist, .hasUserUnlockedOnboardingChecklist, .hasCreatedAtLeastOneItem:
                    self?.update()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func dismissOnboardingChecklistFlow() {
        guard case .onboardingChecklist = currentScreen else { return }
        currentScreen = nil
    }
}

private extension HomeFlowViewModel {
    func makeVaultFlowViewModel() -> VaultFlowViewModel {
        sessionServices.makeVaultFlowViewModel(onboardingChecklistViewAction: { self.handleOnboardingChecklistViewAction($0) })
    }

    func makeOnboardingCheckListFlowViewModel() -> OnboardingChecklistFlowViewModel {
        sessionServices.makeOnboardingChecklistFlowViewModel(
            displayMode: .root,
            onboardingChecklistViewAction: handleOnboardingChecklistViewAction
        ) { [weak self] completion in
            switch completion {
            case .dismiss:
                self?.currentScreen = nil
            }
        }
    }
}

extension HomeFlowViewModel {
    func displaySearch(for query: String) {
        guard case let .homeView(vaultFlowViewModel) = currentScreen else { return }
        vaultFlowViewModel.displaySearch(for: query)
    }

    func handle(_ deepLink: VaultDeeplink) {
        guard case let .homeView(vaultFlowViewModel) = currentScreen else { return }
        vaultFlowViewModel.handle(deepLink)
    }

    func createCredential(using password: GeneratedPassword) {
        switch currentScreen {
        case .homeView(let vaultFlowViewModel):
            vaultFlowViewModel.createCredential(using: password)
        case .onboardingChecklist:
            addNewItem(displayMode: .prefilledPassword(password))
        default:
            break
        }
    }

    func canHandle(deepLink: VaultDeeplink) -> Bool {
        guard case let .homeView(vaultFlowViewModel) = currentScreen else { return false }
        return vaultFlowViewModel.canHandle(deepLink: deepLink)
    }
}

extension HomeFlowViewModel {
    func presentImport(for importMethod: ImportMethodDeeplink) {
        func makeImportFlowView<Model: ImportFlowViewModel>(viewModel: Model) -> ImportFlowView<Model> {
            return ImportFlowView(viewModel: viewModel) { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .popToRootView:
                    self.genericFullCover = nil
                case .dismiss:
                    self.genericFullCover = nil
                }
            }
        }

        switch importMethod {
        case .import(.csv):
            guard sessionServices.featureService.isEnabled(.keychainImport) else { return }
            let importFlowViewModel = KeychainImportFlowViewModel(
                fromDeeplink: true,
                personalDataURLDecoder: sessionServices.appServices.personalDataURLDecoder,
                applicationDatabase: sessionServices.database,
                iconService: sessionServices.iconService,
                activityReporter: sessionServices.activityReporter)
            genericFullCover = .init(view: makeImportFlowView(viewModel: importFlowViewModel))
        case .import(.dash):
            guard sessionServices.featureService.isEnabled(.dashImport) else { return }
            let importFlowViewModel = DashImportFlowViewModel(
                fromDeeplink: true,
                personalDataURLDecoder: sessionServices.appServices.personalDataURLDecoder,
                applicationDatabase: sessionServices.database,
                databaseDriver: sessionServices.databaseDriver,
                iconService: sessionServices.iconService,
                activityReporter: sessionServices.activityReporter)
            genericFullCover = .init(view: makeImportFlowView(viewModel: importFlowViewModel))
        }
    }
}

private extension OnboardingService {
    var shouldDisplayOnboardingChecklistOnHome: Bool {
        !hasCreatedAtLeastOneItem && shouldShowOnboardingChecklist
    }
}
