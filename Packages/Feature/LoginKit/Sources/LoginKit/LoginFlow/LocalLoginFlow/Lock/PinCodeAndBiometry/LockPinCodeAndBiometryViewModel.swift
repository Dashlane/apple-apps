import Combine
import CoreKeychain
import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import Foundation
import LocalAuthentication
import SwiftTreats

#if canImport(UIKit)
  import UIKit
  import CoreSettings
#endif

@MainActor
public class LockPinCodeAndBiometryViewModel: ObservableObject, LoginKitServicesInjecting {
  public enum State {
    case biometricAuthenticationRequested
    case biometricAuthenticationFailure
    case biometricAuthenticationSuccess
    case pinRequested
    case pinIncorrect
    case pinCorrect
  }

  public enum Completion {
    case biometricAuthenticationSuccess
    case pinAuthenticationSuccess
    case failure
    case recover
    case cancel
  }

  public let login: Login

  @Published
  public var pincode: String = "" {
    didSet {
      if pincode.count == savedPincode.count {
        Task {
          await validatePinCode()
        }
      }
    }
  }

  @Published
  public var attempts: Int = 0

  @Published
  private var state: State {
    didSet {
      if state == .biometricAuthenticationFailure {
        activityReporter.log(.biometricAuthenticationFailure, context: context)
        state = .pinRequested
      }

      activityReporter.log(state, context: context)
    }
  }

  public var loading: Bool {
    switch state {
    case .biometricAuthenticationSuccess, .pinCorrect:
      return true
    default:
      return false
    }
  }

  public var biometricAuthenticationInProgress: Bool {
    switch state {
    case .biometricAuthenticationSuccess, .biometricAuthenticationRequested,
      .biometricAuthenticationFailure:
      return true
    default:
      return false
    }
  }

  let pinCodeLock: SecureLockMode.PinCodeLock
  let savedPincode: String
  let context: LoginUnlockContext
  let biometryType: Biometry?
  let accountType: AccountType

  let completion: (Completion) -> Void

  var pincodeLength: Int {
    savedPincode.count
  }
  private let unlocker: UnlockSessionHandler
  private let loginMetricsReporter: LoginMetricsReporterProtocol
  private let activityReporter: ActivityReporterProtocol
  private var cancellables: Set<AnyCancellable> = []

  public init(
    login: Login,
    accountType: CoreSession.AccountType,
    pinCodeLock: SecureLockMode.PinCodeLock,
    biometryType: Biometry? = nil,
    context: LoginUnlockContext,
    unlocker: UnlockSessionHandler,
    loginMetricsReporter: LoginMetricsReporterProtocol,
    activityReporter: ActivityReporterProtocol,
    completion: @escaping (LockPinCodeAndBiometryViewModel.Completion) -> Void
  ) {
    self.login = login
    self.accountType = accountType
    self.pinCodeLock = pinCodeLock
    savedPincode = pinCodeLock.code
    self.biometryType = biometryType

    self.context = context

    self.unlocker = unlocker
    self.activityReporter = activityReporter
    self.loginMetricsReporter = loginMetricsReporter

    self.completion = completion

    if let biometryType = biometryType {
      state = .biometricAuthenticationRequested
      Task {
        await authenticate(using: biometryType)
      }
    } else {
      state = .pinRequested
    }

    pinCodeLock.attempts.countPublisher.assign(to: &$attempts)

    #if canImport(UIKit)
      NotificationCenter.default.publisher(
        for: UIApplication.applicationWillEnterForegroundNotification
      )
      .sink { [weak self] _ in self?.refresh() }
      .store(in: &cancellables)
    #endif
  }

  public func logOnAppear() {
    activityReporter.log(state, context: context)
  }

  public func cancel() {
    completion(.cancel)
  }

  public func authenticate(using biometryType: Biometry) async {
    loginMetricsReporter.startLoginTimer(from: biometryType)
    do {
      try await Biometry.authenticate(
        reasonTitle: L10n.Core.unlockDashlane, fallbackTitle: L10n.Core.enterPasscode)
      do {
        try await unlocker.validateMasterKey(pinCodeLock.masterKey, isRecoveryLogin: false)
        state = .biometricAuthenticationSuccess
        completion(.biometricAuthenticationSuccess)
      } catch {
        loginMetricsReporter.resetTimer(.login)
        state = .pinRequested
        completion(.failure)
      }
    } catch {
      state = .biometricAuthenticationFailure
    }
  }

  private func refresh() {
    if pinCodeLock.attempts.tooManyAttempts {
      completion(.failure)
    }
  }

  public func validatePinCode() async {
    guard savedPincode == pincode else {
      state = .pinIncorrect
      pinCodeLock.attempts.addNewAttempt()
      pincode = ""
      if pinCodeLock.attempts.tooManyAttempts {
        completion(.failure)
      }
      return
    }
    state = .pinCorrect
    pinCodeLock.attempts.removeAll()
    loginMetricsReporter.startLoginTimer(from: .pinCode)
    do {
      try await unlocker.validateMasterKey(pinCodeLock.masterKey, isRecoveryLogin: false)
      completion(.pinAuthenticationSuccess)
    } catch {
      loginMetricsReporter.resetTimer(.login)
      completion(.failure)
    }
  }

  public func recover() {
    completion(.recover)
  }
}

#if canImport(UIKit)
  extension LockPinCodeAndBiometryViewModel {
    static var mock: LockPinCodeAndBiometryViewModel {
      LockPinCodeAndBiometryViewModel(
        login: Login("John"),
        accountType: .invisibleMasterPassword,
        pinCodeLock: SecureLockMode.PinCodeLock(
          code: "123456", attempts: PinCodeAttempts(internalStore: .mock()),
          masterKey: .masterPassword("_")),
        context: LoginUnlockContext(
          verificationMode: .emailToken, isBackupCode: nil, origin: .login,
          localLoginContext: .passwordApp),
        unlocker: .mock(),
        loginMetricsReporter: .fake,
        activityReporter: .mock
      ) { _ in

      }
    }
  }
#endif

extension ActivityReporterProtocol {
  fileprivate func log(_ state: LockPinCodeAndBiometryViewModel.State?, context: LoginUnlockContext)
  {
    guard let state = state else {
      return
    }

    switch state {
    case .biometricAuthenticationRequested:
      report(
        UserEvent.AskAuthentication(
          mode: .biometric,
          reason: context.reason,
          verificationMode: context.verificationMode))
    case .biometricAuthenticationFailure:
      report(
        UserEvent.Login(
          isBackupCode: context.isBackupCode,
          mode: .biometric,
          status: .errorWrongBiometric,
          verificationMode: context.verificationMode))
    case .biometricAuthenticationSuccess:
      break

    case .pinRequested:
      report(
        UserEvent.AskAuthentication(
          mode: .pin,
          reason: context.reason,
          verificationMode: context.verificationMode))
      reportPageShown(.unlockPin)
    case .pinIncorrect:
      report(
        UserEvent.Login(
          isBackupCode: context.isBackupCode,
          mode: .pin,
          status: .errorWrongPin,
          verificationMode: context.verificationMode))
    case .pinCorrect:
      break
    }
  }

}
