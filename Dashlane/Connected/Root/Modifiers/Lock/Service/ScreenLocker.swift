import Combine
import CorePremium
import CoreSession
import CoreSettings
import DashTypes
import LoginKit
import PremiumKit
import SwiftTreats
import UIKit

public class ScreenLocker {
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

  var privacyShutterOnAppInactive: Bool = true {
    didSet {
      if privacyShutterOnAppInactive,
        UIApplication.shared.applicationState != .active
      {
        appWillResignActive()
      }
    }
  }

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
  private var unlockSubscription: AnyCancellable?
  private var activeLockTimer: Timer?
  private var lockTimerStartTime: TimeInterval?
  private let logger: Logger
  let masterKey: CoreSession.MasterKey
  let secureLockProvider: SecureLockProviderProtocol
  let userLockSettings: KeyedSettings<UserLockSettingsKey>
  private let userSpacesService: UserSpacesService
  let login: Login
  let session: Session

  init(
    masterKey: CoreSession.MasterKey,
    secureLockProvider: SecureLockProviderProtocol,
    settings: LocalSettingsStore,
    userSpacesService: UserSpacesService,
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
      activeLockTimer?.invalidate()
      lockTimerStartTime = nil
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

  func suspendMomentarelyPrivacyShutter() {
    privacyShutterOnAppInactive = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
      self.privacyShutterOnAppInactive = true
    }
  }

  private func appWillResignActive() {
    guard privacyShutterOnAppInactive, !self.setting.paused else {
      return
    }
    logger.debug("appDidEnterBackground privacy on")
    self.privacyShutterOn = true
  }

  private func appDidBecomeActive() {
    logger.debug("appDidBecomeActive privacy off")
    self.privacyShutterOn = UIApplication.shared.applicationState != .active
    secureLockAfterAppInBackground()
  }

  func secureLock() {
    secureLockMode = secureLockProvider.secureLockMode()
    logger.debug("session securely locked using \(String(describing: self.secureLockMode))")
  }

  private func secureLockAfterAppInBackground() {
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
    guard unlockSubscription == nil else {
      return
    }
    logger.debug("session will unlock")

    unlockSubscription =
      $privacyShutterOn
      .filter { !$0 }
      .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
      .sink { [weak self] _ in
        guard let self = self else {
          return
        }
        self.logger.debug("session did unlock")
        self.unlockSubscription = nil

        self.secureLockMode = nil
      }
  }

}

extension ScreenLocker: UnlockSessionHandler {
  @MainActor
  public func unlock(with masterKey: CoreSession.MasterKey, isRecoveryLogin: Bool) async throws
    -> Session?
  {
    guard masterKey == self.masterKey else {
      throw MasterPasswordLocalLoginStateMachine.Error.wrongMasterKey
    }
    return session
  }
}

extension ScreenLocker: PremiumKit.ScreenLocker {}
