import Foundation

extension UserDeviceAPIClient.Devices {
  public struct UpdateDeviceInfo: APIRequest {
    public static let endpoint: Endpoint = "/devices/UpdateDeviceInfo"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      deviceInformation: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(deviceInformation: deviceInformation)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var updateDeviceInfo: UpdateDeviceInfo {
    UpdateDeviceInfo(api: api)
  }
}

extension UserDeviceAPIClient.Devices.UpdateDeviceInfo {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case deviceInformation = "deviceInformation"
    }

    public let deviceInformation: String

    public init(deviceInformation: String) {
      self.deviceInformation = deviceInformation
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(deviceInformation, forKey: .deviceInformation)
    }
  }
}

extension UserDeviceAPIClient.Devices.UpdateDeviceInfo {
  public typealias Response = Empty?
}
