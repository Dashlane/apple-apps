import Foundation
import CoreUserTracking
import CoreSession
import DashTypes

public protocol SessionActivityReporterProvider {
    func makeSessionActivityReporter(for login: Login, analyticsId: AnalyticsIdentifiers) -> ActivityReporterProtocol
}

struct FakeSessionActivityReporter: SessionActivityReporterProvider {
    public init() {}
    public func makeSessionActivityReporter(for login: Login, analyticsId: AnalyticsIdentifiers) -> ActivityReporterProtocol {
        FakeActivityReporter()
    }
}

public extension SessionActivityReporterProvider {
	static var mock: SessionActivityReporterProvider {
		FakeSessionActivityReporter()
	}
}
