import CoreTypes
import Foundation
import SecurityDashboard

@MainActor
class DataLeakMonitoringAddEmailViewModel: ObservableObject, SessionServicesInjecting {

  @Published
  var emailToMonitor = ""

  @Published
  var errorMessage: String?

  @Published
  var isRegisteringEmail = false

  let dataLeakService: IdentityDashboardServiceProtocol

  enum Step {
    case enterEmail
    case success
  }

  @Published
  var steps: [Step] = [.enterEmail]

  init(
    login: Login,
    dataLeakService: IdentityDashboardServiceProtocol
  ) {
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

    try? await dataLeakService.monitorNew(email: emailToMonitor)
    self.steps.append(.success)
  }
}

extension SecurityDashboard.DataLeakMonitoringServiceError {
  fileprivate var localized: String? {
    switch self {
    case .emailAlreadyActive: return L10n.Localizable.dataleakmonitoringEmailAlreadyActive
    case .invalidEmail: return L10n.Localizable.dataleakmonitoringEnteredBadEmail
    case .numberOfAcceptedMonitoredEmailsExceeded:
      return L10n.Localizable.dataleakmonitoringErrorTooManyAddresses
    case .optinAlreadyInProgress: return L10n.Localizable.dataleakmonitoringErrorOptinInProgress
    default: return nil
    }
  }
}

extension DataLeakMonitoringAddEmailViewModel {
  static var mock: DataLeakMonitoringAddEmailViewModel {
    return .init(
      login: Login("_"),
      dataLeakService: IdentityDashboardService.mock)
  }
}
