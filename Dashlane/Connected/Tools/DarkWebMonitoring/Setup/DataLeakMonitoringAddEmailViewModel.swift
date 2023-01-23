import Foundation
import DashlaneReportKit
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
    let usageLogService: UsageLogServiceProtocol

    let logger: DataLeakMonitoringAddEmailLogger

    enum Step {
        case enterEmail
        case success
    }

    @Published
    var steps: [Step] = [.enterEmail]

    init(login: Login,
         dataLeakService: DataLeakMonitoringRegisterServiceProtocol,
         usageLogService: UsageLogServiceProtocol) {
        self.dataLeakService = dataLeakService
        self.usageLogService = usageLogService
        self.logger = DataLeakMonitoringAddEmailLogger(usageLogService: usageLogService)
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
            self.logger.localError(.invalidEmailLocal)
            return
        }

        let response = try? await dataLeakService.webService.register(emails: [emailToMonitor])
        if let error = response?.results.first?.result, let localizedError = error.localized {
            self.errorMessage = localizedError
            self.logger.serverError(error)
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

struct DataLeakMonitoringAddEmailLogger {

    enum LogError: String {
        case invalidEmailLocal = "invalid_email_local"
    }

    private let typeSubKey = "enter_email"

    let usageLogService: UsageLogServiceProtocol

    func localError(_ error: LogError) {
        let log129 = UsageLogCode129DarkwebMonitoring(type: .darkWebRegistration,
                                                      type_sub: typeSubKey,
                                                      action: .error,
                                                      action_sub: error.rawValue)
        usageLogService.post(log129)
    }

    func serverError(_ error: DataLeakMonitoringServiceError) {

        guard let subActionError = error.logAction else {
            return
        }

        let log129 = UsageLogCode129DarkwebMonitoring(type: .darkWebRegistration,
                                                      type_sub: typeSubKey,
                                                      action: .error,
                                                      action_sub: subActionError)
        usageLogService.post(log129)
    }

    func show() {
        let log129 = UsageLogCode129DarkwebMonitoring(type: .darkWebRegistration,
                                                      type_sub: typeSubKey,
                                                      action: .show)
        usageLogService.post(log129)
    }

    func cancel() {
        let log129 = UsageLogCode129DarkwebMonitoring(type: .darkWebRegistration,
                                                      type_sub: typeSubKey,
                                                      action: .cancel)
        usageLogService.post(log129)
    }
}

private extension DataLeakMonitoringServiceError {
    var logAction: String? {
        switch self {
            case .invalidEmail:
                return "invalid_email_server"
            case .optinAlreadyInProgress:
                return "validation_pending"
            case .emailAlreadyActive:
                return "already_validated"
            case .numberOfAcceptedMonitoredEmailsExceeded:
                return "max_mail_limit"
            default:
                return nil
        }
    }
}

extension DataLeakMonitoringAddEmailViewModel {
    static var mock: DataLeakMonitoringAddEmailViewModel {
        return .init(login: Login("_"),
                     dataLeakService: DataLeakMonitoringRegisterService.mock,
                     usageLogService: UsageLogService.fakeService)
    }
}
