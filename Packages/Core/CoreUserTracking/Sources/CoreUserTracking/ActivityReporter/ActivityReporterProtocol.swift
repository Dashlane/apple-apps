import Foundation

public protocol ActivityReporterProtocol {

    func reportPageShown(_ page: Page)
    func report<Event: UserEventProtocol>(_ event: Event)
    func report<Event: AnonymousEventProtocol>(_ event: Event)
    func flush()
}

public struct FakeActivityReporter: ActivityReporterProtocol {
    public func report<Event>(_ event: Event) where Event : AnonymousEventProtocol { }
    public func reportPageShown(_ page: Page) {}
    public func report<Event>(_ event: Event) where Event : UserEventProtocol {}
    public func flush() {}
    public init() {}
}

public extension ActivityReporterProtocol where Self == FakeActivityReporter {
    static var fake: ActivityReporterProtocol {
        return FakeActivityReporter()
    }
}
