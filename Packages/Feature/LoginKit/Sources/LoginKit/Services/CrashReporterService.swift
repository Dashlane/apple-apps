import Combine
import CoreSession
import DashTypes
import Foundation
import Sentry
import SwiftTreats

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
public class CrashReporterService: NSObject {

  @Published
  private var events: [Sentry.Event] = []

  @SharedUserDefault(key: "is_sentry_enabled", default: true)
  private var isSentryEnabled: Bool

  public init(target: BuildTarget) {
    super.init()

    guard isSentryEnabled else {
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
      options.beforeSend = { [weak self] event in
        event.exceptions?.forEach({ $0.sanitize() })
        self?.events.append(event)
        return event
      }
    }
  }

  @MainActor
  public func associate(to login: Login?) {
    SentrySDK.configureScope { @MainActor scope in
      scope.setUser(.init(login: login))
    }
  }

  public func enableSentry(_ isEnabled: Bool) {
    self.isSentryEnabled = isEnabled
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
