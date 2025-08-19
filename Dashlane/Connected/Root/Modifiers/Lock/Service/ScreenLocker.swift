import Combine
import CorePremium
import CoreSession
import CoreSettings
import CoreTypes
import LogFoundation
import LoginKit
import PremiumKit
import SwiftTreats
import UIKit

public final class ScreenLocker {
  enum Lock: Equatable {
    case privacyShutter
    case secure(_ mode: SecureLockMode)
  }

  struct AutoLockSetting {
    var lockOnExit: Bool
    var lockTimeInterval: TimeInterval?
    var paused: Bool = false
  }

  enum LockOnExit {
    case businessEnforced
    case enabled
    case disabled
  }

  @Published
  private var secureLockMode: SecureLockMode?

  @Published
  private var privacyShutterOn: Bool = false
  private var privacyShutterOnAppInactive: Bool = true

  @Published
  var lock: Lock?

  var setting: AutoLockSetting {
    didSet {
      userLockSettings[.autoLockDelay] = setting.lockTimeInterval
      userLockSettings[.lockOnExit] = setting.lockOnExit

      configure()
    }
  }

  var lockDelay: TimeInterval? {
    get {
      return setting.lockTimeInterval
    }
    set {
      self.setting.lockTimeInterval = newValue
    }
  }

  var lockOnExitState: LockOnExit {
    if userSpacesService.configuration.currentTeam?.teamInfo.lockOnExit == true {
      return .businessEnforced
    }
    return userLockSettings[.lockOnExit] == true ? .enabled : .disabled
  }

  var currentKernelBootTime: TimeInterval? {
    var mangementInformationBase = [CTL_KERN, KERN_BOOTTIME]
    var bootTime = timeval()
    var bootTimeSize: Int = MemoryLayout<timeval>.size
    guard
      sysctl(
        &mangementInformationBase, UInt32(mangementInformationBase.count), &bootTime, &bootTimeSize,
        nil, 0) != -1
    else {
      return nil
    }
    return Date().timeIntervalSince1970
      - (TimeInterval(bootTime.tv_sec) + TimeInterval(bootTime.tv_usec) / 1_000_000.0)
  }

  private var cancellables = Set<AnyCancellable>()
  private var autoLockTask: Task<Void, Never>?
  private var businessTeamCancellable: AnyCancellable?
  private var activeLockTimer: Timer?
  private var lockTimerStartTime: TimeInterval?
  private let logger: Logger
  let masterKey: CoreSession.MasterKey
  let secureLockProvider: SecureLockProviderProtocol
  let userLockSettings: KeyedSettings<UserLockSettingsKey>
  private let userSpacesService: UserSpacesService
  let login: Login
  let session: Session
  let deeplinkService: DeepLinkingServiceProtocol
  private var suspensionPrivacyShutterTask: Task<Void, Error>?

  init(
    masterKey: CoreSession.MasterKey,
    secureLockProvider: SecureLockProviderProtocol,
    settings: LocalSettingsStore,
    userSpacesService: UserSpacesService,
    deeplinkService: DeepLinkingServiceProtocol,
    logger: Logger,
    session: Session
  ) {
    self.masterKey = masterKey
    self.secureLockProvider = secureLockProvider
    self.userLockSettings = settings.keyed(by: UserLockSettingsKey.self)
    self.userSpacesService = userSpacesService
    self.session = session
    self.login = session.login
    self.logger = logger
    self.deeplinkService = deeplinkService
    self.setting = AutoLockSetting(
      lockOnExit: userLockSettings[.lockOnExit] ?? false,
      lockTimeInterval: userLockSettings[.autoLockDelay] ?? 300)
    businessTeamCancellable = userSpacesService.$configuration.sink { [weak self] configuration in
      self?.businessTeamUpdated(configuration.currentTeam)
    }
    configure()
  }

  private func configure() {
    cancellables.removeAll()
    autoLockTask?.cancel()

    NotificationCenter.default.publisher(for: UIApplication.applicationWillResignActiveNotification)
      .sink { [weak self] _ in
        self?.appWillResignActive()
      }.store(in: &cancellables)

    NotificationCenter.default.publisher(
      for: UIApplication.applicationWillEnterForegroundNotification
    )
    .sink { [weak self] _ in
      if self?.setting.lockOnExit == true {
        self?.secureLock()
      }
    }.store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
      .sink { [weak self] _ in
        self?.appDidBecomeActive()
      }.store(in: &cancellables)

    if let lockTimeInterval = setting.lockTimeInterval, lockTimeInterval > 0, !setting.paused {
      autoLockTask = makeAutoLockTaskOnTouch()
    } else {
      stopAutoLockTimer()
    }

    $secureLockMode
      .receive(on: DispatchQueue.main)
      .sink { [weak self] mode in
        if mode != nil {
          self?.stopAutoLockTimer()
        } else {
          self?.resetAutoLockTimer()
        }
      }.store(in: &cancellables)

    $privacyShutterOn
      .combineLatest($secureLockMode) { isAppActive, secureLockMode in
        if let mode = secureLockMode {
          return Lock.secure(mode)
        } else if isAppActive {
          return Lock.privacyShutter
        } else {
          return nil
        }
      }
      .removeDuplicates()
      .assign(to: \.lock, on: self)
      .store(in: &cancellables)

    deeplinkService.deepLinkPublisher.sink { [weak self] deeplink in
      guard let self = self else {
        return
      }
      switch deeplink {
      case .mplessLogin:
        guard !self.setting.lockOnExit else {
          return
        }

        self.secureLock()
      default: break
      }
    }.store(in: &cancellables)
  }
  private func businessTeamUpdated(_ team: CurrentTeam?) {

    let lockOnExitEnforced = team?.teamInfo.lockOnExit ?? false
    if lockOnExitEnforced {
      self.setting.lockOnExit = true
    }
  }

  private func makeAutoLockTaskOnTouch() -> Task<Void, Never> {
    Task { @MainActor [weak self] in
      let events = FiberUIApplication.touchEvents._throttle(for: .seconds(1), latest: false)
      for await _ in events {
        self?.resetAutoLockTimer()
      }
    }
  }
  private func stopAutoLockTimer() {
    self.activeLockTimer?.invalidate()
    lockTimerStartTime = nil
  }

  private func resetAutoLockTimer() {
    activeLockTimer?.invalidate()
    lockTimerStartTime = nil

    guard let time = setting.lockTimeInterval == 0 ? nil : setting.lockTimeInterval else {
      return
    }

    activeLockTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) {
      [weak self] _ in
      guard let self = self else {
        return
      }
      self.logger.debug("scheduled auto lock")
      self.secureLock()
    }

    lockTimerStartTime = currentKernelBootTime
  }

  public func pauseAutoLock() {
    self.setting.paused = true
  }

  public func resumeAutoLock() {
    self.setting.paused = false
  }

  func suspendMomentarilyPrivacyShutter() {
    logger.debug("Privacy suspended")

    privacyShutterOnAppInactive = false
    privacyShutterOn = false

    suspensionPrivacyShutterTask?.cancel()
    suspensionPrivacyShutterTask = Task { [weak self] in
      try await Task.sleep(for: .seconds(3))
      self?.activatePrivacyShutterOnAppInactive()
    }
  }

  func activatePrivacyShutterOnAppInactive() {
    suspensionPrivacyShutterTask?.cancel()
    privacyShutterOnAppInactive = true
    privacyShutterOn = UIApplication.shared.applicationState != .active

    self.logger.debug("Privacy enabled")
  }

  private func appWillResignActive() {
    guard privacyShutterOnAppInactive, !self.setting.paused else {
      return
    }
    logger.debug("appWillResignActive Privacy on")
    self.privacyShutterOn = true
  }

  private func appDidBecomeActive() {
    guard UIApplication.shared.applicationState == .active else {
      return
    }

    logger.debug("appDidBecomeActive Privacy off")
    self.privacyShutterOn = false
    secureLockTimerAfterAppBecomeActive()
  }

  func secureLock() {
    secureLockMode = secureLockProvider.secureLockMode()
    logger.debug("session securely locked using \(String(describing: self.secureLockMode))")
  }

  private func secureLockTimerAfterAppBecomeActive() {
    guard let lockTimeInterval = setting.lockTimeInterval, lockTimeInterval > 0,
      let lockTimerStartTime = lockTimerStartTime,
      let currentKernelBootTime = currentKernelBootTime,
      currentKernelBootTime - lockTimerStartTime >= lockTimeInterval
    else {
      return
    }
    logger.debug("scheduled auto lock (after app was in background)")
    self.lockTimerStartTime = nil
    activeLockTimer?.invalidate()
    secureLock()
  }

  func unlock() {
    logger.debug("session did unlock")
    if secureLockMode?.biometryType != nil {
      suspendMomentarilyPrivacyShutter()
    }
    secureLockMode = nil
  }
}

extension ScreenLocker: UnlockSessionHandler {
  @MainActor
  public func unlock(with masterKey: CoreSession.MasterKey) async throws -> Session {
    guard masterKey == self.masterKey else {
      throw MasterPasswordLocalLoginStateMachine.Error.wrongMasterKey
    }
    return session
  }
}

extension ScreenLocker: PremiumKit.ScreenLocker {}

extension ScreenLocker {
  static var mock: ScreenLocker {
    ScreenLocker(
      masterKey: .masterPassword("_", serverKey: nil),
      secureLockProvider: SecureLockProvider.mock,
      settings: .mock(),
      userSpacesService: .mock(),
      deeplinkService: DeepLinkingService.fakeService,
      logger: .mock,
      session: .mock())
  }
}
