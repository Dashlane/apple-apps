import CoreUserTracking
import Foundation

public enum AuthenticationType {
  case masterPassword
  case faceId
  case touchId
  case pinCode

  public var logValue: String {
    switch self {
    case .masterPassword:
      return "mp"
    case .faceId, .touchId:
      return "biometric"
    case .pinCode:
      return "pin"
    }
  }
}

public struct LoginPerformanceLogInfo {

  public enum PerformanceLogType {
    case timeToLogin(authType: AuthenticationType)
    case timeToAppReady
  }

  public let duration: Int
  public let performanceLogType: PerformanceLogType

  public func performanceUserEvent(for measureName: Definition.MeasureName) -> UserEvent.Performance
  {
    .init(
      measureName: measureName,
      measureType: .duration,
      unit: .milliseconds,
      value: Double(duration))
  }
}
