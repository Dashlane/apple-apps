import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats
import UserTrackingFoundation

actor UserTrackingLogEngine {

  let installationId: LowercasedUUID
  let styxAPIClient: StyxDataAPIClient
  let logger: Logger
  var userTrackingSessionProvider = UserTrackingSessionProvider()
  let userTrackingLocalStore: ActivityReportsLocalStore
  let component: Definition.BrowseComponent
  let platform: Definition.Platform

  lazy var userEventsEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()

  lazy var anonymousEventsEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    encoder.dateEncodingStrategy = .formatted(dateFormatter)
    return encoder
  }()
  private var isTestEnvironment: Bool
  private var lastPageShown: Page?

  private let flushQueue = AsyncSerialQueue()

  public init(
    installationId: LowercasedUUID,
    appAPIClient: AppAPIClient,
    logger: Logger,
    component: Definition.BrowseComponent,
    localStorageURL: URL,
    isTesting: Bool,
    cryptoEngine: CryptoEngine,
    platform: Definition.Platform
  ) {
    let styxAPIClient = appAPIClient.makeStyxDataClient(
      credentials: .init(
        accessKey: ApplicationSecrets.Analytics.apiKey,
        secretKey: ApplicationSecrets.Analytics.apiSecret))
    self.init(
      installationId: installationId,
      styxAPIClient: styxAPIClient,
      logger: logger,
      component: component,
      localStorageURL: localStorageURL,
      isTesting: isTesting,
      cryptoEngine: cryptoEngine,
      platform: platform)
  }

  internal init(
    installationId: LowercasedUUID,
    styxAPIClient: StyxDataAPIClient,
    logger: Logger,
    component: Definition.BrowseComponent,
    localStorageURL: URL,
    isTesting: Bool,
    cryptoEngine: CryptoEngine,
    platform: Definition.Platform
  ) {
    self.isTestEnvironment = isTesting
    self.installationId = installationId
    self.styxAPIClient = styxAPIClient
    self.logger = logger
    self.component = component
    self.userTrackingLocalStore = ActivityReportsLocalStore(
      workingDirectory: localStorageURL,
      cryptoEngine: cryptoEngine,
      component: component,
      batchLogs: true)
    self.platform = platform

    logger.info("User Tracking Installation Id: \(installationId)")
  }

  public func reportPageShown(_ newPage: Page, using analyticsIds: AnalyticsIdentifiers?) async {

    guard lastPageShown != newPage else { return }
    userTrackingSessionProvider.refreshSession()

    let browse = Definition.Browse(
      component: self.component,
      originComponent: nil,
      originPage: self.lastPageShown,
      page: newPage)
    lastPageShown = newPage

    let session = userTrackingSessionProvider.fetchSession()
    let userReport = Report.User(
      event: UserEvent.ViewPage(),
      installationId: self.installationId,
      analyticsId: analyticsIds,
      navigationState: browse,
      session: session,
      platform: self.platform)
    await self.store(
      report: userReport,
      category: .user,
      encodingWith: self.userEventsEncoder,
      shouldFlush: newPage.isPriority)
    logger.info("User Tracking: Page View: \(newPage)")
  }

  public func report<Event: UserEventProtocol>(
    _ event: Event, using analyticsIds: AnalyticsIdentifiers?
  ) async {

    let browse = Definition.Browse(originComponent: component, originPage: lastPageShown)
    let session = userTrackingSessionProvider.fetchSession()

    let userReport = Report.User(
      event: event,
      installationId: installationId,
      analyticsId: analyticsIds,
      navigationState: browse,
      session: session,
      platform: platform)
    await store(
      report: userReport,
      category: .user,
      encodingWith: userEventsEncoder,
      shouldFlush: Event.isPriority)
  }

  public func report<Event: AnonymousEventProtocol>(_ event: Event) async {
    let anonymousReport = Report.Anonymous(
      event: event,
      platform: platform)
    await store(
      report: anonymousReport,
      category: .anonymous,
      encodingWith: anonymousEventsEncoder,
      shouldFlush: Event.isPriority)
  }

  private func store<Report: Encodable>(
    report: Report, category: LogCategory, encodingWith encoder: JSONEncoder, shouldFlush: Bool
  ) async {

    do {
      let data = try encoder.encode(report)
      try await userTrackingLocalStore.store(data, category: category)
    } catch {
      logger.error("can't encode User Tracking report", error: error)
    }
    if shouldFlush || isTestEnvironment {
      await flush()
    }
  }

  public func flush() async {
    try? await flushQueue {
      await self.flushLogs(for: .anonymous)
      await self.flushLogs(for: .user)
    }
  }

  public func configureEnvironment(isTest: Bool) {
    self.isTestEnvironment = isTest
  }

  private func flushLogs(for category: LogCategory) async {
    do {
      let storedLogEntries = try await userTrackingLocalStore.fetchEntries(max: 100, of: category)
      guard !storedLogEntries.isEmpty else {
        return
      }
      let entries = storedLogEntries.map({ $0.data })
      guard !entries.isEmpty else { return }
      let encodedData = try JSONLinesEncoder().encode(entries)
      try await styxAPIClient.sendEvents(
        encodedData, for: category, isTestEnvironment: isTestEnvironment)
      await userTrackingLocalStore.delete(storedLogEntries)
    } catch {
      logger.error("Flush failed", error: error)
    }
  }
}

extension Report.Anonymous {

  fileprivate init(event: Event, platform: Definition.Platform) {
    let context = Definition.ContextAnonymous(
      app: .init(
        buildType: BuildEnvironment.current.buildType,
        platform: platform, version: Application.version()),
      browser: nil,
      os: .init(
        locale: System.languageCountry,
        type: .current,
        version: System.version))
    self.init(
      context: context,
      date: Date(),
      dateOrigin: .local,
      id: LowercasedUUID(),
      properties: event)

  }

}

extension Report.User {

  fileprivate init(
    event: Event,
    installationId: LowercasedUUID,
    analyticsId: AnalyticsIdentifiers?,
    navigationState: Definition.Browse,
    session: Definition.Session?,
    platform: Definition.Platform
  ) {

    let context = Definition.Context(
      app: .init(
        buildType: BuildEnvironment.current.buildType,
        platform: platform,
        version: Application.version()),
      browser: nil,
      device: .init(installationId: installationId, analyticsId: analyticsId),
      user: .init(analyticsId: analyticsId))

    self.init(
      browse: navigationState,
      context: context,
      date: Date(),
      dateOrigin: .local,
      id: LowercasedUUID(),
      session: session,
      properties: event)
  }
}

extension Definition.User {
  fileprivate init?(analyticsId: AnalyticsIdentifiers?) {
    guard let analyticsId = analyticsId,
      let analyticsUserId = LowercasedUUID(uuidString: analyticsId.user)
    else {
      return nil
    }
    self.init(id: analyticsUserId)
  }
}

extension Definition.Device {
  fileprivate init(installationId: LowercasedUUID, analyticsId: AnalyticsIdentifiers?) {
    let analyticsDeviceId: LowercasedUUID? = analyticsId.flatMap {
      LowercasedUUID(uuidString: $0.device)
    }

    self.init(
      id: analyticsDeviceId,
      installationId: installationId,
      os: .init(
        locale: System.languageCountry,
        type: .current,
        version: System.version))

  }
}
