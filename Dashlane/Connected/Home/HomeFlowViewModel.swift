import Combine
import CorePersonalData
import CoreSettings
import Foundation
import ImportKit
import SwiftUI
import UIComponents
import VaultKit
import NotificationKit
import CoreLocalization

@MainActor
final class HomeFlowViewModel: ObservableObject, SessionServicesInjecting, OnboardingChecklistActionHandler {

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

    let origin: OnboardingChecklistOrigin = .home

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
    let homeModalAnnouncementsViewModel: HomeModalAnnouncementsViewModel
    let deeplinkPublisher: AnyPublisher<DeepLink, Never>

    init(sessionServices: SessionServicesContainer) {
        self.sessionServices = sessionServices
        self.userSettings = sessionServices.spiegelUserSettings
        self.onboardingService = sessionServices.onboardingService
        self.deeplinkPublisher = sessionServices.appServices.deepLinkingService.homeDeeplinkPublisher()
        self.homeModalAnnouncementsViewModel = sessionServices.makeHomeModalAnnouncementsViewModel()

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

        sessionServices.lockService.locker.unlocked
            .sinkOnce { [weak self] _ in
                self?.homeModalAnnouncementsViewModel.trigger.send(.sessionUnlocked)
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
        func makeImportFlowView<Model: ImportFlowViewModel>(viewModel: Model) -> some View {
            return ImportFlowView(viewModel: viewModel) { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .popToRootView:
                    self.genericFullCover = nil
                case .dismiss:
                    self.genericFullCover = nil
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationBarButton(CoreLocalization.L10n.Core.cancel) {
                        self.genericFullCover = nil
                    }
                }
            }
        }

        switch importMethod {
        case .import(.csv):
            guard sessionServices.featureService.isEnabled(.keychainImport) else { return }
            let importFlowViewModel = sessionServices.makeKeychainImportFlowViewModel(applicationDatabase: sessionServices.database)
            genericFullCover = .init(view: makeImportFlowView(viewModel: importFlowViewModel))
        case .import(.dash):
            guard sessionServices.featureService.isEnabled(.dashImport) else { return }
            let importFlowViewModel = sessionServices.makeDashImportFlowViewModel(applicationDatabase: sessionServices.database, databaseDriver: sessionServices.databaseDriver)
            genericFullCover = .init(view: makeImportFlowView(viewModel: importFlowViewModel))
        case .import(.lastpass):
            guard sessionServices.featureService.isEnabled(.lastpassImport) else { return }
            let importFlowViewModel = sessionServices.makeLastpassImportFlowViewModel(applicationDatabase: sessionServices.database, userSettings: sessionServices.userSettings)
            genericFullCover = .init(view: makeImportFlowView(viewModel: importFlowViewModel))
        }
    }
}

private extension OnboardingService {
    var shouldDisplayOnboardingChecklistOnHome: Bool {
        !hasCreatedAtLeastOneItem && shouldShowOnboardingChecklist
    }
}
