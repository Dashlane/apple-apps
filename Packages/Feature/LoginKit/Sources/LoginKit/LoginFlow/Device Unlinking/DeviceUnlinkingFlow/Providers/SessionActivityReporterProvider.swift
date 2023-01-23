import Foundation
import CoreUserTracking
import CoreSession
import DashTypes

public protocol SessionActivityReporterProvider {
    func makeSessionActivityReporter(for login: Login, analyticsId: AnalyticsIdentifiers) -> ActivityReporterProtocol
}
