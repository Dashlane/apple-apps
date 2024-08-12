import Combine
import CorePersonalData
import DashTypes
import Foundation
import SecurityDashboard
import VaultKit

protocol DarkWebMonitoringMonitoredEmailsViewModelProtocol: ObservableObject {
  var registeredEmails: [DataLeakEmail] { get }
  func status() -> DarkWebMonitoringMonitoredEmailsViewModel.Status
  var isMonitoringEnabled: Bool { get }
  func numberOfEmailsMonitored() -> Int
  var availableSpots: Int { get }
  var canAddEmail: Bool { get }
  var maxMonitoredEmails: Int { get }
  var shouldShowEmailSection: Bool { get set }

  func addEmail()
  func makeRowViewModel(email: DataLeakEmail) -> DarkWebMonitoringEmailRowViewModel
}

class DarkWebMonitoringMonitoredEmailsViewModel: DarkWebMonitoringMonitoredEmailsViewModelProtocol,
  SessionServicesInjecting
{

  enum Status {
    case active
    case pending
    case inactive
  }

  @Published
  var registeredEmails: [DataLeakEmail] = []

  @Published
  var shouldShowEmailSection: Bool = false

  var isMonitoringEnabled: Bool {
    return darkWebMonitoringService.isDwmEnabled
  }

  func status() -> Status {
    let states = registeredEmails.map({ DataLeakEmail.State(rawValue: $0.state) })
    if states.first(where: { $0 == .disabled }) != nil {
      return .inactive
    } else if !registeredEmails.isEmpty, states.allSatisfy({ $0 == .active }) {
      return .active
    } else {
      return .pending
    }
  }

  func numberOfEmailsMonitored() -> Int {
    return registeredEmails.filter({ DataLeakEmail.State(rawValue: $0.state) == .active }).count
  }

  var canAddEmail: Bool {
    return registeredEmails.count < maxMonitoredEmails
  }

  var maxMonitoredEmails: Int {
    return darkWebMonitoringService.maxMonitoredEmails
  }

  var availableSpots: Int {
    return maxMonitoredEmails - registeredEmails.count
  }

  private let actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  private let iconService: IconServiceProtocol

  private var darkWebMonitoringService: DarkWebMonitoringServiceProtocol
  private var subscriptions = Set<AnyCancellable>()

  init(
    darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
    iconService: IconServiceProtocol,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  ) {
    self.darkWebMonitoringService = darkWebMonitoringService
    self.iconService = iconService
    self.actionPublisher = actionPublisher

    subscribeToMonitoredEmails()
  }

  private func subscribeToMonitoredEmails() {
    darkWebMonitoringService.monitoredEmailsPublisher.assign(to: \.registeredEmails, on: self)
      .store(in: &subscriptions)
    darkWebMonitoringService.monitoredEmailsPublisher.sink { [weak self] emails in
      guard let self = self else {
        return
      }
      let states = emails.map({ DataLeakEmail.State(rawValue: $0.state) })
      self.shouldShowEmailSection =
        states.allSatisfy { $0 == .pending } || states.allSatisfy { $0 == .disabled }
        || self.shouldShowEmailSection
    }.store(in: &subscriptions)
  }

  func makeRowViewModel(email: DataLeakEmail) -> DarkWebMonitoringEmailRowViewModel {
    return DarkWebMonitoringEmailRowViewModel(
      email: email, iconService: iconService, actionPublisher: actionPublisher)
  }

  func addEmail() {
    actionPublisher.send(.addEmail)
  }
}

extension DarkWebMonitoringMonitoredEmailsViewModel {
  static var mock: DarkWebMonitoringMonitoredEmailsViewModel {
    .init(
      darkWebMonitoringService: DarkWebMonitoringServiceMock(),
      iconService: IconServiceMock(), actionPublisher: .init())
  }
}

class FakeDarkWebMonitoringMonitoredEmailsViewModel:
  DarkWebMonitoringMonitoredEmailsViewModelProtocol
{
  var registeredEmails: [DataLeakEmail] = [DataLeakEmail(pendingEmail: "_")]

  var isMonitoringEnabled: Bool = true
  var availableSpots: Int = 4
  var canAddEmail: Bool = true
  var maxMonitoredEmails: Int = 5
  var shouldShowEmailSection: Bool = false

  init(shouldShowEmailSection: Bool) {
    self.shouldShowEmailSection = shouldShowEmailSection
  }

  func status() -> DarkWebMonitoringMonitoredEmailsViewModel.Status {
    .active
  }

  func numberOfEmailsMonitored() -> Int {
    1
  }

  func addEmail() {}
  func makeRowViewModel(email: DataLeakEmail) -> DarkWebMonitoringEmailRowViewModel {
    return DarkWebMonitoringEmailRowViewModel(
      email: email, iconService: IconServiceMock(), actionPublisher: .init())
  }
}
