import Combine
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats
import UserTrackingFoundation

public struct UserTrackingAppActivityReporter: ActivityReporterProtocol {
  let logEngine: UserTrackingLogEngine

  public var installationId: LowercasedUUID {
    logEngine.installationId
  }

  public init(
    logger: Logger,
    component: Definition.BrowseComponent,
    installationId: LowercasedUUID,
    localStorageURL: URL,
    cryptoEngine: CryptoEngine,
    appAPIClient: AppAPIClient,
    platform: Definition.Platform = .ios
  ) {
    self.logEngine = UserTrackingLogEngine(
      installationId: installationId,
      appAPIClient: appAPIClient,
      logger: logger,
      component: component,
      localStorageURL: localStorageURL,
      isTesting: BuildEnvironment.current != .appstore,
      cryptoEngine: cryptoEngine,
      platform: platform)

  }

  public func reportPageShown(_ page: @autoclosure @escaping @Sendable () -> Page) {
    Task.detached(priority: .utility) {
      await self.logEngine.reportPageShown(page(), using: nil)
    }
  }

  public func report<Event>(_ event: @autoclosure @escaping @Sendable () -> Event)
  where Event: UserEventProtocol {
    Task.detached(priority: .utility) {
      await self.logEngine.report(event(), using: nil)
    }
  }

  public func report<Event>(_ event: @autoclosure @escaping @Sendable () -> Event)
  where Event: AnonymousEventProtocol {
    Task.detached(priority: .utility) {
      await self.logEngine.report(event())
    }
  }

  public func flush() {
    Task.detached(priority: .medium) {
      await self.logEngine.flush()
    }
  }
}
