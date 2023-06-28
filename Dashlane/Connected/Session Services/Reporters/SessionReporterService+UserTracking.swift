import Foundation
import DashlaneAppKit
import CoreUserTracking

extension SessionReporterService: ActivityReporterProtocol {
    func report<Event>(_ event: @autoclosure @escaping @Sendable () -> Event) where Event: AnonymousEventProtocol {
        activityReporter.report(event())
    }

    func report<Event>(_ event: @autoclosure @escaping @Sendable () -> Event) where Event: UserEventProtocol {
        activityReporter.report(event())
    }

    func reportPageShown(_ page: @autoclosure @escaping @Sendable () -> Page) {
        activityReporter.reportPageShown(page())
    }

    func flush() {
        activityReporter.flush()
    }
}
