import Foundation
import SwiftUI
import DashTypes

public struct ReportAction {
    let reporter: ActivityReporterProtocol

    public init(reporter: ActivityReporterProtocol) {
        self.reporter = reporter
    }

    public func callAsFunction(_ page: Page) {
        reporter.reportPageShown(page)
    }

    public func callAsFunction<Event: AnonymousEventProtocol>(_ event: Event) {
        reporter.report(event)
    }

    public func callAsFunction<Event: UserEventProtocol>(_ event: Event) {
        reporter.report(event)
    }
}

@MainActor
public struct ReportActionKey: EnvironmentKey {
        public static let defaultValue: ReportAction? = nil
}

extension GlobalEnvironmentValues {
    public var report: ReportAction? {
        get {
            return self[ReportActionKey.self]
        } set {
            self[ReportActionKey.self] = newValue
        }
    }
}

extension EnvironmentValues {
    public var report: ReportAction? {
        get {
            return self[ReportActionKey.self]
        } set {
            self[ReportActionKey.self] = newValue
        }
    }
}
