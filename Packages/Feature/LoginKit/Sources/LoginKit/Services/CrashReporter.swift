import Combine
import CoreSession
import CoreTypes
import Foundation
import Sentry
import SwiftTreats

@MainActor
public protocol CrashReporter: AnyObject {
  func setEnabled(_ enabled: Bool)
  func configureScope(for session: Session, loadingContext: SessionLoadingContext)
  func resetScope()
}

public class SentryCrashReporter: CrashReporter {
  enum SessionTagKey: String, CaseIterable {
    case accountType
    case loadingContext
  }

  enum SessionExtraKey: String, CaseIterable {
    case otp2
    case loginMode
  }

  @Published
  private var events: [Sentry.Event] = []

  @SharedUserDefault(key: "is_sentry_enabled", default: true)
  public var isEnabled: Bool

  public init(target: BuildTarget) {
    guard isEnabled else {
      return
    }

    guard BuildEnvironment.current != .debug else {
      return
    }

    let key: String
    key = ApplicationSecrets.Sentry.passwordManagerKey

    startSentry(key: key)
  }

  private func startSentry(key: String) {
    SentrySDK.start { [weak self] options in
      options.dsn = key

      options.enableSwizzling = false
      options.enableNetworkTracking = false
      options.enableNetworkBreadcrumbs = false
      options.enableUIViewControllerTracing = false
      options.enableUserInteractionTracing = false
      options.enableAppHangTracking = false
      options.enableAutoBreadcrumbTracking = false
      options.enableAutoPerformanceTracing = false
      options.enableWatchdogTerminationTracking = false
      options.environment = Application.environment.rawValue
      options.initialScope = { (scope: Scope) in
        scope.setTag(value: "\(Device.kind)", key: "device")

        return scope
      }
      options.beforeSend = { [weak self] event in
        event.exceptions?.forEach({ $0.sanitize() })
        self?.events.append(event)
        return event
      }
    }
  }

  public func setEnabled(_ enabled: Bool) {
    isEnabled = enabled
  }

  public func configureScope(for session: Session, loadingContext: SessionLoadingContext) {
    SentrySDK.configureScope { @MainActor scope in
      scope.setUser(.init(login: session.login))

      scope.setTag(
        value: "\(session.configuration.info.accountType)", key: SessionTagKey.accountType.rawValue)

      switch loadingContext {
      case .accountCreation:
        scope.setTag(value: "accountCreation", key: SessionTagKey.loadingContext.rawValue)

      case .localLogin(let origin, _):
        scope.setTag(value: "local", key: SessionTagKey.loadingContext.rawValue)
        switch origin {
        case let .regular(reportedLoginMode: mode):
          scope.setExtra(value: "\(mode)", key: SessionExtraKey.loginMode.rawValue)
        case .afterLogout:
          break
        }
      case .remoteLogin:
        scope.setTag(value: "remote", key: SessionTagKey.loadingContext.rawValue)
      }

      if let option = session.configuration.info.loginOTPOption {
        scope.setExtra(value: option.rawValue, key: SessionExtraKey.otp2.rawValue)
      }
    }
  }

  public func resetScope() {
    SentrySDK.configureScope { @MainActor scope in
      scope.setUser(nil)

      SessionTagKey.allCases.forEach { key in
        scope.removeTag(key: key.rawValue)
      }

      SessionExtraKey.allCases.forEach { key in
        scope.removeExtra(key: key.rawValue)
      }
    }
  }
}

extension Sentry.User {
  fileprivate convenience init?(login: Login?) {
    guard let login = login else {
      return nil
    }
    self.init()

    ipAddress = ""
    if login.isTest || Application.environment == .internal {
      email = login.email
    } else if let hashedEmail = login.email.lowercased().sha512() {
      userId = hashedEmail
    } else {
      return nil
    }
  }
}

extension Sentry.Exception {
  fileprivate func sanitize() {
    self.value = self.value.sanitizedForUpload()
  }
}

extension String {
  fileprivate func sanitizedForUpload() -> String {
    guard let range = self.range(of: "Fatal error") else {
      return self
    }

    return String(self[range.lowerBound..<self.endIndex])
  }
}

extension Application {
  fileprivate static var environment: Environment {
    if self.version().starts(with: "70.") {
      return .qa
    } else if self.version().starts(with: "80.") {
      return .internal
    } else {
      return .production
    }
  }
}

private enum Environment: String {
  case production
  case qa
  case `internal`
}

public class FakeCrashReporter: CrashReporter {
  public var isEnabled: Bool = true

  public func setEnabled(_ enabled: Bool) {
    isEnabled = enabled
  }

  public func configureScope(for session: Session, loadingContext: SessionLoadingContext) {

  }

  public func resetScope() {

  }
}

extension CrashReporter where Self == FakeCrashReporter {
  public static var fake: FakeCrashReporter {
    return FakeCrashReporter()
  }
}
