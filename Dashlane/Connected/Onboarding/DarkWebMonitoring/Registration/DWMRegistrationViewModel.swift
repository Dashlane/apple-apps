import UIKit
import Combine

class DWMRegistrationViewModel: DWMRegistrationViewModelProtocol {

    enum Completion {
        case back
        case skip
        case registrationRequestSent
        case mailAppOpened
        case userIndicatedEmailConfirmed
        case unexpectedError
    }

    var email: String

    @Published
    var shouldShowRegistrationRequestSent: Bool = false

    @Published
    var shouldShowMailAppsMenu: Bool = false {
        didSet {
            if shouldShowMailAppsMenu {
                mailApps.forEach { usageLogsService.log(.mailAppDisplayed(app: $0)) }
            }
        }
    }

    @Published
    var shouldShowLoading: Bool = false

    let mailApps: [MailApp] = {
        MailApp.allCases.compactMap { UIApplication.shared.canOpenURL(URL(string: $0.urlScheme)!) ? $0 : nil }
    }()

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

    var completion: ((Completion) -> Void)?

    var dwmOnboardingService: DWMOnboardingService
    var usageLogsService: DWMLogService
    var cancellables = Set<AnyCancellable>()

    init(email: String, dwmOnboardingService: DWMOnboardingService, logsService: UsageLogServiceProtocol, completion: ((Completion) -> Void)?) {
        self.email = email
        self.dwmOnboardingService = dwmOnboardingService
        self.usageLogsService = logsService.dwmLogService
        self.completion = completion
    }

    func register() {
        usageLogsService.log(.checkForBreachesTapped)

        self.shouldShowLoading = true
        dwmOnboardingService.register(email: email).receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] result in
            guard let self = self else { return }
            self.shouldShowLoading = false
            if case let .failure(error) = result {
                switch error {
                case .incorrectEmail:
                    self.error(L10n.Localizable.darkWebMonitoringEmailRegistrationErrorInvalidEmail)
                case .connectionError:
                    self.error(L10n.Localizable.darkWebMonitoringEmailRegistrationErrorConnection)
                case .unexpectedError:
                    self.error(L10n.Localizable.darkWebMonitoringEmailRegistrationErrorUnknown) {
                        self.completion?(.unexpectedError)
                    }
                }
            }
            }, receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.usageLogsService.log(.emailRegistrationRequestSent)
                self.shouldShowLoading = false
                self.completion?(.registrationRequestSent)
        }).store(in: &cancellables)
    }

    func openMailAppsMenu() {
        usageLogsService.log(.openMailAppTapped)
        shouldShowMailAppsMenu = true
    }

    func openMailApp(_ app: MailApp) {
        usageLogsService.log(.mailAppTapped(app: app))
        completion?(.mailAppOpened)
        UIApplication.shared.open(URL(string: app.urlScheme)!)
    }

    func userIndicatedEmailWasConfirmed() {
        usageLogsService.log(.confirmedEmailTapped)
        completion?(.userIndicatedEmailConfirmed)
    }

    func updateProgressUponDisplay() {
        dwmOnboardingService.shown()
    }

    func skip() {
        usageLogsService.log(.emailRegistrationScreenSkipped)
        dwmOnboardingService.skip()
        cancellables.removeAll()
        completion?(.skip)
    }

    func back() {
        completion?(.back)
    }

    func dismiss() {
        cancellables.removeAll()
    }

    func error(_ message: String, dismissalCompletion: (() -> Void)? = nil) {
        errorContent = message
        errorDismissalCompletion = dismissalCompletion ?? { return }
        shouldDisplayError = true
    }

    func sendDisplayLogs() {
        if mailApps.isEmpty == false {
            usageLogsService.log(.openMailAppDisplayed)
        }
        usageLogsService.log(.confirmedEmailDisplayed)
    }
}
