import Foundation

public protocol ActivityReporterProtocol {

  func reportPageShown(_ page: @autoclosure @escaping @Sendable () -> Page)
  func report<Event: UserEventProtocol>(_ event: @autoclosure @escaping @Sendable () -> Event)
  func report<Event: AnonymousEventProtocol>(_ event: @autoclosure @escaping @Sendable () -> Event)
  func flush()
}

public class ActivityReporterMock: ActivityReporterProtocol {

  public private(set) var pageStore: [Page] = []
  public private(set) var eventsStore: [EventProtocol] = []

  public func reportPageShown(_ page: @autoclosure @escaping @Sendable () -> Page) {
    pageStore.append(page())
  }

  public func report<Event: UserEventProtocol>(
    _ event: @autoclosure @escaping @Sendable () -> Event
  ) {
    eventsStore.append(event())
  }

  public func report<Event: AnonymousEventProtocol>(
    _ event: @autoclosure @escaping @Sendable () -> Event
  ) {
    eventsStore.append(event())
  }

  public func flush() {
    pageStore = []
    eventsStore = []
  }

  public init() {

  }
}

extension ActivityReporterProtocol where Self == ActivityReporterMock {
  public static var mock: ActivityReporterMock {
    return ActivityReporterMock()
  }
}
