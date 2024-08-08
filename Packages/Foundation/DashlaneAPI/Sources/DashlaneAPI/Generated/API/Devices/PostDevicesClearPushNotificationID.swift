import Foundation

extension UserDeviceAPIClient.Devices {
  public struct ClearPushNotificationID: APIRequest {
    public static let endpoint: Endpoint = "/devices/ClearPushNotificationID"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(pushID: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(pushID: pushID)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var clearPushNotificationID: ClearPushNotificationID {
    ClearPushNotificationID(api: api)
  }
}

extension UserDeviceAPIClient.Devices.ClearPushNotificationID {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case pushID = "pushID"
    }

    public let pushID: String

    public init(pushID: String) {
      self.pushID = pushID
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(pushID, forKey: .pushID)
    }
  }
}

extension UserDeviceAPIClient.Devices.ClearPushNotificationID {
  public typealias Response = Empty?
}
