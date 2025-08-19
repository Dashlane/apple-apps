import Foundation

extension UserDeviceAPIClient.Devices {
  public struct DeactivateDevices: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/devices/DeactivateDevices"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      deviceIds: [String]? = nil, pairingGroupIds: [String]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(deviceIds: deviceIds, pairingGroupIds: pairingGroupIds)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deactivateDevices: DeactivateDevices {
    DeactivateDevices(api: api)
  }
}

extension UserDeviceAPIClient.Devices.DeactivateDevices {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case deviceIds = "deviceIds"
      case pairingGroupIds = "pairingGroupIds"
    }

    public let deviceIds: [String]?
    public let pairingGroupIds: [String]?

    public init(deviceIds: [String]? = nil, pairingGroupIds: [String]? = nil) {
      self.deviceIds = deviceIds
      self.pairingGroupIds = pairingGroupIds
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(deviceIds, forKey: .deviceIds)
      try container.encodeIfPresent(pairingGroupIds, forKey: .pairingGroupIds)
    }
  }
}

extension UserDeviceAPIClient.Devices.DeactivateDevices {
  public typealias Response = Empty?
}
