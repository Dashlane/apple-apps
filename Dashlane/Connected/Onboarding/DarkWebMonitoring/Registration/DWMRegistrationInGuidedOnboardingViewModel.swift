import Foundation
import Combine
import DashTypes

enum DWMEmailRegistrationRequestState {
    case notSent
    case sent
}

final class DWMRegistrationInGuidedOnboardingViewModel: DWMRegistrationViewModel, SessionServicesInjecting {

        @Published private var emailRegistrationRequestState: DWMEmailRegistrationRequestState = .notSent

        private var shouldMakeRequest: Bool {
        guard emailRegistrationRequestState == .notSent else {
            return false
        }

        return true
    }

    override init(email: String, dwmOnboardingService: DWMOnboardingService, logsService: UsageLogServiceProtocol, completion: ((DWMRegistrationViewModel.Completion) -> Void)?) {
        super.init(email: email, dwmOnboardingService: dwmOnboardingService, logsService: logsService, completion: completion)

        dwmOnboardingService.progressPublisher().removeDuplicates().receive(on: DispatchQueue.main).sink { [weak self] progress in
            guard let progress = progress else {
                self?.emailRegistrationRequestState = .notSent
                return
            }

                        self?.emailRegistrationRequestState = progress >= .emailRegistrationRequestSent ? .sent : .notSent
            self?.shouldShowRegistrationRequestSent = self?.emailRegistrationRequestState == .sent
            self?.sendDisplayLogs()
        }.store(in: &cancellables)
    }

    override func register() {
        usageLogsService.log(.checkForBreachesTapped)

        guard shouldMakeRequest else {
            shouldShowRegistrationRequestSent = true
            return
        }

        super.register()
    }

    override func sendDisplayLogs() {
        if case .sent = emailRegistrationRequestState {
            super.sendDisplayLogs()
        }
    }

    override func back() {
                if emailRegistrationRequestState == .sent && shouldShowRegistrationRequestSent == true {
            shouldShowRegistrationRequestSent = false
        } else {
            completion?(.back)
        }
    }

    override func updateProgressUponDisplay() {
        usageLogsService.log(.emailRegistrationScreenDisplayed)
        super.updateProgressUponDisplay()
    }
}

class FakeDWMEmailRegistrationInGuidedOnboardingViewModel: DWMRegistrationViewModelProtocol {

    var shouldShowRegistrationRequestSent: Bool

    let email: String = "_"
    var shouldShowMailAppsMenu: Bool = false
    var mailApps: [MailApp] = [.appleMail]
    var shouldShowLoading: Bool = false
    var shouldDisplayError: Bool = false
    var errorContent: String = ""
    var errorDismissalCompletion: (() -> Void)?

    func register() {}
    func openMailAppsMenu() {}
    func openMailApp(_ app: MailApp) {}
    func userIndicatedEmailWasConfirmed() {}
    func updateProgressUponDisplay() {}
    func back() {}
    func skip() {}

    init(registrationRequestSent: Bool = false) {
        self.shouldShowRegistrationRequestSent = registrationRequestSent
    }
}
