import DashTypes
import DashlaneAPI
import Foundation

public typealias DataLeakRegisterResponse = UserDeviceAPIClient.Darkwebmonitoring.RegisterEmail
  .Response
public typealias DataLeakUnregisterResponse = UserDeviceAPIClient.Darkwebmonitoring.DeregisterEmail
  .Response
public typealias DataLeakStatusResponse = UserDeviceAPIClient.Darkwebmonitoring.ListRegistrations
  .Response
public typealias DataLeakLeaksResponse = UserDeviceAPIClient.Darkwebmonitoring.ListLeaks.Response
public typealias DataLeakMonitoringService = UserDeviceAPIClient.Darkwebmonitoring

extension DataLeakMonitoringService {
  public func listLeaks(lastUpdateDate: TimeInterval?) async throws -> DataLeakLeaksResponse {
    let lastUpdate: Int? =
      if let lastUpdateDate {
        Int(lastUpdateDate)
      } else {
        nil
      }
    return try await listLeaks(includeDisabled: true, lastUpdateDate: lastUpdate)
  }
}
