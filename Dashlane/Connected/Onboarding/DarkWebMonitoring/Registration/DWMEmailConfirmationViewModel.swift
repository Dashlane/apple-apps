import Combine
import CoreSettings
import DashTypes
import Foundation
import SecurityDashboard
import SwiftUI

@MainActor
class DWMEmailConfirmationViewModel: ObservableObject, SessionServicesInjecting {

  enum ScanState {
    case fetchingEmailConfirmationStatus
    case emailNotConfirmedYet
    case breachesFound
    case breachesNotFound
  }

  enum EmailStatusCheckStrategy {
    case instant
    case delayed
  }

  struct Alert: Identifiable {
    let id: UUID = .init()
    let message: String
    let isUnexpected: Bool
  }

  @Published
  var state: ScanState = .fetchingEmailConfirmationStatus

  var isInFinalState: Bool {
    switch state {
    case .fetchingEmailConfirmationStatus, .emailNotConfirmedYet:
      return false
    case .breachesFound, .breachesNotFound:
      return true
    }
  }

  @Published
  var alert: Alert?

  private let email: String
  private let settings: DWMOnboardingSettings
  private let dwmOnboardingService: DWMOnboardingService

  private var emailRegistrationStatusSubscription: AnyCancellable?
  private var cancellables = Set<AnyCancellable>()

  private init(
    state: ScanState,
    accountEmail: String,
    emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy,
    settings: DWMOnboardingSettings,
    dwmOnboardingService: DWMOnboardingService
  ) {
    self.state = state
    self.email = accountEmail
    self.settings = settings
    self.dwmOnboardingService = dwmOnboardingService

    switch emailStatusCheck {
    case .instant:
      checkEmailConfirmationStatus()
    case .delayed:
      setupEmailRegistrationStatusSubscriber()
    }
  }

  convenience init(
    accountEmail: String,
    emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy,
    settings: DWMOnboardingSettings,
    dwmOnboardingService: DWMOnboardingService
  ) {
    self.init(
      state: .fetchingEmailConfirmationStatus,
      accountEmail: accountEmail,
      emailStatusCheck: emailStatusCheck,
      settings: settings,
      dwmOnboardingService: dwmOnboardingService
    )
  }

  func cancel() {
    cancelAllSubscriptions()
  }

  func skip() {
    cancelAllSubscriptions()
  }

  func checkEmailConfirmationStatus() {
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
  }

  private func setupEmailRegistrationStatusSubscriber() {
    emailRegistrationStatusSubscription = dwmOnboardingService.emailStatePublisher(email: email)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] result in
          if case let .failure(error) = result {
            self?.handleCheckStatusError(error)
          }
        },
        receiveValue: { [weak self] emailStatus in
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
    case .disabled:
      alert = .init(
        message: L10n.Localizable.darkWebMonitoringEmailRegistrationErrorUnknown, isUnexpected: true
      )
    }
  }

  private func fetchBreachedAccounts() {
    dwmOnboardingService.fetchBreachedAccounts()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] result in
          if case let .failure(error) = result {
            guard let self = self else { return }
            if error.isConnectionError {
              self.alert = .init(
                message: L10n.Localizable.darkWebMonitoringEmailRegistrationErrorConnection,
                isUnexpected: false)
            } else {
              self.state = .breachesNotFound
            }
          }
        },
        receiveValue: { [weak self] breaches in
          guard let self = self else { return }

          if breaches.isEmpty == false {
            self.state = .breachesFound
          } else {
            self.state = .breachesNotFound
          }
        }
      )
      .store(in: &cancellables)
  }

  private func cancelAllSubscriptions() {
    emailRegistrationStatusSubscription?.cancel()
    cancellables.forEach { $0.cancel() }
  }
}

extension DWMEmailConfirmationViewModel {
  static func mock(state: DWMEmailConfirmationViewModel.ScanState) -> DWMEmailConfirmationViewModel
  {
    .init(
      accountEmail: "",
      emailStatusCheck: .instant,
      settings: .init(internalStore: .mock()),
      dwmOnboardingService: .mock
    )
  }
}
