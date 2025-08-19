import Combine
import CoreKeychain
import CoreLocalization
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import LocalAuthentication
import StateMachine
import SwiftTreats
import UIKit
import UserTrackingFoundation

@MainActor
public class PinCodeAndBiometryViewModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  public enum Completion: Equatable {
    case authenticated(LocalLoginConfiguration)
    case failure
    case recover
    case cancel
  }

  enum ViewState {
    case biometry(Biometry)
    case pin
  }

  @Published
  var viewState: ViewState?

  public let login: Login

  @Published
  public var pincode: String = "" {
    didSet {
      if pincode.count == savedPincode.count {
        Task {
          await perform(.validatePIN(pincode))
        }
      }
    }
  }

  @Published
  public var attempts: Int = 0

  @Published public var isPerformingEvent: Bool = false

  public var pincodeLength: Int {
    savedPincode.count
  }

  let savedPincode: String
  let accountType: AccountType
  let completion: (Completion) -> Void
  @Published public var stateMachine: LockPinCodeAndBiometryStateMachine

  private var cancellables: Set<AnyCancellable> = []

  public init(
    login: Login,
    accountType: CoreSession.AccountType,
    pincode: String,
    lockPinCodeAndBiometryStateMachine: LockPinCodeAndBiometryStateMachine,
    completion: @escaping (PinCodeAndBiometryViewModel.Completion) -> Void
  ) {
    self.login = login
    self.accountType = accountType
    savedPincode = pincode
    self.completion = completion
    self.stateMachine = lockPinCodeAndBiometryStateMachine
    Task {
      await self.perform(.initialize)
    }
  }

  public func update(
    for event: LockPinCodeAndBiometryStateMachine.Event,
    from oldState: LockPinCodeAndBiometryStateMachine.State,
    to newState: LockPinCodeAndBiometryStateMachine.State
  ) async {

    switch (newState, event) {
    case (.initial, _): break
    case (let .biometricAuthenticationRequested(biometryType), _):
      viewState = .biometry(biometryType)
    case (.pinRequested, _):
      viewState = .pin
    case (let .authenticated(config), _):
      completion(.authenticated(config))
    case (let .pinValidationFailed(attempts), _):
      pincode = ""
      self.attempts = attempts
    case (.recoveryStarted, _):
      completion(.recover)
    case (.cancelled, _):
      completion(.cancel)
    case (.authenticationFailed, _):
      completion(.failure)
    }
  }

  func validateBiometry() async {
    await self.perform(
      .startBiometryAuthentication(CoreL10n.unlockDashlane, CoreL10n.enterPasscode))
  }
}

extension PinCodeAndBiometryViewModel {
  static var mock: PinCodeAndBiometryViewModel {
    PinCodeAndBiometryViewModel(
      login: Login("John"),
      accountType: .invisibleMasterPassword,
      pincode: "123456",
      lockPinCodeAndBiometryStateMachine: .mock
    ) { _ in

    }
  }
}
