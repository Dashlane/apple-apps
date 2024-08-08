import Combine
import CoreSettings
import DashTypes
import Foundation
import UIKit

@MainActor
final class DWMRegistrationInGuidedOnboardingViewModel: ObservableObject, SessionServicesInjecting {

  struct Alert: Identifiable {
    let id: UUID = .init()
    let message: String
    let isUnexpected: Bool
  }

  private enum RequestState {
    case notSent
    case sent
  }

  @Published
  private var emailRegistrationRequestState: RequestState = .notSent

  @Published
  var shouldShowRegistrationRequestSent: Bool = false

  @Published
  var shouldShowMailAppsMenu: Bool = false

  @Published
  var shouldShowLoading: Bool = false

  @Published
  var alert: Alert?

  private var shouldMakeRequest: Bool {
    return emailRegistrationRequestState == .notSent
  }

  let email: String
  let mailApps: [MailApp] = {
    MailApp.allCases.compactMap {
      UIApplication.shared.canOpenURL(URL(string: $0.urlScheme)!) ? $0 : nil
    }
  }()

  var previousStepsHaveBeenSkipped: Bool {
    dwmOnboardingService.hasGoneStraightToDWMOnboarding
  }

  private let dwmOnboardingService: DWMOnboardingService
  private let userSettings: UserSettings
  private var cancellables = Set<AnyCancellable>()

  init(
    email: String,
    dwmOnboardingService: DWMOnboardingService,
    userSettings: UserSettings
  ) {
    self.email = email
    self.dwmOnboardingService = dwmOnboardingService
    self.userSettings = userSettings

    dwmOnboardingService.progressPublisher()
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] progress in
        guard let progress = progress else {
          self?.emailRegistrationRequestState = .notSent
          return
        }

        self?.emailRegistrationRequestState =
          progress >= .emailRegistrationRequestSent ? .sent : .notSent
        self?.shouldShowRegistrationRequestSent = self?.emailRegistrationRequestState == .sent
      }
      .store(in: &cancellables)
  }

  func register() {
    guard shouldMakeRequest else {
      shouldShowRegistrationRequestSent = true
      return
    }

    shouldShowLoading = true
    dwmOnboardingService.register(email: email)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] result in
          guard let self = self else { return }
          self.shouldShowLoading = false
          if case let .failure(error) = result {
            switch error {
            case .incorrectEmail:
              self.alert = .init(
                message: L10n.Localizable.darkWebMonitoringEmailRegistrationErrorInvalidEmail,
                isUnexpected: false)
            case .connectionError:
              self.alert = .init(
                message: L10n.Localizable.darkWebMonitoringEmailRegistrationErrorConnection,
                isUnexpected: false)
            case .unexpectedError:
              self.alert = .init(
                message: L10n.Localizable.darkWebMonitoringEmailRegistrationErrorUnknown,
                isUnexpected: true)
            }
          }
        },
        receiveValue: { [weak self] _ in
          guard let self = self else { return }
          self.shouldShowLoading = false
        }
      )
      .store(in: &cancellables)
  }

  func openMailAppsMenu() {
    shouldShowMailAppsMenu = true
  }

  func openMailApp(_ app: MailApp) {
    UIApplication.shared.open(URL(string: app.urlScheme)!)
  }

  func updateProgressUponDisplay() {
    dwmOnboardingService.shown()
  }

  func skip() {
    dwmOnboardingService.skip()
    cancellables.removeAll()
  }

  func canGoBack() -> Bool {
    guard !(emailRegistrationRequestState == .sent && shouldShowRegistrationRequestSent) else {
      shouldShowRegistrationRequestSent = false
      return false
    }

    return true
  }

  func dismiss() {
    cancellables.removeAll()
  }
}

extension DWMRegistrationInGuidedOnboardingViewModel {
  static func mock(shouldShowRegistrationRequestSent: Bool = false)
    -> DWMRegistrationInGuidedOnboardingViewModel
  {
    let viewModel = DWMRegistrationInGuidedOnboardingViewModel(
      email: "_", dwmOnboardingService: .mock, userSettings: .mock)
    viewModel.shouldShowRegistrationRequestSent = shouldShowRegistrationRequestSent
    return viewModel
  }
}
