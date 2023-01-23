import Foundation
import SwiftUI
import Combine
import SecurityDashboard
import DashlaneAppKit
import SwiftTreats

enum DWMOnboardingPresentationContext {
    case guidedOnboarding
    case onboardingChecklist
}

class DWMOnboardingCoordinator: Coordinator, SubcoordinatorOwner {

    enum Completion {
        case back
        case skip
        case unexpectedError
    }

    var subcoordinator: Coordinator?

    private let context: DWMOnboardingPresentationContext
    private let navigator: DashlaneNavigationController

        private let transitionHandler: GuidedOnboardingTransitionHandler?

    private let sessionServices: SessionServicesContainer
    lazy var detailFactory = DetailViewFactory(sessionServices: sessionServices)
    private let dwmOnboardingService: DWMOnboardingService
    private var progress: DWMOnboardingProgress?
    private let completion: (Completion) -> Void
    private var delayedViewPresentationSubscription: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init(context: DWMOnboardingPresentationContext, navigator: DashlaneNavigationController, transitionHandler: GuidedOnboardingTransitionHandler? = nil, sessionServices: SessionServicesContainer, completion: @escaping (Completion) -> Void) {
        self.context = context
        self.navigator = navigator
        self.transitionHandler = transitionHandler
        self.sessionServices = sessionServices
        self.dwmOnboardingService = sessionServices.dwmOnboardingService
        self.completion = completion

        dwmOnboardingService.progressPublisher().assign(to: \.progress, on: self).store(in: &cancellables)
    }

    func start() {
        switch context {
        case .guidedOnboarding:
            move(to: .dwmCheckSuggested)
        case .onboardingChecklist:
            moveNextDependingOnProgress()
        }
    }

        private func moveNextDependingOnProgress() {
        guard context == .onboardingChecklist else {
            assertionFailure("This method should be used only in the context of Onboarding Checklist")
            return
        }

        switch progress {
        case .none, .shown:
            move(to: .dwmCheckSuggested)
        case .emailRegistrationRequestSent, .emailConfirmed:
            move(to: .emailConfirmationRequested)
        case .breachesFound:
            sessionServices.appServices.deepLinkingService.handleLink(.tool(.darkWebMonitoring, origin: "onboarding_vault"))
        case .breachesNotFound:
            showAddPasswordFlow()
        }
    }

    private enum Step {
        case dwmCheckSuggested
        case emailConfirmationRequested
        case mailAppOpened
        case fetchingEmailConfirmationStatus
    }

    private func move(to step: Step) {
        switch step {
        case .dwmCheckSuggested:
            if context == .onboardingChecklist {
                navigator.push(makeRegistrationViewForOnboardingChecklist())
            } else {
                navigator.push(makeRegistrationViewForGuidedOnboarding())
            }
        case .emailConfirmationRequested:
                        if context == .onboardingChecklist {
                navigator.push(makeRegistrationViewForOnboardingChecklist())
            }
        case .mailAppOpened:
                        performUponEnteringForeground { [weak self] in
                self?.fetchEmailConfirmationStatus(userInitiated: false)
            }
        case .fetchingEmailConfirmationStatus:
                        fetchEmailConfirmationStatus(userInitiated: true)
        }
    }

                private func fetchEmailConfirmationStatus(userInitiated: Bool) {
        switch context {
        case .guidedOnboarding:
            self.delayedViewPresentationSubscription?.cancel()
            navigator.setRootNavigation(makeEmailConfirmationView(context: .guidedOnboarding, emailStatusCheck: userInitiated ? .instant : .delayed))
        case .onboardingChecklist:
            let modalNavigator = DashlaneNavigationController()
            modalNavigator.modalPresentationStyle = Device.isIpadOrMac ? .formSheet : .fullScreen
            modalNavigator.isModalInPresentation = true
            modalNavigator.setRootNavigation(makeEmailConfirmationView(context: .onboardingChecklist, emailStatusCheck: userInitiated ? .instant : .delayed))
            navigator.present(modalNavigator, animated: true)
        }
    }

    private func makeRegistrationViewForGuidedOnboarding() -> DWMEmailRegistrationInGuidedOnboardingView<DWMRegistrationInGuidedOnboardingViewModel> {
        let viewModel = sessionServices.viewModelFactory.makeDWMRegistrationInGuidedOnboardingViewModel(email: sessionServices.session.login.email) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .back:
                self.completion(.back)
            case .skip:
                self.completion(.skip)
            case .registrationRequestSent:
                self.move(to: .emailConfirmationRequested)
            case .mailAppOpened:
                self.move(to: .mailAppOpened)
            case .userIndicatedEmailConfirmed:
                self.move(to: .fetchingEmailConfirmationStatus)
            case .unexpectedError:
                self.completion(.unexpectedError)
            }
        }
        return DWMEmailRegistrationInGuidedOnboardingView(viewModel: viewModel)
    }

    private func makeRegistrationViewForOnboardingChecklist() -> DWMRegistrationInOnboardingChecklistView<DWMRegistrationInOnboardingChecklistViewModel> {
        let viewModel = sessionServices.viewModelFactory.makeDWMRegistrationInOnboardingChecklistViewModel(email: sessionServices.session.login.email) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .back:
                self.completion(.back)
            case .mailAppOpened:
                self.move(to: .mailAppOpened)
            case .userIndicatedEmailConfirmed:
                self.move(to: .fetchingEmailConfirmationStatus)
            case .unexpectedError:
                self.completion(.unexpectedError)
            case .registrationRequestSent:
                                break
            case .skip:
                assertionFailure("Not expected in the context of Onboarding Checklist")
            }
        }
        return DWMRegistrationInOnboardingChecklistView(viewModel: viewModel)
    }

        private func makeEmailConfirmationView(context: DWMOnboardingPresentationContext, emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy) -> DWMEmailConfirmationView<DWMEmailConfirmationViewModel> {
        let viewModel = sessionServices.viewModelFactory.makeDWMEmailConfirmationViewModel(accountEmail: sessionServices.session.login.email, context: context, emailStatusCheck: emailStatusCheck) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .cancel:
                self.navigator.presentedViewController?.dismiss(animated: true)
            case .emailConfirmedFromChecklist:
                self.sessionServices.dwmOnboardingSettings[.hasConfirmedEmailFromOnboardingChecklist] = true
                self.moveNextDependingOnProgress()
                self.navigator.presentedViewController?.dismiss(animated: true)
            case .unexpectedError:
                self.dismissModalInOnboardingChecklist()
                self.completion(.unexpectedError)
            case .skip:
                self.dismissModalInOnboardingChecklist()
                self.completion(.skip)
            }
        }
        return DWMEmailConfirmationView(viewModel: viewModel, transitionHandler: transitionHandler)
    }

        private func showAddPasswordFlow() {

        let mode: ImportMethodMode = {
            let settingsProvider = GuidedOnboardingSettingsProvider(userSettings: sessionServices.spiegelUserSettings)

            if let selectedAnswer = settingsProvider.storedAnswers[.howPasswordsHandled] {
                switch selectedAnswer {
                case .memorizePasswords, .somethingElse:
                    return .firstPassword
                case .browser:
                    return .browser
                default:
                    return .firstPassword
                }
            }

            return .firstPassword
        }()

        subcoordinator = ImportMethodCoordinator(contextNavigator: nil, internalNavigator: navigator, sessionServices: sessionServices, mode: mode) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .finished:
                self.navigator.popToRootViewController(animated: true)
                self.subcoordinator = nil
            }
        }
        subcoordinator?.start()
    }

    private func cancelFetchingEmailConfirmationStatus() {
        switch context {
        case .guidedOnboarding:
            self.move(to: .dwmCheckSuggested)
        case .onboardingChecklist:
            self.navigator.presentedViewController?.dismiss(animated: true)
        }
    }

    private func performUponEnteringForeground(_ block: @escaping () -> Void) {
        delayedViewPresentationSubscription = NotificationCenter.default.publisher(for: UIApplication.applicationWillEnterForegroundNotification).sink {_ in
            block()
        }
    }

    private func dismissModalInOnboardingChecklist() {
        if self.context == .onboardingChecklist {
            self.navigator.presentedViewController?.dismiss(animated: true)
        }
    }
}
