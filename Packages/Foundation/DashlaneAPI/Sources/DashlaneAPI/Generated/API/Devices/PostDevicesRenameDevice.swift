import Foundation

extension UserDeviceAPIClient.Devices {
  public struct RenameDevice: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/devices/RenameDevice"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      accessKey: String, updatedName: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(accessKey: accessKey, updatedName: updatedName)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var renameDevice: RenameDevice {
    RenameDevice(api: api)
  }
}

extension UserDeviceAPIClient.Devices.RenameDevice {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case accessKey = "accessKey"
      case updatedName = "updatedName"
    }

    public let accessKey: String
    public let updatedName: String

    public init(accessKey: String, updatedName: String) {
      self.accessKey = accessKey
      self.updatedName = updatedName
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(accessKey, forKey: .accessKey)
      try container.encode(updatedName, forKey: .updatedName)
    }
  }
}

extension UserDeviceAPIClient.Devices.RenameDevice {
  public typealias Response = Empty?
}
