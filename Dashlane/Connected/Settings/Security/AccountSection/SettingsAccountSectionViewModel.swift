import Combine
import CoreFeature
import CoreNetworking
import CorePasswords
import CorePersonalData
import CorePremium
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LoginKit
import UIKit
import UserTrackingFoundation

@MainActor
final class SettingsAccountSectionViewModel: ObservableObject, SessionServicesInjecting {

  enum Alert {
    case privacyError
    case wrongMasterPassword
    case logOut
  }

  let session: Session
  private let featureService: FeatureServiceProtocol
  private let userSpacesService: UserSpacesService
  let deviceListViewModel: () -> DeviceListViewModel
  private let activityReporter: ActivityReporterProtocol
  private let sessionLifeCycleHandler: SessionLifeCycleHandler?
  private let userDeviceAPIClient: UserDeviceAPIClient

  @Published
  var activeAlert: Alert?

  private let actionHandler: (MasterPasswordResetActivationViewModel.Action) -> Void

  let deepLinkPublisher: AnyPublisher<SettingsDeepLinkComponent, Never>

  private let masterPasswordResetActivationViewModelFactory:
    MasterPasswordResetActivationViewModel.Factory
  private let changeMasterPasswordFlowViewModelFactory: MP2MPAccountMigrationViewModel.Factory
  private let accountRecoveryKeyStatusViewModelFactory: AccountRecoveryKeyStatusViewModel.Factory
  var masterPasswordResetActivationViewModel: MasterPasswordResetActivationViewModel?

  init(
    session: Session,
    featureService: FeatureServiceProtocol,
    userSpacesService: UserSpacesService,
    deviceListViewModel: @escaping () -> DeviceListViewModel,
    activityReporter: ActivityReporterProtocol,
    sessionLifeCycleHandler: SessionLifeCycleHandler?,
    deepLinkingService: DeepLinkingServiceProtocol,
    userDeviceAPIClient: UserDeviceAPIClient,
    masterPasswordResetActivationViewModelFactory: MasterPasswordResetActivationViewModel.Factory,
    changeMasterPasswordFlowViewModelFactory: MP2MPAccountMigrationViewModel.Factory,
    accountRecoveryKeyStatusViewModelFactory: AccountRecoveryKeyStatusViewModel.Factory,
    actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
  ) {
    self.session = session
    self.featureService = featureService
    self.userSpacesService = userSpacesService
    self.deviceListViewModel = deviceListViewModel
    self.activityReporter = activityReporter
    self.userDeviceAPIClient = userDeviceAPIClient
    self.sessionLifeCycleHandler = sessionLifeCycleHandler
    self.actionHandler = actionHandler
    deepLinkPublisher = deepLinkingService.settingsComponentPublisher()
    self.masterPasswordResetActivationViewModelFactory =
      masterPasswordResetActivationViewModelFactory
    self.changeMasterPasswordFlowViewModelFactory = changeMasterPasswordFlowViewModelFactory
    self.accountRecoveryKeyStatusViewModelFactory = accountRecoveryKeyStatusViewModelFactory
  }

  var isChangeMasterPasswordAvailable: String? {
    guard featureService.isEnabled(.changeMasterPasswordIsAvailable) else {
      return nil
    }
    return session.authenticationMethod.userMasterPassword
  }

  var canShowAccountRecovery: Bool {
    if session.configuration.info.accountType == .invisibleMasterPassword {
      return true
    }
    guard featureService.isEnabled(.accountRecoveryKey) else {
      return false
    }
    return session.configuration.info.accountType == .masterPassword
  }

  var masterPassword: String? {
    return session.authenticationMethod.userMasterPassword
  }

  func goToPrivacySettings() {
    Task {
      do {
        let url = try await userDeviceAPIClient.premium.fetchPrivacySettingsURL()
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } catch {
        self.activeAlert = .privacyError
      }
    }
  }

  func logOut() {
    activityReporter.report(UserEvent.Logout())
    if case .invisibleMasterPassword = session.authenticationMethod {
      sessionLifeCycleHandler?.logoutAndPerform(action: .deleteCurrentSessionLocalData)
    } else {
      sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
    }
  }

  func enableResetMasterPassword() {
    guard masterPassword != nil else { return }
  }

  func makeAccountRecoveryKeyStatusViewModel() -> AccountRecoveryKeyStatusViewModel {
    return accountRecoveryKeyStatusViewModelFactory.make()
  }

  func makeMasterPasswordChallengeAlertViewModel(
    masterPassword: String,
    completion: @escaping (MasterPasswordChallengeAlertViewModel.Completion) -> Void
  ) -> MasterPasswordChallengeAlertViewModel {
    return MasterPasswordChallengeAlertViewModel(
      masterPassword: masterPassword, intent: .changeMasterPassword, completion: completion)
  }

  func makeMasterPasswordResetActivationViewModel(masterPassword: String)
    -> MasterPasswordResetActivationViewModel
  {
    let model = masterPasswordResetActivationViewModelFactory.make(
      masterPassword: masterPassword, actionHandler: actionHandler)
    self.masterPasswordResetActivationViewModel = model
    return model
  }

  func makeChangeMasterPasswordViewModel(_ completion: @escaping () -> Void)
    -> MP2MPAccountMigrationViewModel
  {
    changeMasterPasswordFlowViewModelFactory.make(migrationContext: .changeMP) {
      [weak self] result in
      guard let self else { return }

      if case .success(let session) = result {
        self.sessionLifeCycleHandler?.logoutAndPerform(
          action: .startNewSession(session, reason: .masterPasswordChanged))
      }

      completion()
    }
  }
}

extension SettingsAccountSectionViewModel {

  static var mock: SettingsAccountSectionViewModel {
    SettingsAccountSectionViewModel(
      session: .mock,
      featureService: .mock(),
      userSpacesService: .mock(),
      deviceListViewModel: { DeviceListViewModel.mock },
      activityReporter: .mock,
      sessionLifeCycleHandler: nil,
      deepLinkingService: DeepLinkingService.fakeService,
      userDeviceAPIClient: .fake,
      masterPasswordResetActivationViewModelFactory: .init({ _, _ in .mock }),
      changeMasterPasswordFlowViewModelFactory: .init({ _, _ in fatalError("unreachable in Preview")
        }),
      accountRecoveryKeyStatusViewModelFactory: .init({ .mock }),
      actionHandler: { _ in })
  }
}
