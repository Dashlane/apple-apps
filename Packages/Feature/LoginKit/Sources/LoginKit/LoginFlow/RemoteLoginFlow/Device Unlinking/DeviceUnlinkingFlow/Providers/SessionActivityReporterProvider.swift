import CoreSession
import CoreTypes
import Foundation
import UserTrackingFoundation

public protocol SessionActivityReporterProvider {
  func makeSessionActivityReporter(for login: Login, analyticsId: AnalyticsIdentifiers)
    -> ActivityReporterProtocol
}

public struct SessionActivityReporterMock: SessionActivityReporterProvider {
  public init() {}
  public func makeSessionActivityReporter(for login: Login, analyticsId: AnalyticsIdentifiers)
    -> ActivityReporterProtocol
  {
    ActivityReporterMock()
  }
}

extension SessionActivityReporterProvider where Self == SessionActivityReporterMock {
  public static var mock: SessionActivityReporterProvider {
    SessionActivityReporterMock()
  }
}
