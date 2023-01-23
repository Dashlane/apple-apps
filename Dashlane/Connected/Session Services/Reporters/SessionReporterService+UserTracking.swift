import Foundation
import DashlaneAppKit
import CoreUserTracking

extension SessionReporterService: ActivityReporterProtocol {
    func report<Event>(_ event: Event) where Event: AnonymousEventProtocol {
        activityReporter.report(event)
    }

    func report<Event>(_ event: Event) where Event: UserEventProtocol {
        activityReporter.report(event)
    }

    func reportPageShown(_ page: Page) {
        activityReporter.reportPageShown(page)
    }

    func flush() {
        activityReporter.flush()
    }
}
