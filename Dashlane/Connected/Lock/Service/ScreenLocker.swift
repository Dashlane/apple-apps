import UIKit
import Combine
import CoreSession
import DashTypes
import SwiftTreats
import DashlaneAppKit
import CorePremium
import CoreSettings
import LoginKit
import PremiumKit

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
                  UIApplication.shared.applicationState != .active {
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
        if teamSpaceService.businessTeamsInfo.availableBusinessTeam?.space.info.lockOnExit == true {
            return .businessEnforced
        }
        return userLockSettings[.lockOnExit] == true ? .enabled : .disabled
    }

            var currentKernelBootTime: TimeInterval? {
        var managementInformationBase = [CTL_KERN, KERN_BOOTTIME]
        var bootTime = timeval()
        var bootTimeSize: Int = MemoryLayout<timeval>.size
        guard sysctl(&managementInformationBase, UInt32(managementInformationBase.count), &bootTime, &bootTimeSize, nil, 0) != -1 else {
            return nil
        }
        return Date().timeIntervalSince1970 - (TimeInterval(bootTime.tv_sec) + TimeInterval(bootTime.tv_usec) / 1_000_000.0)
    }

    private var cancellables = Set<AnyCancellable>()
    private var businessTeamCancellable: AnyCancellable?
    private var unlockSubscription: AnyCancellable?
        private var activeLockTimer: Timer?
            private var lockTimerStartTime: TimeInterval?
    private let logger: Logger
    let masterKey: MasterKey
    let secureLockProvider: SecureLockProviderProtocol
    let userLockSettings: KeyedSettings<UserLockSettingsKey>
    private let teamSpaceService: TeamSpacesService
    let login: Login

    init(masterKey: MasterKey,
         secureLockProvider: SecureLockProviderProtocol,
         settings: LocalSettingsStore,
         teamSpaceService: TeamSpacesService,
         logger: Logger,
         login: Login) {
        self.masterKey = masterKey
        self.secureLockProvider = secureLockProvider
        self.userLockSettings = settings.keyed(by: UserLockSettingsKey.self)
        self.teamSpaceService = teamSpaceService
        self.login = login
        self.logger = logger
                self.setting = AutoLockSetting(lockOnExit: userLockSettings[.lockOnExit] ?? false,
                                       lockTimeInterval: userLockSettings[.autoLockDelay] ?? 300)
        businessTeamCancellable = teamSpaceService.$businessTeamsInfo.sink { [weak self] info in
            self?.businessTeamUpdated(info.availableBusinessTeam)
        }
        configure()
    }

    private func configure() {
        cancellables.removeAll()

                NotificationCenter.default.publisher(for: UIApplication.applicationWillResignActiveNotification)
            .sink { [weak self] _ in
                self?.appWillResignActive()
        }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.applicationWillEnterForegroundNotification)
            .sink { [weak self] _ in
                if self?.setting.lockOnExit == true {
                    self?.secureLock()
                }
        }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.appDidBecomeActive()
        }.store(in: &cancellables)

                if setting.lockTimeInterval != nil && !setting.paused {
            NotificationCenter.default.publisher(for: FiberUIApplication.didReceiveTouchNotification)
                .sink { [weak self] _ in
                    self?.resetAutoLockTimer()
            }.store(in: &cancellables)
        } else {
            activeLockTimer?.invalidate()
            lockTimerStartTime = nil
        }

                $secureLockMode
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

    private func businessTeamUpdated(_ team: BusinessTeam?) {

        let lockOnExitEnforced = team?.space.info.lockOnExit ?? false
        if lockOnExitEnforced {
            self.setting.lockOnExit = true
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

        activeLockTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { [weak self] _ in
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
        logger.debug("session securely locked using \(String(describing: secureLockMode))")
    }

    private func secureLockAfterAppInBackground() {
        guard let lockTimeInterval = setting.lockTimeInterval, lockTimeInterval > 0,
              let lockTimerStartTime = lockTimerStartTime,
              let currentKernelBootTime = currentKernelBootTime,
              currentKernelBootTime - lockTimerStartTime >= lockTimeInterval else {
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

        unlockSubscription = $privacyShutterOn
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
    public func unlock(with masterKey: MasterKey, loginContext: LoginContext) async throws {
        guard masterKey == self.masterKey else {
            throw LocalLoginHandler.Error.wrongMasterKey
        }
    }
}

extension ScreenLocker: PremiumKit.ScreenLocker {}
