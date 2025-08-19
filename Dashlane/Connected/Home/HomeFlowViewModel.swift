import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CoreSettings
import Foundation
import ImportKit
import NotificationKit
import PremiumKit
import SwiftUI
import UIComponents
import VaultKit

@MainActor
final class HomeFlowViewModel: ObservableObject, SessionServicesInjecting,
  OnboardingChecklistActionHandler
{

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

  @Published
  var remainingActionsCount: Int = 0

  private var cancellables: Set<AnyCancellable> = []

  let sessionServices: SessionServicesContainer
  private let userSettings: UserSettings
  private let onboardingService: OnboardingService
  private let featureService: FeatureService
  private let lockService: LockService
  private let deeplinkService: DeepLinkingServiceProtocol
  private let lastpassImportFlowViewModelFactory: LastpassImportFlowViewModel.Factory
  private let vaultFlowViewModelFactory: VaultFlowViewModel.Factory
  private let onboardingChecklistFlowViewModel: OnboardingChecklistFlowViewModel.Factory

  let homeModalAnnouncementsViewModel: HomeModalAnnouncementsViewModel
  let deeplinkPublisher: AnyPublisher<DeepLink, Never>

  init(
    sessionServices: SessionServicesContainer,
    userSettings: UserSettings,
    onboardingService: OnboardingService,
    featureService: FeatureService,
    lockService: LockService,
    deeplinkService: DeepLinkingServiceProtocol,
    homeModalAnnouncementsViewModelFactory: HomeModalAnnouncementsViewModel.Factory,
    lastpassImportFlowViewModelFactory: LastpassImportFlowViewModel.Factory,
    vaultFlowViewModelFactory: VaultFlowViewModel.Factory,
    onboardingChecklistFlowViewModel: OnboardingChecklistFlowViewModel.Factory
  ) {
    self.sessionServices = sessionServices
    self.userSettings = userSettings
    self.onboardingService = onboardingService
    self.featureService = featureService
    self.lockService = lockService
    self.deeplinkService = deeplinkService
    self.lastpassImportFlowViewModelFactory = lastpassImportFlowViewModelFactory
    self.vaultFlowViewModelFactory = vaultFlowViewModelFactory
    self.onboardingChecklistFlowViewModel = onboardingChecklistFlowViewModel
    self.deeplinkPublisher = deeplinkService.homeDeeplinkPublisher()
    self.homeModalAnnouncementsViewModel = homeModalAnnouncementsViewModelFactory.make()

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

    onboardingService.$remainingActions
      .receive(on: DispatchQueue.main)
      .map { [onboardingService] actions in
        return if onboardingService.shouldShowOnboardingChecklist {
          actions.count
        } else {
          0
        }
      }
      .assign(to: &$remainingActionsCount)

    sessionServices.vaultStateService.vaultStatePublisher()
      .receive(on: DispatchQueue.main)
      .filter { $0 == .frozen }
      .sinkOnce { [deeplinkService] _ in
        deeplinkService.handleLink(
          .premium(.planPurchase(initialView: .paywall(trigger: .frozenAccount))))
      }
  }

  func displayAnnouncementIffNeeded() {
    lockService.locker.unlockedPublisher
      .delay(for: .seconds(1), scheduler: DispatchQueue.main)
      .sinkOnce { [weak self] _ in
        self?.homeModalAnnouncementsViewModel.trigger.send(.sessionUnlocked)
      }
  }

  private func setupSettingsSubscription() {
    userSettings.settingsChangePublisher
      .sink { [weak self] key in
        switch key {
        case .hasUserDismissedOnboardingChecklist, .hasUserUnlockedOnboardingChecklist,
          .hasCreatedAtLeastOneItem:
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

extension HomeFlowViewModel {
  fileprivate func makeVaultFlowViewModel() -> VaultFlowViewModel {
    vaultFlowViewModelFactory.make { [weak self] in
      self?.handleOnboardingChecklistViewAction($0)
    }
  }

  fileprivate func makeOnboardingCheckListFlowViewModel() -> OnboardingChecklistFlowViewModel {
    onboardingChecklistFlowViewModel.make(
      displayMode: .root,
      onboardingChecklistViewAction: { [weak self] in
        self?.handleOnboardingChecklistViewAction($0)
      },
      completion: { [weak self] completion in
        switch completion {
        case .dismiss:
          self?.currentScreen = nil
        }
      })
  }
}

extension HomeFlowViewModel {
  func handle(_ deepLink: VaultDeeplink) {
    guard let currentScreen else { return }

    switch currentScreen {
    case .homeView(let viewModel):
      if viewModel.canHandle(deepLink: deepLink) {
        viewModel.handle(deepLink)
      }

    case .onboardingChecklist:
      if case .create(let component) = deepLink {
        addNewItem(displayMode: .itemType(component.type))
      }
    }
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
          Button(CoreL10n.cancel) {
            self.genericFullCover = nil
          }
        }
      }
    }

    switch importMethod {
    case .import(.csv):
      guard featureService.isEnabled(.keychainImport) else { return }
      let importFlowViewModel = sessionServices.makeKeychainImportFlowViewModel(
        applicationDatabase: sessionServices.database)
      genericFullCover = .init(view: makeImportFlowView(viewModel: importFlowViewModel))
    case .import(.dash):
      guard featureService.isEnabled(.dashImport) else { return }
      let importFlowViewModel = sessionServices.makeDashImportFlowViewModel(
        applicationDatabase: sessionServices.database,
        databaseDriver: sessionServices.databaseDriver)
      genericFullCover = .init(view: makeImportFlowView(viewModel: importFlowViewModel))
    case .import(.lastpass):
      guard featureService.isEnabled(.lastpassImport) else { return }
      let importFlowViewModel = sessionServices.makeLastpassImportFlowViewModel(
        applicationDatabase: sessionServices.database, userSettings: userSettings)
      genericFullCover = .init(view: makeImportFlowView(viewModel: importFlowViewModel))
    }
  }
}

extension OnboardingService {
  fileprivate var shouldDisplayOnboardingChecklistOnHome: Bool {
    !hasCreatedAtLeastOneItem && shouldShowOnboardingChecklist
  }
}
