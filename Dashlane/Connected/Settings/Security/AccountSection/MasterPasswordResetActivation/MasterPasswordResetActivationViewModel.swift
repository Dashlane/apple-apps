import Combine
import CoreSession
import CoreTypes
import LogFoundation
import LoginKit
import SwiftTreats
import SwiftUI

@MainActor
final class MasterPasswordResetActivationViewModel: ObservableObject, SessionServicesInjecting {

  @Loggable
  enum Error: Swift.Error {
    case biometricActivation(Swift.Error)
    case resetContainerCreationFailure(Swift.Error)
    case resetContainerRemovalFailure
    case canceled
    case unexpectedError
  }

  enum Alert {
    case wrongMasterPassword(completion: () -> Void)
    case biometricActivation(completion: (Bool) -> Void)
    case deactivation(completion: (Bool) -> Void)
  }

  enum Action {
    case activateBiometry
  }

  let masterPassword: String
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  let lockService: LockServiceProtocol

  @Published
  var isToggleOn: Bool

  @Published
  var displayMasterPasswordChallenge = false

  @Published
  var activeAlert: Alert?

  private let actionHandler: (Action) -> Void

  init(
    masterPassword: String,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    lockService: LockServiceProtocol,
    actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
  ) {
    self.masterPassword = masterPassword
    self.resetMasterPasswordService = resetMasterPasswordService
    self.lockService = lockService
    self.isToggleOn = resetMasterPasswordService.isActive
    self.actionHandler = actionHandler
  }

  func startMasterPasswordChallenge() {
    displayMasterPasswordChallenge = true
  }

  func activateMasterPasswordReset(withBiometric enableBiometric: Bool) {
    do {
      try activateResetMasterPassword()
      if enableBiometric {
        actionHandler(.activateBiometry)
      }
      if !isToggleOn {
        toggleValueWithAnimation(true)
      }
    } catch {
      assertionFailure("Couldn't activate resetMasterPassword [\(error.localizedDescription)]")
    }
  }

  func deactivateMasterPasswordReset() {
    do {
      try resetMasterPasswordService.deactivate()
      toggleValueWithAnimation(false)
    } catch {
      assertionFailure("Couldn't deactivate master password reset [\(error.localizedDescription)]")
      if resetMasterPasswordService.isActive {
        toggleValueWithAnimation(true)
      }
    }
  }

  private func activateResetMasterPassword() throws {
    do {
      try self.resetMasterPasswordService.activate(using: masterPassword)
    } catch {
      throw Error.resetContainerCreationFailure(error)
    }
  }

  func handleMasterPasswordChallengeStatus(
    _ status: MasterPasswordChallengeAlertViewModel.Completion
  ) {
    displayMasterPasswordChallenge = false

    switch status {
    case .validated:
      if lockService.secureLockConfigurator.isBiometricActivated || Device.biometryType == nil {
        activateMasterPasswordReset(withBiometric: false)
      } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
          self?.activeAlert = .biometricActivation(completion: { enableBiometric in
            self?.activeAlert = nil
            if enableBiometric {
              self?.activateMasterPasswordReset(withBiometric: true)
            } else {
              self?.toggleValueWithAnimation(false)
            }
          })
        }
      }
    case .failed:
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
        self?.toggleValueWithAnimation(false)
        self?.activeAlert = .wrongMasterPassword(completion: {
          self?.activeAlert = nil
        })
      }
    case .cancelled:
      toggleValueWithAnimation(false)
    }
  }

  func handleToggleValueChange(newValue enabled: Bool) {
    guard
      enabled && !resetMasterPasswordService.isActive
        || !enabled && resetMasterPasswordService.isActive
    else { return }

    if enabled {
      startMasterPasswordChallenge()
    } else {
      activeAlert = .deactivation(completion: { [weak self] deactivate in
        if deactivate {
          self?.deactivateMasterPasswordReset()
        } else {
          self?.activeAlert = nil
          self?.toggleValueWithAnimation(true)
        }
      })
    }
  }

  func makeMasterPasswordChallengeAlertViewModel() -> MasterPasswordChallengeAlertViewModel {
    MasterPasswordChallengeAlertViewModel(
      masterPassword: masterPassword, intent: .enableMasterPasswordReset
    ) { [weak self] status in
      self?.handleMasterPasswordChallengeStatus(status)
    }
  }

  private func toggleValueWithAnimation(_ on: Bool) {
    withAnimation { isToggleOn = on }
  }
}

extension MasterPasswordResetActivationViewModel {

  static var mock: MasterPasswordResetActivationViewModel {
    MasterPasswordResetActivationViewModel(
      masterPassword: "_",
      resetMasterPasswordService: ResetMasterPasswordServiceMock(),
      lockService: LockServiceMock(),
      actionHandler: { _ in })
  }
}
