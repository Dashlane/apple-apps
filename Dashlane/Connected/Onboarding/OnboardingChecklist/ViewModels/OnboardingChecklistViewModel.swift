import Foundation
import Combine
import AuthenticationServices
import Lottie
import CoreFeature
import DashlaneAppKit
import CoreUserTracking
import CoreSettings
import DashTypes
import UIComponents
import CorePremium
import NotificationKit

enum OnboardingChecklistDismissability: String {
    case nonDismissable
    case dismissableTimeOver
    case dismissableAllDone
}

class OnboardingChecklistViewModel: ObservableObject, SessionServicesInjecting {

    let userSettings: UserSettings
    let dwmOnboardingSettings: DWMOnboardingSettings
    let dwmOnboardingService: DWMOnboardingService
    let vaultItemsService: VaultItemsServiceProtocol
    private let onboardingService: OnboardingService
    let autofillService: AutofillService
    private let featureService: FeatureServiceProtocol
    private let capabilityService: CapabilityServiceProtocol
    private let logsService: OnboardingChecklistLogsService
    private let activityReporter: ActivityReporterProtocol
    var cancellables = Set<AnyCancellable>()
    let userSwitcherViewModel: UserSpaceSwitcherViewModel

    var isSecureNoteDisabled: Bool {
        featureService.isEnabled(.disableSecureNotes)
    }

    var actions: [OnboardingChecklistAction] = []

    private var animationLoadingTask: Task<LottieAnimation?, Never>?

    @Published
    var hasAtLeastOnePassword: Bool = false

    @Published
    var hasFinishedChromeImportAtLeastOnce: Bool = false

    @Published
    var isAutofillActivated: Bool = false

    @Published
    var hasFinishedM2WAtLeastOnce: Bool = false

    @Published
    var hasSeenDWMExperience: Bool = false

    @Published
    var selectedAction: OnboardingChecklistAction?

    @Published
    var dismissability: OnboardingChecklistDismissability = .nonDismissable {
        didSet {
            if oldValue != dismissability {
                logsService.log(.checklistDismissabilityUpdate(dismissability: dismissability))
            }
        }
    }

    @Published
    var dismissButtonCTA: String?

    @Published
    var hasConfirmedEmailFromOnboardingChecklist: Bool = false

    @Published
    var hasUserDismissedOnboardingChecklist: Bool = false

    @Published
    var hasUserUnlockedOnboardingChecklist: Bool = false

    @Published
    var dwmOnboardingProgress: DWMOnboardingProgress?

    @Published
    var secureNoteState: SecureNoteState

    let action: (OnboardingChecklistFlowViewModel.Action) -> Void

    let modalAnnouncementsViewModel: HomeModalAnnouncementsViewModel
    let lockService: LockServiceProtocol

    init(userSettings: UserSettings,
         dwmOnboardingSettings: DWMOnboardingSettings,
         dwmOnboardingService: DWMOnboardingService,
         vaultItemsService: VaultItemsServiceProtocol,
         capabilityService: CapabilityServiceProtocol,
         featureService: FeatureServiceProtocol,
         onboardingService: OnboardingService,
         autofillService: AutofillService,
         logsService: OnboardingChecklistLogsService,
         lockService: LockServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         userSwitcherViewModel: @escaping () -> UserSpaceSwitcherViewModel,
         action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
         homeModalAnnouncementsViewModelFactory: HomeModalAnnouncementsViewModel.Factory
    ) {
        self.userSettings = userSettings
        self.featureService = featureService
        self.dwmOnboardingSettings = dwmOnboardingSettings
        self.dwmOnboardingService = dwmOnboardingService
        self.vaultItemsService = vaultItemsService
        self.onboardingService = onboardingService
        self.autofillService = autofillService
        self.logsService = logsService
        self.activityReporter = activityReporter
        self.capabilityService = capabilityService
        self.userSwitcherViewModel = userSwitcherViewModel()
        self.action = action
        self.secureNoteState = SecureNoteState(isSecureNoteDisabled: featureService.isEnabled(.disableSecureNotes),
                                               isSecureNoteLimited: capabilityService.state(of: .secureNotes) == .needsUpgrade)
        modalAnnouncementsViewModel = homeModalAnnouncementsViewModelFactory.make()
        self.lockService = lockService
        setupSubscriptions()
        setupChecklist()
        updateDismissability()
    }

    func setupSelectedAction() {
        self.selectedAction = actions.first(where: { completionState(for: $0) == .todo })
    }

    func updateDismissability() {
        if allDone() {
            dismissability = .dismissableAllDone
            dismissButtonCTA = L10n.Localizable.onboardingChecklistV2DismissAction
        } else if onboardingService.isNewUser() == false {
            dismissability = .dismissableTimeOver
            dismissButtonCTA = L10n.Localizable.onboardingChecklistV2DismissTimeOver
        } else {
            dismissability = .nonDismissable
            dismissButtonCTA = nil
        }
    }

    func allDone() -> Bool {
        guard !actions.isEmpty else { return false }
        return !actions.contains { completionState(for: $0) == .todo }
    }

    @MainActor
    func didTapDismiss() {
        self.userSettings[.hasUserDismissedOnboardingChecklist] = true

                if allDone() {
            logsService.log(.checklistDismissed(dismissal: .allDone))
            showDismissAnimation {
                self.dismiss()
            }
        } else {
            logsService.log(.checklistDismissed(dismissal: .timeOver))
            self.dismiss()
        }
    }

        func setupChecklist() {
        self.actions = []

                self.actions.append(checklistFirstAction())

                self.actions.append(contentsOf: [.activateAutofill, .m2d])

        logsService.log(.checklistDisplayed(actions: actions))
        setupSelectedAction()
    }

        private func checklistFirstAction() -> OnboardingChecklistAction {
        if hasConfirmedEmailFromOnboardingChecklist && dwmOnboardingProgress == .breachesNotFound {
            return .seeScanResult
        }

                if dwmOnboardingService.canShowDWMOnboarding && (dwmOnboardingProgress == .emailRegistrationRequestSent || dwmOnboardingProgress == .emailConfirmed || dwmOnboardingProgress == .breachesFound) {
            return .fixBreachedAccounts
        }

                let settingsProvider = GuidedOnboardingSettingsProvider(userSettings: userSettings)

        if let selectedAnswer = settingsProvider.storedAnswers[.howPasswordsHandled] {
            switch selectedAnswer {
            case .memorizePasswords, .somethingElse:
                return .addFirstPasswordsManually
            case .browser:
                return .importFromBrowser
            default:
                assertionFailure("Unacceptable answer")
            }
        }

                return .addFirstPasswordsManually
    }

    enum CompletionState {
        case completed
        case todo
    }

    func completionState(for action: OnboardingChecklistAction) -> CompletionState {
        switch action {
        case .addFirstPasswordsManually:
            return hasAtLeastOnePassword ? .completed : .todo
        case .importFromBrowser:
            return hasAtLeastOnePassword ? .completed : .todo
        case .activateAutofill:
            return isAutofillActivated ? .completed : .todo
        case .m2d:
            return hasFinishedM2WAtLeastOnce ? .completed : .todo
        case .fixBreachedAccounts:
            return hasSeenDWMExperience ? .completed : .todo
        case .seeScanResult:
            return hasAtLeastOnePassword ? .completed : .todo
        }
    }

    func showDetails(_ action: OnboardingChecklistAction) {
        guard completionState(for: action) == .todo else { return }
        selectedAction = action
    }

    func start(_ checklistAction: OnboardingChecklistAction) {
        logsService.log(.checklistActionSelected(action: checklistAction))
        action(.ctaTapped(action: checklistAction))
    }

    func updateOnAppear() {
        action(.onAppear)
    }

    func preLoadAnimation() {
        animationLoadingTask = Task { () -> LottieAnimation? in
            return LottieAsset.onboardingConfettis.animation()
        }
    }

    func dismiss() {
        self.cancellables.forEach { $0.cancel() }
        action(.onDismiss)
    }

    func onAddItemDropdown() {
        activityReporter.reportPageShown(.homeAddItemDropdown)
    }

    func addNewItemAction(mode: AddItemFlowViewModel.DisplayMode) {
        action(.addNewItem(displayMode: mode))
    }

    @MainActor
    private func showDismissAnimation(completion: @escaping () -> Void) {
        Task {
            guard let animation = await animationLoadingTask?.value else { return }
            let animationView = LottieAnimationView(animation: animation)

            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                let animation = animationView
                animation.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                animation.contentMode = .scaleAspectFill
                animation.loopMode = .playOnce
                animation.animationSpeed = 1
                animation.isUserInteractionEnabled = false
                window.addSubview(animation)
                animation.frame = window.bounds
            }

            completion()
            animationView.play { _ in
                animationView.removeFromSuperview()
            }
        }
    }

    private func secureNoteStatePublisher() -> AnyPublisher<SecureNoteState, Never> {
        return capabilityService.statePublisher(of: .secureNotes).map { state -> SecureNoteState in
            SecureNoteState(isSecureNoteDisabled: self.isSecureNoteDisabled,
                            isSecureNoteLimited: state == .needsUpgrade)
        }
        .eraseToAnyPublisher()
    }
}

extension OnboardingChecklistViewModel {
    static var mock: OnboardingChecklistViewModel {
        OnboardingChecklistViewModel(
            userSettings: .mock,
            dwmOnboardingSettings: .init(internalStore: InMemoryLocalSettingsStore()),
            dwmOnboardingService: .mock,
            vaultItemsService: MockVaultConnectedContainer().vaultItemsService,
            capabilityService: CapabilityService.mock,
            featureService: .mock(),
            onboardingService: .mock,
            autofillService: .fakeService,
            logsService: .init(usageLogService: UsageLogService.fakeService),
            lockService: LockServiceMock(),
            activityReporter: .fake,
            userSwitcherViewModel: { .mock },
            action: { _ in },
            homeModalAnnouncementsViewModelFactory: .init { .mock }
        )
    }
}
