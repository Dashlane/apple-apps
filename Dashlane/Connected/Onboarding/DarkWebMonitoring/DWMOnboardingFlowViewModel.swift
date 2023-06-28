import Combine
import CoreSession
import CoreSettings
import Foundation
import SwiftUI

@MainActor
final class DWMOnboardingFlowViewModel: ObservableObject, SessionServicesInjecting {

    enum Completion {
        case back
        case skip
        case unexpectedError
    }

    enum Step {
        case dwmCheckSuggested(DWMRegistrationInGuidedOnboardingViewModel)
        case emailConfirmation(DWMEmailConfirmationViewModel)
    }

    @Published
    var steps: [Step]

    private let email: String
    private let completion: (Completion) -> Void

        let transitionHandler: GuidedOnboardingTransitionHandler?

        private let dwmOnboardingSettings: DWMOnboardingSettings

        private let registrationInGuidedOnboardingVModelFactory: DWMRegistrationInGuidedOnboardingViewModel.Factory
    private let emailConfirmationViewModelFactory: DWMEmailConfirmationViewModel.Factory

    private var delayedViewPresentationSubscription: AnyCancellable?

    init(
        transitionHandler: GuidedOnboardingTransitionHandler?,
        session: Session,
        dwmOnboardingSettings: DWMOnboardingSettings,
        registrationInGuidedOnboardingVModelFactory: DWMRegistrationInGuidedOnboardingViewModel.Factory,
        emailConfirmationViewModelFactory: DWMEmailConfirmationViewModel.Factory,
        completion: @escaping (DWMOnboardingFlowViewModel.Completion) -> Void
    ) {
        self.transitionHandler = transitionHandler
        self.email = session.login.email

        self.dwmOnboardingSettings = dwmOnboardingSettings

        self.registrationInGuidedOnboardingVModelFactory = registrationInGuidedOnboardingVModelFactory
        self.emailConfirmationViewModelFactory = emailConfirmationViewModelFactory

        self.completion = completion
        self.steps = []
        self.steps.append(.dwmCheckSuggested(makeRegistrationViewForGuidedOnboardingViewModel()))
    }

        private func performUponEnteringForeground(_ block: @escaping () -> Void) {
        delayedViewPresentationSubscription = NotificationCenter.default
            .publisher(for: UIApplication.applicationWillEnterForegroundNotification)
            .sink { _ in block() }
    }

    func handleRegistrationInGuidedOnboardingViewAction(_ action: DWMRegistrationInGuidedOnboardingView.Action) {
        switch action {
        case .back:
            completion(.back)
        case .skip:
            completion(.skip)
        case .mailAppOpened:
            performUponEnteringForeground {
                self.steps = [.emailConfirmation(self.makeEmailConfirmationViewModel(emailStatusCheck: .delayed))]
            }
        case .userIndicatedEmailConfirmed:
            steps = [.emailConfirmation(makeEmailConfirmationViewModel(emailStatusCheck: .instant))]
        case .unexpectedError:
            completion(.unexpectedError)
        }
    }

    func handleEmailConfirmationViewAction(_ action: DWMEmailConfirmationView.Action) {
        switch action {
        case .cancel:
            steps.removeLast()
        case .unexpectedError:
            completion(.unexpectedError)
        case .skip:
            completion(.skip)
        }
    }

        private func makeRegistrationViewForGuidedOnboardingViewModel() -> DWMRegistrationInGuidedOnboardingViewModel {
        registrationInGuidedOnboardingVModelFactory.make(email: email)
    }

    private func makeEmailConfirmationViewModel(
        emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy
    ) -> DWMEmailConfirmationViewModel {
        emailConfirmationViewModelFactory.make(accountEmail: email, emailStatusCheck: emailStatusCheck)
    }
}

extension DWMOnboardingFlowViewModel {
    static func mock() -> DWMOnboardingFlowViewModel {
        return .init(
            transitionHandler: nil,
            session: .mock,
            dwmOnboardingSettings: .init(internalStore: .mock()),
            registrationInGuidedOnboardingVModelFactory: .init { _ in .mock() },
            emailConfirmationViewModelFactory: .init { _, _ in .mock(state: .emailNotConfirmedYet) },
            completion: { _ in }
        )
    }
}
