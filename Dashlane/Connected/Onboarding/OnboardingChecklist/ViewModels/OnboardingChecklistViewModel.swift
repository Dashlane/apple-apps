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
import VaultKit
import AutofillKit
import CoreSession

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
    private let activityReporter: ActivityReporterProtocol
    var cancellables = Set<AnyCancellable>()
    let userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory

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
    var dismissability: OnboardingChecklistDismissability = .nonDismissable

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
    private let session: Session

    init(session: Session,
         userSettings: UserSettings,
         dwmOnboardingSettings: DWMOnboardingSettings,
         dwmOnboardingService: DWMOnboardingService,
         vaultItemsService: VaultItemsServiceProtocol,
         capabilityService: CapabilityServiceProtocol,
         featureService: FeatureServiceProtocol,
         onboardingService: OnboardingService,
         autofillService: AutofillService,
         activityReporter: ActivityReporterProtocol,
         action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
         userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory) {
        self.session = session
        self.userSettings = userSettings
        self.featureService = featureService
        self.dwmOnboardingSettings = dwmOnboardingSettings
        self.dwmOnboardingService = dwmOnboardingService
        self.vaultItemsService = vaultItemsService
        self.onboardingService = onboardingService
        self.autofillService = autofillService
        self.activityReporter = activityReporter
        self.capabilityService = capabilityService
        self.userSpaceSwitcherViewModelFactory = userSpaceSwitcherViewModelFactory
        self.action = action
        self.secureNoteState = SecureNoteState(isSecureNoteDisabled: featureService.isEnabled(.disableSecureNotes),
                                               isSecureNoteLimited: capabilityService.state(of: .secureNotes) == .needsUpgrade)
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
            showDismissAnimation {
                self.dismiss()
            }
        } else {
            self.dismiss()
        }
    }

        func setupChecklist() {
        self.actions = []

                self.actions.append(checklistFirstAction())

                self.actions.append(.activateAutofill)

                if session.configuration.info.accountType != .invisibleMasterPassword {
            self.actions.append(.mobileToDesktop)
        }
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
        case .mobileToDesktop:
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
        action(.ctaTapped(action: checklistAction))
    }

    func updateOnAppear() {
        action(.onAppear)
        preLoadAnimation()
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
        return capabilityService.statePublisher(of: .secureNotes).eraseToAnyPublisher().map { state -> SecureNoteState in
            SecureNoteState(isSecureNoteDisabled: self.isSecureNoteDisabled,
                            isSecureNoteLimited: state == .needsUpgrade)
        }
        .eraseToAnyPublisher()
    }
}

extension OnboardingChecklistViewModel {
    static var mock: OnboardingChecklistViewModel {
        OnboardingChecklistViewModel(
            session: .mock,
            userSettings: .mock,
            dwmOnboardingSettings: .init(internalStore: .mock()),
            dwmOnboardingService: .mock,
            vaultItemsService: MockVaultConnectedContainer().vaultItemsService,
            capabilityService: .mock(),
            featureService: .mock(),
            onboardingService: .mock,
            autofillService: .fakeService,
            activityReporter: .fake,
            action: { _ in },
            userSpaceSwitcherViewModelFactory: .init({ .mock })
        )
    }
}
