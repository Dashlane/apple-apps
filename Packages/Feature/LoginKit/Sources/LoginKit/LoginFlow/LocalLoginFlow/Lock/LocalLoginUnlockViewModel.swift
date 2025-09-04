import Combine
import CoreKeychain
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import SwiftTreats
import SwiftUI
import UserTrackingFoundation

@MainActor
public class LocalLoginUnlockViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting
{
  public enum Completion {
    case authenticated(LocalLoginConfiguration)

    case logout

    case cancel
  }

  enum UnlockMode: Equatable {
    case masterPassword(Biometry?, MPUserAccountUnlockMode)
    case pincode(
      pinCodeLock: SecureLockMode.PinCodeLock, biometry: Biometry?, CoreSession.AccountType)
    case biometry(Biometry, CoreSession.AccountType)
    case passwordLessRecovery(afterFailure: Bool)
    case sso(_ deviceAccessKey: String)

    var biometryType: Biometry? {
      switch self {
      case .biometry(let biometryType, _):
        return biometryType
      default: return nil
      }
    }
  }

  enum UnlockOrigin {
    case login
    case lock
  }

  @Published
  var unlockMode: UnlockMode?

  @Published
  var showRememberPassword: Bool = false

  @Published public var isPerformingEvent: Bool = false
  @Published public var isLoadingAccount: Bool = false

  let login: Login
  let context: LoginUnlockContext
  let userSettings: UserSettings
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  let completion: (Completion) -> Void
  let masterPasswordLocalViewModelFactory: MasterPasswordLocalViewModel.Factory
  let biometryViewModelFactory: BiometryViewModel.Factory
  let pinCodeAndBiometryViewModelFactory: PinCodeAndBiometryViewModel.Factory
  let passwordLessRecoveryViewModelFactory: PasswordLessRecoveryViewModel.Factory
  let ssoUnlockViewModelFactory: SSOUnlockViewModel.Factory

  @Published public var stateMachine: LocalLoginUnlockStateMachine

  public init(
    login: Login,
    context: LoginUnlockContext,
    userSettings: UserSettings,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    logger: Logger,
    masterPasswordLocalViewModelFactory: MasterPasswordLocalViewModel.Factory,
    biometryViewModelFactory: BiometryViewModel.Factory,
    pinCodeAndBiometryViewModelFactory: PinCodeAndBiometryViewModel.Factory,
    passwordLessRecoveryViewModelFactory: PasswordLessRecoveryViewModel.Factory,
    localLoginUnlockStateMachine: LocalLoginUnlockStateMachine,
    ssoUnlockViewModelFactory: SSOUnlockViewModel.Factory,
    completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
  ) {
    self.login = login
    self.context = context
    self.userSettings = userSettings
    self.resetMasterPasswordService = resetMasterPasswordService
    self.completion = completion
    self.masterPasswordLocalViewModelFactory = masterPasswordLocalViewModelFactory
    self.pinCodeAndBiometryViewModelFactory = pinCodeAndBiometryViewModelFactory
    self.passwordLessRecoveryViewModelFactory = passwordLessRecoveryViewModelFactory
    self.biometryViewModelFactory = biometryViewModelFactory
    self.ssoUnlockViewModelFactory = ssoUnlockViewModelFactory
    self.stateMachine = localLoginUnlockStateMachine
    Task {
      await self.perform(.start)
    }
  }

  public func update(
    for event: CoreSession.LocalLoginUnlockStateMachine.Event,
    from oldState: CoreSession.LocalLoginUnlockStateMachine.State,
    to newState: CoreSession.LocalLoginUnlockStateMachine.State
  ) async {
    switch (newState, event) {
    case (.initialize, _):
      break
    case (let .masterPassword(_, biometry, userAccount), _):
      unlockMode = .masterPassword(biometry, userAccount)
    case (let .pincode(_, pinCodeLock, biometry, accountType), _):
      unlockMode = .pincode(pinCodeLock: pinCodeLock, biometry: biometry, accountType)
    case (let .biometry(_, biometry, accountType), _):
      unlockMode = .biometry(biometry, accountType)
    case (.passwordLessRecovery(afterFailure: let afterFailure), _):
      unlockMode = .passwordLessRecovery(afterFailure: afterFailure)
    case (let .sso(deviceAccessKey), _):
      unlockMode = .sso(deviceAccessKey)
    case (.logout, _):
      self.completion(.logout)
    case (let .completed(config), _):
      isLoadingAccount = true
      self.completion(.authenticated(config))
    }
  }
}

extension LocalLoginUnlockViewModel {
  func makeMasterPasswordLocalViewModel(biometry: Biometry?, unlockMode: MPUserAccountUnlockMode)
    -> MasterPasswordLocalViewModel
  {
    let stateMachine = stateMachine.makeMasterPasswordLocalLoginStateMachine(
      unlockMode: unlockMode,
      resetMasterPasswordService: resetMasterPasswordService,
      pinCodeattempts: PinCodeAttempts(internalStore: userSettings.internalStore), context: context)
    return masterPasswordLocalViewModelFactory.make(
      login: login,
      biometry: biometry,
      context: context,
      masterPasswordLocalStateMachine: stateMachine
    ) { [weak self] result in
      guard let self = self else { return }
      Task {
        switch result {
        case let .authenticated(config):
          await self.perform(.authenticated(config))
        case .biometry(let biometry):
          await self.perform(.askBiometryForMasterPassword(biometry))
        case .cancel:
          await self.perform(.logout)
        }
      }
    }
  }

  func makeBiometryViewModel(biometryType: Biometry, accountType: CoreSession.AccountType)
    -> BiometryViewModel
  {
    biometryViewModelFactory.make(
      login: login,
      biometryType: biometryType,
      context: context,
      biometryUnlockStateMachine: stateMachine.makeBiometryUnlockStateMachine(context: context)
    ) { [weak self] session in
      guard let self = self else {
        return
      }
      Task {
        guard let session else {
          await self.perform(.unlockFailed(.biometric))
          return
        }
        await self.perform(
          .authenticated(LocalLoginConfiguration(session: session, authenticationMode: .biometry)))
      }
    }
  }

  func makePinCodeAndBiometryViewModel(
    lock: SecureLockMode.PinCodeLock,
    accountType: CoreSession.AccountType,
    biometryType: Biometry? = nil
  ) -> PinCodeAndBiometryViewModel {
    let stateMachine = stateMachine.makeLockPinCodeAndBiometryStateMachine(
      pinCodeLock: lock,
      pinCodeAttempts: PinCodeAttempts(internalStore: userSettings.internalStore),
      context: context,
      biometry: biometryType)
    return pinCodeAndBiometryViewModelFactory.make(
      login: login,
      accountType: accountType,
      pincode: lock.code,
      lockPinCodeAndBiometryStateMachine: stateMachine
    ) { [weak self] result in
      guard let self = self else {
        return
      }

      Task {
        switch result {
        case let .authenticated(config):
          await self.perform(.authenticated(config))
        case .failure:
          await self.perform(.unlockFailed(.pin, biometryType))
        case .recover, .cancel:
          await self.perform(.cancel)
        }
      }
    }
  }

  func makePasswordLessRecoveryViewModel(recoverFromFailure: Bool) -> PasswordLessRecoveryViewModel
  {
    passwordLessRecoveryViewModelFactory.make(login: login, recoverFromFailure: recoverFromFailure)
    { [weak self] completion in
      guard let self = self else {
        return
      }

      Task {
        switch completion {
        case .logout:
          await self.perform(.logout)
        case .cancel:
          await self.perform(.start)
        }
      }

    }
  }

  func makeSSOUnlockViewModel(deviceAccessKey: String) -> SSOUnlockViewModel {
    ssoUnlockViewModelFactory.make(
      login: login, deviceAccessKey: deviceAccessKey,
      stateMachine: stateMachine.makeSSOUnlockStateMachine(state: .locked)
    ) { result in
      Task {
        let result = try result.get()
        switch result {
        case let .completed(ssoKeys):
          await self.perform(.handleSSOresult(ssoKeys))
        case .cancel, .logout:
          self.completion(.logout)
        }
      }
    }
  }
}
