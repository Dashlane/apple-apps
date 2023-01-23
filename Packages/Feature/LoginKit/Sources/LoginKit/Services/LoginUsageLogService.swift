import Foundation
import DashlaneReportKit
import DashTypes
import SwiftTreats

public protocol LoginUsageLogServiceProtocol {
    func startLoginTimer(from biometryType: Biometry)
    func startLoginTimer(from authType: AuthenticationType)
    func resetTimer(_ timer: LoginUsageLogService.Timer)
    func performanceLogInfo(_ timer: LoginUsageLogService.Timer) -> LoginPerformanceLogInfo?
    func refreshTimer(_ timer: LoginUsageLogService.Timer)
    func didUseOTP()
    func didRegisterNewDevice()
    func loginUsageLog() -> UsageLogCode2UserLogin?
    func accountCreationUsageLogs(anonymousDeviceId: String) -> UsageLogCode1AccountCreation
    func getAndClearCachedLogs() -> [LogCodeProtocol]
    func reset()
    func newDeviceLog(anonymousComputerId: String, fromAccountCreation: Bool) -> UsageLogCode17NewDevice
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?)
    func markAsLoadingSessionFromSavedLogin()
    var hasRegisteredNewDevice: Bool { get }
}

public class LoginUsageLogService: LoginUsageLogServiceProtocol {
    enum OtpStyle: Int {
        case none = 0
        case otpForNewDeviceOrLogin = 3 
    }

    public enum Timer {
        case login
        case appLaunch
    }

    public init(appLaunchTimeStamp: TimeInterval) {
        self.appLaunchTimeStamp = appLaunchTimeStamp
    }

    private var startLoginTimeStamp: TimeInterval?
    private var appLaunchTimeStamp: TimeInterval
    private var otp: OtpStyle = .none

        private var isSessionFromSavedLogin: Bool = false

    private(set) public var hasRegisteredNewDevice: Bool = false

        private var isUserOptedInForMarketingCommunication: Bool?

    private var authType: AuthenticationType?

        var cachedLogs: [LogCodeProtocol] = []

    public func startLoginTimer(from biometryType: Biometry) {
        self.startLoginTimer(from: biometryType == .touchId ? AuthenticationType.touchId : AuthenticationType.faceId)
    }

    public func startLoginTimer(from authType: AuthenticationType) {
        refreshTimer(.login)
        self.authType = authType
    }

        public func resetTimer(_ timer: Timer) {
        switch timer {
        case .login:
            self.startLoginTimeStamp = nil
            self.authType = nil
        case .appLaunch:
            self.isSessionFromSavedLogin = false
        }
    }

        public func performanceLogInfo(_ timer: Timer) -> LoginPerformanceLogInfo? {
        switch timer {
        case .appLaunch:
            guard isSessionFromSavedLogin else { return nil }
            guard let duration = getStartTime(for: .appLaunch) else { return nil }
            let durationInMilliseconds = Int(duration * 1000)
            return LoginPerformanceLogInfo(duration: durationInMilliseconds,
                                           performanceLogType: .timeToAppReady)
        case .login:
            guard let duration = getStartTime(for: .login),
                let type = self.authType else { return nil }
            let durationInMilliseconds = Int(duration * 1000)
            return LoginPerformanceLogInfo(duration: durationInMilliseconds,
                                           performanceLogType: .timeToLogin(authType: type))
        }
    }

    private func getStartTime(for timer: Timer) -> TimeInterval? {
        switch timer {
        case .login:
            guard let start = startLoginTimeStamp else { return nil }
            return Date().timeIntervalSince(Date(timeIntervalSince1970: start))
        case .appLaunch:
            return Date().timeIntervalSince(Date(timeIntervalSince1970: appLaunchTimeStamp))
        }
    }

        public func refreshTimer(_ timer: Timer) {
        switch timer {
        case .appLaunch:
            appLaunchTimeStamp = Date().timeIntervalSince1970
        case .login:
            startLoginTimeStamp = Date().timeIntervalSince1970
        }
    }

    public func didUseOTP() {
        otp = .otpForNewDeviceOrLogin
    }

    public func didRegisterNewDevice() {
        self.hasRegisteredNewDevice = true
    }

    func updateSubscribeToMarketingCommunication(isOptIn: Bool) {
        isUserOptedInForMarketingCommunication = isOptIn
    }

    public func loginUsageLog() -> UsageLogCode2UserLogin? {
        guard let timeIntervalSinceLoading = getStartTime(for: .login) else {
            return nil
        }
        return UsageLogCode2UserLogin(sender: .fromMobile,
                                      OTP: otp == .otpForNewDeviceOrLogin,
                                      loadDuration: Int(timeIntervalSinceLoading * 1000))
    }

    public func markAsLoadingSessionFromSavedLogin() {
        isSessionFromSavedLogin = true
    }

    public func accountCreationUsageLogs(anonymousDeviceId: String) -> UsageLogCode1AccountCreation {
        let log = UsageLogCode1AccountCreation(origin: "iOS",
                                               lang: System.language,
                                               oslang: System.language,
                                               format: System.country,
                                               osformat: System.country,
                                               anonymouscomputerid: anonymousDeviceId,
                                               subscribe: isUserOptedInForMarketingCommunication)
        return log
    }

        public func getAndClearCachedLogs() -> [LogCodeProtocol] {
        let cachedLogs = self.cachedLogs
        self.cachedLogs = []
        return cachedLogs
    }

        public func reset() {
        cachedLogs = []
        otp = .none
        isUserOptedInForMarketingCommunication = nil
        resetTimer(.login)
    }

        public func newDeviceLog(anonymousComputerId: String, fromAccountCreation: Bool) -> UsageLogCode17NewDevice {
        return UsageLogCode17NewDevice(anonymouscomputerid: anonymousComputerId,
                                       creation: fromAccountCreation,
                                       otpstyle: otp.rawValue)
    }

        public func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?) {
        self.cachedLogs.append(log)
        completion?(.success(true))
    }
}

extension LoginUsageLogService {
    private class FakeLoginUsageLogService: LoginUsageLogServiceProtocol {
        var hasRegisteredNewDevice: Bool = false

        func markAsLoadingSessionFromSavedLogin() {}
        func startLoginTimer(from loginType: AuthenticationType) {}
        func startLoginTimer(from biometryType: Biometry) {}
        func resetTimer(_ timer: LoginUsageLogService.Timer) {}
        func performanceLogInfo(_ timer: LoginUsageLogService.Timer) -> LoginPerformanceLogInfo? { return nil }
        func refreshTimer(_ timer: LoginUsageLogService.Timer) {}
        func didUseOTP() {}
        func didRegisterNewDevice() {}
        func loginUsageLog() -> UsageLogCode2UserLogin? { return nil }
        func getAndClearCachedLogs() -> [LogCodeProtocol] { return [] }
        func reset() {}
        func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?) {}

        func accountCreationUsageLogs(anonymousDeviceId: String) -> UsageLogCode1AccountCreation {
            return UsageLogCode1AccountCreation(origin: "", anonymouscomputerid: "")
        }

        func newDeviceLog(anonymousComputerId: String, fromAccountCreation: Bool) -> UsageLogCode17NewDevice {
            return UsageLogCode17NewDevice(anonymouscomputerid: "", creation: false)
        }

    }

    public static var mock: LoginUsageLogServiceProtocol {
        return FakeLoginUsageLogService()
    }
}
