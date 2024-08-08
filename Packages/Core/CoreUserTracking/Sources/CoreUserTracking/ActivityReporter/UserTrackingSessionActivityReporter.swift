import DashTypes
import Foundation

public struct UserTrackingSessionActivityReporter: ActivityReporterProtocol {

  let analyticsIdentifiers: AnalyticsIdentifiers?
  let logEngine: UserTrackingLogEngine

  public init(
    appReporter: UserTrackingAppActivityReporter,
    login: Login,
    analyticsIdentifiers: AnalyticsIdentifiers?
  ) {
    self.logEngine = appReporter.logEngine
    self.analyticsIdentifiers = analyticsIdentifiers
    configureEnvironment(using: login)
  }

  public func reportPageShown(_ page: @autoclosure @escaping @Sendable () -> Page) {
    Task.detached(priority: .utility) {
      await self.logEngine.reportPageShown(page(), using: self.analyticsIdentifiers)
    }
  }

  public func report<Event>(_ event: @autoclosure @escaping @Sendable () -> Event)
  where Event: UserEventProtocol {
    Task.detached(priority: .utility) {
      await self.logEngine.report(event(), using: self.analyticsIdentifiers)
    }
  }

  public func report<Event>(_ event: @autoclosure @escaping @Sendable () -> Event)
  where Event: AnonymousEventProtocol {
    Task.detached(priority: .utility) {
      await self.logEngine.report(event())
    }
  }

  public func flush() {
    Task.detached(priority: .utility) {
      await self.logEngine.flush()
    }
  }

  private nonisolated func configureEnvironment(using login: Login) {
    Task {
      await logEngine.configureEnvironment(
        isTest: BuildEnvironment.current != .appstore || login.isTest)
    }
  }
}
