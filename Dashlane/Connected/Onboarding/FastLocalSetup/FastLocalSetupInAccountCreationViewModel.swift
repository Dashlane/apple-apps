import Combine
import CoreSession
import Foundation
import LoginKit
import SwiftTreats

class FastLocalSetupInAccountCreationViewModel: BiometrySettingsHandler, FastLocalSetupViewModel,
  AccountCreationFlowDependenciesInjecting
{
  let shouldShowMasterPasswordReset: Bool = true

  enum Completion {
    case back(LocalConfiguration)
    case next(LocalConfiguration)
  }

  private let completion: (Completion) -> Void

  init(
    biometry: Biometry? = Device.biometryType,
    completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void
  ) {
    self.completion = completion
    super.init(biometry: biometry)
  }

  func next() {
    completion(
      .next(
        LocalConfiguration(
          isBiometricAuthenticationEnabled: isBiometricsOn,
          isMasterPasswordResetEnabled: isMasterPasswordResetOn,
          isRememberMasterPasswordEnabled: isRememberMasterPasswordOn)))
  }

  func back() {
    completion(
      .back(
        LocalConfiguration(
          isBiometricAuthenticationEnabled: isBiometricsOn,
          isMasterPasswordResetEnabled: isMasterPasswordResetOn,
          isRememberMasterPasswordEnabled: isRememberMasterPasswordOn)))
  }

  func markDisplay() {}
}
