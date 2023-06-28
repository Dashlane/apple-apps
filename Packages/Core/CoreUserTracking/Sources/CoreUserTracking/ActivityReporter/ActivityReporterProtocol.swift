import Foundation

public protocol ActivityReporterProtocol {

    func reportPageShown(_ page: @autoclosure @escaping @Sendable () -> Page)
    func report<Event: UserEventProtocol>(_ event: @autoclosure @escaping @Sendable () -> Event)
    func report<Event: AnonymousEventProtocol>(_ event: @autoclosure @escaping @Sendable () -> Event)
    func flush()
}

public struct FakeActivityReporter: ActivityReporterProtocol {
    public func reportPageShown(_ page: @autoclosure @escaping @Sendable () -> Page) {}
    public func report<Event: UserEventProtocol>(_ event: @autoclosure @escaping @Sendable () -> Event) {}
    public func report<Event: AnonymousEventProtocol>(_ event: @autoclosure @escaping @Sendable () -> Event) {}
    public func flush() {}
    public init() {}
}

public extension ActivityReporterProtocol where Self == FakeActivityReporter {
    static var fake: ActivityReporterProtocol {
        return FakeActivityReporter()
    }
}
