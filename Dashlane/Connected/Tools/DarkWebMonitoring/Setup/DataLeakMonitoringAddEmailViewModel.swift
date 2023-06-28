import Foundation
import DashTypes
import SecurityDashboard

@MainActor
class DataLeakMonitoringAddEmailViewModel: ObservableObject, SessionServicesInjecting {

    @Published
    var emailToMonitor = ""

    @Published
    var errorMessage: String?

    @Published
    var isRegisteringEmail = false

    let dataLeakService: DataLeakMonitoringRegisterServiceProtocol

    enum Step {
        case enterEmail
        case success
    }

    @Published
    var steps: [Step] = [.enterEmail]

    init(login: Login,
         dataLeakService: DataLeakMonitoringRegisterServiceProtocol) {
        self.dataLeakService = dataLeakService
        let monitoredEmails = dataLeakService.monitoredEmails.map({ $0.email })
        if !monitoredEmails.contains(login.email) {
            emailToMonitor = login.email
        }
    }

    func monitorEmail() async {
        isRegisteringEmail = true
        defer {
            isRegisteringEmail = false
        }

        guard Email(emailToMonitor).isValid else {
            self.errorMessage = L10n.Localizable.dataleakmonitoringEnteredBadEmail
            return
        }

        let response = try? await dataLeakService.webService.register(emails: [emailToMonitor])
        if let error = response?.results.first?.result, let localizedError = error.localized {
            self.errorMessage = localizedError
        } else {
                                                            self.steps.append(.success)
        }
    }
}

private extension SecurityDashboard.DataLeakMonitoringServiceError {
    var localized: String? {
        switch self {
        case .emailAlreadyActive: return L10n.Localizable.dataleakmonitoringEmailAlreadyActive
        case .invalidEmail: return L10n.Localizable.dataleakmonitoringEnteredBadEmail
        case .numberOfAcceptedMonitoredEmailsExceeded: return L10n.Localizable.dataleakmonitoringErrorTooManyAddresses
        case .optinAlreadyInProgress: return L10n.Localizable.dataleakmonitoringErrorOptinInProgress
        default: return nil
        }
    }
}

extension DataLeakMonitoringAddEmailViewModel {
    static var mock: DataLeakMonitoringAddEmailViewModel {
        return .init(login: Login("_"),
                     dataLeakService: DataLeakMonitoringRegisterService.mock)
    }
}
