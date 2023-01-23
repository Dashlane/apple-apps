import Foundation
import SwiftUI
import SecurityDashboard
import DashTypes
import Combine
import DashlaneAppKit

enum DWMScanState {
    case fetchingEmailConfirmationStatus
    case emailNotConfirmedYet
    case breachesFound
    case breachesNotFound
}

protocol DWMEmailConfirmationViewModelProtocol: ObservableObject {
    var state: DWMScanState { get set }
    var context: DWMOnboardingPresentationContext { get }
    var errorContent: String { get set }
    var shouldDisplayError: Bool { get set }
    var isInFinalState: Bool { get }
    var errorDismissalCompletion: (() -> Void)? { get set }

    func cancel()
    func skip()
    func checkEmailConfirmationStatus(userInitiated: Bool)
    func emailConfirmedFromChecklist()
}

class DWMEmailConfirmationViewModel: DWMEmailConfirmationViewModelProtocol, SessionServicesInjecting {

    enum Completion {
        case cancel
        case skip
        case emailConfirmedFromChecklist
        case unexpectedError
    }

        enum EmailStatusCheckStrategy {
        case instant
        case delayed
    }

    @Published
    var state: DWMScanState = .fetchingEmailConfirmationStatus {
        didSet {
            guard oldValue != state else {
                return
            }

            switch state {
            case .fetchingEmailConfirmationStatus:
                usageLogsService.log(.fetchingEmailConfirmationDisplayed)
            case .emailNotConfirmedYet:
                usageLogsService.log(.emailConfirmationErrorDisplayed)
            case .breachesFound:
                sendLogForResult(breachesFound: true, in: context)
            case .breachesNotFound:
                sendLogForResult(breachesFound: false, in: context)
            }
        }
    }

    var isInFinalState: Bool {
        switch state {
        case .fetchingEmailConfirmationStatus, .emailNotConfirmedYet:
            return false
        case .breachesFound, .breachesNotFound:
            return true
        }
    }

    let context: DWMOnboardingPresentationContext

    @Published
    var shouldDisplayError: Bool = false {
        didSet {
            if oldValue == true && shouldDisplayError == false {
                                errorContent = ""
                errorDismissalCompletion = nil
            }
        }
    }
    var errorContent: String = ""
    var errorDismissalCompletion: (() -> Void)?

    private let email: String
    private let completion: (Completion) -> Void
    private let settings: DWMOnboardingSettings
    private let webservice: LegacyWebService
    private let dwmOnboardingService: DWMOnboardingService
    private let usageLogsService: DWMLogService

    private var emailRegistrationStatusSubscription: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init(accountEmail: String,
         context: DWMOnboardingPresentationContext,
         emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy,
         webservice: LegacyWebService,
         settings: DWMOnboardingSettings,
         dwmOnboardingService: DWMOnboardingService,
         logsService: UsageLogServiceProtocol,
         completion: @escaping (DWMEmailConfirmationViewModel.Completion) -> Void) {
        self.email = accountEmail
        self.context = context
        self.completion = completion
        self.settings = settings
        self.webservice = webservice
        self.dwmOnboardingService = dwmOnboardingService
        self.usageLogsService = logsService.dwmLogService

        switch emailStatusCheck {
        case .instant:
            checkEmailConfirmationStatus(userInitiated: false)
        case .delayed:
            setupEmailRegistrationStatusSubscriber()
        }
    }

    func cancel() {
        cancelAllSubscriptions()
        completion(.cancel)
    }

    func skip() {
                usageLogsService.log(.emailConfirmationErrorSkipped)
        cancelAllSubscriptions()
        completion(.skip)
    }

    func emailConfirmedFromChecklist() {
        cancelAllSubscriptions()
        completion(.emailConfirmedFromChecklist)
    }

    func checkEmailConfirmationStatus(userInitiated: Bool) {
        if userInitiated {
            usageLogsService.log(.emailConfirmationErrorTryAgainTapped)
        }

        self.state = .fetchingEmailConfirmationStatus
        dwmOnboardingService.state(forEmail: email) { [weak self] status in
            switch status {
            case .success(let status):
                self?.handleNewEmailStatus(status)
            case .failure(let error):
                self?.handleCheckStatusError(error)
            }
        }
    }

    private func handleCheckStatusError(_ error: DWMOnboardingService.EmailStateCheckError) {
        switch error {
        case .unexpectedError:
            self.error(L10n.Localizable.darkWebMonitoringEmailRegistrationErrorUnknown) { [weak self] in
                self?.completion(.unexpectedError)
            }
        case .connectionError:
            self.error(L10n.Localizable.darkWebMonitoringEmailRegistrationErrorConnection)
            state = .emailNotConfirmedYet
        }
    }

        private func setupEmailRegistrationStatusSubscriber() {
        emailRegistrationStatusSubscription = dwmOnboardingService.emailStatePublisher(email: email).removeDuplicates().receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] result in
            if case let .failure(error) = result {
                self?.handleCheckStatusError(error)
            }
        }, receiveValue: { [weak self] emailStatus in
            self?.handleNewEmailStatus(emailStatus)
        })
    }

    private func handleNewEmailStatus(_ status: DataLeakEmail.State) {
        switch status {
        case .active:
            emailRegistrationStatusSubscription?.cancel()
            settings.updateProgress(.emailConfirmed)
            fetchBreachedAccounts()
        case .pending:
            state = .emailNotConfirmedYet
            usageLogsService.log(.emailConfirmationErrorDisplayed)
        case .disabled:
            self.error(L10n.Localizable.darkWebMonitoringEmailRegistrationErrorUnknown) { [weak self] in
                self?.completion(.unexpectedError)
            }
        }
    }

    private func fetchBreachedAccounts() {
        dwmOnboardingService.fetchBreachedAccounts().receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] result in
            if case let .failure(error) = result {
                guard let self = self else { return }
                if error.isConnectionError {
                    self.error(L10n.Localizable.darkWebMonitoringEmailRegistrationErrorConnection)
                } else {
                                        self.state = .breachesNotFound
                }
            }
        }, receiveValue: { [weak self] breaches in
            guard let self = self else { return }
            self.usageLogsService.log(.breachesFound(numberOfBreaches: breaches.count))
            self.usageLogsService.log(.breachesFoundWithPassword(numberOfBreaches: breaches.filter({ $0.leakedPassword != nil }).count))

            if breaches.isEmpty == false {
                self.state = .breachesFound
            } else {
                self.state = .breachesNotFound
            }
        }).store(in: &cancellables)
    }

    private func error(_ message: String, dismissalCompletion: (() -> Void)? = nil) {
        errorContent = message
        errorDismissalCompletion = dismissalCompletion ?? { return }
        shouldDisplayError = true
    }

    private func cancelAllSubscriptions() {
        emailRegistrationStatusSubscription?.cancel()
        cancellables.forEach { $0.cancel() }
    }

    private func sendLogForResult(breachesFound: Bool, in context: DWMOnboardingPresentationContext) {
        switch context {
        case .guidedOnboarding:
            if breachesFound {
                usageLogsService.log(.emailConfirmedScreenDisplayed)
            } else {
                usageLogsService.log(.emailConfirmedFromChecklistDisplayed)
            }
        case .onboardingChecklist:
            if breachesFound {
                usageLogsService.log(.everythingLooksGreatDisplayed)
            } else {
                usageLogsService.log(.emailConfirmedFromChecklistDisplayed)
            }
        }
    }
}
