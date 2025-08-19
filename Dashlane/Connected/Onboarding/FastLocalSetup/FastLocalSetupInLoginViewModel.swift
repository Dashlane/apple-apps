import Combine
import CoreSettings
import CoreTypes
import Foundation
import LoginKit
import SwiftTreats

class FastLocalSetupInLoginViewModel: BiometrySettingsHandler, FastLocalSetupViewModel,
  SessionServicesInjecting, AccountCreationFlowDependenciesInjecting
{

  var shouldShowMasterPasswordReset: Bool {
    return masterPassword != nil
  }

  enum Completion {
    case next
  }

  private let masterPassword: String?
  private let lockService: LockService
  private let masterPasswordResetService: ResetMasterPasswordService
  private let userSettings: UserSettings
  private let completion: (Completion) -> Void

  init(
    masterPassword: String?,
    biometry: Biometry?,
    lockService: LockService,
    masterPasswordResetService: ResetMasterPasswordService,
    userSettings: UserSettings,
    completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
  ) {

    self.masterPassword = masterPassword
    self.lockService = lockService
    self.masterPasswordResetService = masterPasswordResetService
    self.userSettings = userSettings
    self.completion = completion

    super.init(biometry: biometry)
  }

  func next() {
    if isBiometricsOn {
      try? lockService.secureLockConfigurator.enableBiometry()
    }

    if let masterPassword = masterPassword, isMasterPasswordResetOn {
      try? masterPasswordResetService.activate(using: masterPassword)
    }

    if isRememberMasterPasswordOn {
      try? lockService.secureLockConfigurator.enableRememberMasterPassword()
    }

    completion(.next)
  }

  func back() {
    assertionFailure("There is no back button in the login context.")
  }

  func markDisplay() {
    userSettings[.fastLocalSetupForRemoteLoginDisplayed] = true
  }
}
