public protocol RemoteLogger: Sendable {
  func configureReportedDeviceId(_ deviceId: String)
}

public final class RemoteLoggerMock: RemoteLogger {
  nonisolated(unsafe) var deviceId: String?
  public func configureReportedDeviceId(_ deviceId: String) {
    self.deviceId = deviceId
  }
}

extension RemoteLogger where Self == RemoteLoggerMock {
  public static var mock: RemoteLogger {
    RemoteLoggerMock()
  }
}
