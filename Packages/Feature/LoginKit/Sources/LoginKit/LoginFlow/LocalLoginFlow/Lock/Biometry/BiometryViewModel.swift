import Combine
import CoreKeychain
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import Foundation
import SwiftTreats

#if canImport(UIKit)
  import UIKit
#endif

@MainActor
public class BiometryViewModel: ObservableObject, LoginKitServicesInjecting {
  public let login: Login
  public let biometryType: Biometry

  @Published
  public var shouldDisplayProgress: Bool = false

  @Published
  public var canShowPrompt: Bool = true

  let userSettings: UserSettings
  let unlocker: UnlockSessionHandler
  let loginMetricsReporter: LoginMetricsReporterProtocol
  private var cancellable: AnyCancellable?
  public let manualLockOrigin: Bool
  private let activityReporter: ActivityReporterProtocol
  private let context: LoginUnlockContext
  private let keychainService: AuthenticationKeychainServiceProtocol
  private let completion: (_ isSuccess: Bool) -> Void

  public init(
    login: Login,
    biometryType: Biometry,
    manualLockOrigin: Bool = false,
    unlocker: UnlockSessionHandler,
    context: LoginUnlockContext,
    loginMetricsReporter: LoginMetricsReporterProtocol,
    activityReporter: ActivityReporterProtocol,
    userSettings: UserSettings,
    keychainService: AuthenticationKeychainServiceProtocol,
    completion: @escaping (_ isSuccess: Bool) -> Void
  ) {
    self.login = login
    self.context = context
    self.loginMetricsReporter = loginMetricsReporter
    self.activityReporter = activityReporter
    self.biometryType = biometryType
    self.keychainService = keychainService
    self.unlocker = unlocker
    self.completion = completion
    self.userSettings = userSettings
    self.manualLockOrigin = manualLockOrigin
    cancellable = NotificationCenter
      .default
      .didBecomeActiveNotificationPublisher()?
      .sink { [weak self] _ in
        self?.validateBiometry()
      }
  }

  private func validateBiometry() {
    Task {
      await validate()
    }
  }

  @MainActor
  public func validate() async {
    #if canImport(UIKit)
      if !context.localLoginContext.isExtension {
        guard UIApplication.shared.applicationState == .active else { return }
      }
    #endif

    guard canShowPrompt else {
      return
    }

    canShowPrompt = false

    guard let masterKey = try? await self.keychainService.masterKey(for: self.login) else {
      self.completion(false)
      self.activityReporter.logFailure(for: context)
      return
    }
    self.shouldDisplayProgress = true
    switch masterKey {
    case .masterPassword(let masterPassword):
      self.loginMetricsReporter.startLoginTimer(from: self.biometryType)
      do {
        try await self.unlocker.validateMasterKey(
          .masterPassword(masterPassword, serverKey: nil), isRecoveryLogin: false)
        completion(true)
        guard self.biometryType == .touchId else { return }
      } catch {
        self.loginMetricsReporter.resetTimer(.login)
        try? self.keychainService.removeMasterKey(for: self.login)
        let lockSettings = self.userSettings.internalStore.keyed(by: UserLockSettingsKey.self)
        lockSettings[.biometric] = false
        self.activityReporter.logFailure(for: context)
        completion(false)
        guard self.biometryType == .touchId else { return }
      }
    case .key(let key):
      do {
        try await self.unlocker.validateMasterKey(.ssoKey(key), isRecoveryLogin: false)
        completion(true)
      } catch {
        self.activityReporter.logFailure(for: context)
        completion(false)
      }
    }
  }

  public func logAskAuthentication() {
    self.activityReporter.logAskAuthentication(for: context)
  }

  public func cancel() {
    self.completion(false)
  }
}

extension ActivityReporterProtocol {
  fileprivate func logAskAuthentication(for context: LoginUnlockContext) {
    report(UserEvent.AskAuthentication(mode: .biometric, reason: .unlockApp))
  }

  fileprivate func logFailure(for context: LoginUnlockContext) {
    report(
      UserEvent.Login(
        isBackupCode: context.isBackupCode,
        mode: .biometric,
        status: .errorWrongBiometric,
        verificationMode: context.verificationMode))
  }
}

extension BiometryViewModel {
  static func mock(type: Biometry) -> BiometryViewModel {
    BiometryViewModel(
      login: Login(""),
      biometryType: type,
      unlocker: .mock,
      context: LoginUnlockContext(
        verificationMode: .emailToken, isBackupCode: nil, origin: .login,
        localLoginContext: .passwordApp),
      loginMetricsReporter: .fake,
      activityReporter: .mock,
      userSettings: .mock,
      keychainService: .fake,
      completion: { _ in })
  }
}
