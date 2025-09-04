import Combine
import CorePersonalData
import CoreSettings
import DomainParser
import Foundation
import UIKit

class DarkWebMonitoringDetailsViewModel: ObservableObject, SessionServicesInjecting {
  var breachViewModel: BreachViewModel
  var actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?

  @Published
  var advice: DarkWebMonitoringAdvice?

  var canChangePassword: Bool {
    !correspondingCredentials.isEmpty
  }

  private var currentCredential: Credential?

  private let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
  private let correspondingCredentials: [Credential]
  private let domainParser: DomainParserProtocol
  private let userSettings: UserSettings
  private let initialPassword: String
  private var newPassword: String

  init(
    breach: DWMSimplifiedBreach,
    breachViewModel: BreachViewModel,
    darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
    domainParser: DomainParserProtocol,
    userSettings: UserSettings,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>? = nil
  ) {
    self.breachViewModel = breachViewModel
    self.darkWebMonitoringService = darkWebMonitoringService
    self.domainParser = domainParser
    self.userSettings = userSettings
    self.actionPublisher = actionPublisher
    self.correspondingCredentials = darkWebMonitoringService.correspondingCredentials(for: breach)

    self.currentCredential = correspondingCredentials.first
    self.initialPassword = correspondingCredentials.first?.password ?? ""
    self.newPassword = ""

    advice = canChangePassword ? .changePassword(changePassword) : nil
  }

  func changePassword() {
    if let breach = breachViewModel.simplifiedBreach, let url = breach.url.openableURL {
      self.darkWebMonitoringService.solved(breach)
      UIApplication.shared.open(url)
    } else if let credential = correspondingCredentials.first {
      self.actionPublisher?.send(.changePassword(credential, { _ in }))
    }
  }

  func newPasswordToBeSaved() {
    guard let credential = currentCredential else { return }
    guard let breach = breachViewModel.simplifiedBreach else { return }

    darkWebMonitoringService.saveNewPassword(for: credential, newPassword: newPassword) {
      [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let updatedCredential):
        self.currentCredential = updatedCredential
        self.darkWebMonitoringService.solved(breach)
        self.advice = .savedNewPassword(self.viewItem, self.undoSavePassword)
      case .failure: self.advice = .changePassword(self.changePassword)
      }
    }
  }

  func undoSavePassword() {
    guard let credential = currentCredential else { return }

    darkWebMonitoringService.saveNewPassword(for: credential, newPassword: initialPassword) {
      [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let updatedCredential):
        self.currentCredential = updatedCredential
        self.advice = nil
      case .failure: self.advice = .savedNewPassword(self.viewItem, self.undoSavePassword)
      }
    }
  }

  func viewItem() {
    guard let credential = currentCredential else { return }

    self.actionPublisher?.send(.showCredential(credential))
  }
}

extension DarkWebMonitoringDetailsViewModel {
  static func fake() -> DarkWebMonitoringDetailsViewModel {
    DarkWebMonitoringDetailsViewModel(
      breach: DWMSimplifiedBreach(
        breachId: "00", url: .init(rawValue: "world.com"), leakedPassword: nil, date: nil),
      breachViewModel: .mock(for: .init()),
      darkWebMonitoringService: DarkWebMonitoringServiceMock(),
      domainParser: FakeDomainParser(),
      userSettings: .mock,
      actionPublisher: nil)
  }
}
