import Foundation
import DashTypes
import SwiftTreats

public protocol LoginMetricsReporterProtocol {
    func startLoginTimer(from biometryType: Biometry)
    func startLoginTimer(from authType: AuthenticationType)
    func resetTimer(_ timer: LoginMetricsReporter.Timer)
    func getPerformanceLogInfo(_ timer: LoginMetricsReporter.Timer) -> LoginPerformanceLogInfo?
    func refreshTimer(_ timer: LoginMetricsReporter.Timer)
    func reset()
    func markAsLoadingSessionFromSavedLogin()
}

public class LoginMetricsReporter: LoginMetricsReporterProtocol {
    public enum Timer {
        case login
        case appLaunch
    }

    public init(appLaunchTimeStamp: TimeInterval) {
        self.appLaunchTimeStamp = appLaunchTimeStamp
    }

    private var startLoginTimeStamp: TimeInterval?
    private var appLaunchTimeStamp: TimeInterval

        private var performanceLogInfo: LoginPerformanceLogInfo?

        private var isSessionFromSavedLogin: Bool = false

        private var isUserOptedInForMarketingCommunication: Bool?

    private var authType: AuthenticationType?

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

        public func getPerformanceLogInfo(_ timer: Timer) -> LoginPerformanceLogInfo? {
        if let performanceLogInfo = self.performanceLogInfo {
            return performanceLogInfo
        }
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

    func updateSubscribeToMarketingCommunication(isOptIn: Bool) {
        isUserOptedInForMarketingCommunication = isOptIn
    }

    public func markAsLoadingSessionFromSavedLogin() {
        isSessionFromSavedLogin = true
    }

        public func reset() {
        isUserOptedInForMarketingCommunication = nil
        resetTimer(.login)
    }
}

extension LoginMetricsReporterProtocol where Self == FakeLoginMetricsReporter {
    public static var fake: LoginMetricsReporterProtocol {
        FakeLoginMetricsReporter()
    }
}

public class FakeLoginMetricsReporter: LoginMetricsReporterProtocol {
    public func markAsLoadingSessionFromSavedLogin() {}
    public func startLoginTimer(from loginType: AuthenticationType) {}
    public func startLoginTimer(from biometryType: Biometry) {}
    public func resetTimer(_ timer: LoginMetricsReporter.Timer) {}
    public func getPerformanceLogInfo(_ timer: LoginMetricsReporter.Timer) -> LoginPerformanceLogInfo? { return nil }
    public func refreshTimer(_ timer: LoginMetricsReporter.Timer) {}
    public func reset() {}
}
