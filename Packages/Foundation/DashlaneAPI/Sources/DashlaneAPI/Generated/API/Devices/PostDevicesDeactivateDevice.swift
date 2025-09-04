import Foundation

extension UserDeviceAPIClient.Devices {
  public struct DeactivateDevice: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/devices/DeactivateDevice"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(deviceId: String, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(deviceId: deviceId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deactivateDevice: DeactivateDevice {
    DeactivateDevice(api: api)
  }
}

extension UserDeviceAPIClient.Devices.DeactivateDevice {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case deviceId = "deviceId"
    }

    public let deviceId: String

    public init(deviceId: String) {
      self.deviceId = deviceId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(deviceId, forKey: .deviceId)
    }
  }
}

extension UserDeviceAPIClient.Devices.DeactivateDevice {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case status = "status"
    }

    public let status: String?

    public init(status: String? = nil) {
      self.status = status
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(status, forKey: .status)
    }
  }
}
