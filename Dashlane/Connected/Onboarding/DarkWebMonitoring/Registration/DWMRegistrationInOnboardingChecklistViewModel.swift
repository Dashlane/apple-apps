import Foundation
import Combine
import DashTypes

final class DWMRegistrationInOnboardingChecklistViewModel: DWMRegistrationViewModel, SessionServicesInjecting {

    override init(email: String, dwmOnboardingService: DWMOnboardingService, logsService: UsageLogServiceProtocol, completion: ((DWMRegistrationInOnboardingChecklistViewModel.Completion) -> Void)?) {
        super.init(email: email, dwmOnboardingService: dwmOnboardingService, logsService: logsService, completion: completion)

        dwmOnboardingService.progressPublisher().receive(on: DispatchQueue.main).sink { [weak self] progress in
            guard let progress = progress else {
                self?.shouldShowRegistrationRequestSent = false
                return
            }

            self?.shouldShowRegistrationRequestSent = progress >= .emailRegistrationRequestSent
        }.store(in: &cancellables)
    }

    override func register() {
        usageLogsService.log(.checkForBreachesTapped)
        super.register()
    }

    override func updateProgressUponDisplay() {
        usageLogsService.log(.emailRegistrationFromChecklistDisplayed)
        super.updateProgressUponDisplay()
    }
}

class FakeDWMRegistrationInOnboardingChecklistViewModel: DWMRegistrationViewModelProtocol {

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
