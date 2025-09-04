import CoreFeature
import CoreSession
import CoreTypes
import CryptoKit
import Foundation
import LoginKit
import SwiftTreats
import SwiftUI

final class SettingsBiometricToggleViewModel: ObservableObject, SessionServicesInjecting {
  typealias Confirmed = Bool

  enum Alert {
    case pinCodeReplacementWarning(completion: (Confirmed) -> Void)
    case masterPasswordResetDeactivationWarning(completion: (Confirmed) -> Void)
    case masterPasswordResetActivationSuggestion(completion: (Confirmed) -> Void)
    case keychainStoredMasterPassword(completion: (Confirmed) -> Void)
  }

  enum Action {
    case enableMasterPasswordReset(_ masterPassword: String)
    case disableRememberMasterPassword
    case disablePinCode
    case disableResetMasterPassword(_ masterPassword: String)
  }

  let authenticationMethod: AuthenticationMethod
  let lockService: LockServiceProtocol
  let featureService: FeatureServiceProtocol
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol

  @Published
  var isToggleOn: Bool

  @Published
  var activeAlert: Alert?

  private let actionHandler: (Action) -> Void

  init(
    session: Session,
    lockService: LockServiceProtocol,
    featureService: FeatureServiceProtocol,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void
  ) {
    self.authenticationMethod = session.authenticationMethod
    self.lockService = lockService
    self.featureService = featureService
    self.resetMasterPasswordService = resetMasterPasswordService
    self.actionHandler = actionHandler
    isToggleOn = lockService.secureLockConfigurator.isBiometricActivated
  }

  func useBiometry(_ shouldEnable: Bool) {
    guard shouldEnable && !isBiometricActivated || !shouldEnable && isBiometricActivated
    else { return }

    if shouldEnable {
      actionHandler(.disableRememberMasterPassword)
    }

    switch (shouldEnable, SecureEnclave.isAvailable) {
    case (true, true):
      activateBiometry()
    case (true, false):
      warnAboutPinCodeReplacement { [weak self] _ in
        self?.actionHandler(.disablePinCode)
        self?.activateBiometry()
      }
    case (false, _):
      warnAboutResetMasterPasswordDeactivation { [weak self] confirmed in
        if confirmed {
          if let password = self?.authenticationMethod.userMasterPassword {
            self?.actionHandler(.disableResetMasterPassword(password))
          }
          do {
            try self?.disableBiometry()
          } catch {
            assertionFailure("Couldn't disable biometry [\(error.localizedDescription)]")
            self?.setToggleOnWithAnimation(true)
          }
        } else {
          self?.setToggleOnWithAnimation(true)
        }
      }
    }
  }

  private func activateBiometry() {
    if authenticationMethod.userMasterPassword == nil
      || lockService.secureLockConfigurator.isPincodeActivated
    {
      do {
        try enableBiometry()
        if isResetMasterPasswordContainerAvailable
          && featureService.isEnabled(.masterPasswordResetIsAvailable)
        {
          suggestActivatingResetMasterPassword()
        }

      } catch {
        setToggleOnWithAnimation(false)
      }
      return
    }

    activeAlert = .keychainStoredMasterPassword(completion: { [weak self] confirmed in
      guard let self = self else { return }
      if confirmed {
        do {
          try self.enableBiometry()
        } catch {
          self.setToggleOnWithAnimation(false)
          return
        }
        if self.featureService.isEnabled(.masterPasswordResetIsAvailable),
          !self.resetMasterPasswordService.isActive
        {
          DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.suggestActivatingResetMasterPassword()
          }
        }
      } else {
        self.setToggleOnWithAnimation(false)
      }
    })
  }

  private func suggestActivatingResetMasterPassword() {
    activeAlert = .masterPasswordResetActivationSuggestion(completion: { [weak self] confirmation in
      guard let self = self, confirmation,
        let password = self.authenticationMethod.userMasterPassword
      else { return }
      self.actionHandler(.enableMasterPasswordReset(password))
    })
  }

  private func warnAboutPinCodeReplacement(completion: @escaping (Confirmed) -> Void) {
    if lockService.secureLockConfigurator.isPincodeActivated {
      activeAlert = .pinCodeReplacementWarning(completion: completion)
    } else {
      completion(true)
    }
  }

  private func warnAboutResetMasterPasswordDeactivation(completion: @escaping (Confirmed) -> Void) {
    guard
      isResetMasterPasswordActivated && featureService.isEnabled(.masterPasswordResetIsAvailable)
    else {
      completion(true)
      return
    }
    activeAlert = .masterPasswordResetDeactivationWarning(completion: completion)
  }

  func enableBiometry() throws {
    try lockService.secureLockConfigurator.enableBiometry()
    setToggleOnWithAnimation(true)
  }

  func disableBiometry() throws {
    try lockService.secureLockConfigurator.disableBiometry()
    setToggleOnWithAnimation(false)
  }

  private func setToggleOnWithAnimation(_ on: Bool) {
    withAnimation {
      isToggleOn = on
    }
  }
  private var isResetMasterPasswordContainerAvailable: Bool {
    Device.biometryType != nil && authenticationMethod.userMasterPassword != nil
  }

  private var isResetMasterPasswordActivated: Bool {
    resetMasterPasswordService.isActive
  }

  private var isBiometricActivated: Bool {
    lockService.secureLockConfigurator.isBiometricActivated
  }
}

extension SettingsBiometricToggleViewModel {

  static var mock: SettingsBiometricToggleViewModel {
    SettingsBiometricToggleViewModel(
      session: .mock,
      lockService: LockServiceMock(),
      featureService: .mock(),
      resetMasterPasswordService: ResetMasterPasswordServiceMock(),
      actionHandler: { _ in })
  }
}
