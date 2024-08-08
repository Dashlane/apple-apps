import Foundation

extension UserDeviceAPIClient.Devices {
  public struct SetPushNotificationID: APIRequest {
    public static let endpoint: Endpoint = "/devices/SetPushNotificationID"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      pushID: String, type: Body.`Type`, sendToAppboy: Bool, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(pushID: pushID, type: type, sendToAppboy: sendToAppboy)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var setPushNotificationID: SetPushNotificationID {
    SetPushNotificationID(api: api)
  }
}

extension UserDeviceAPIClient.Devices.SetPushNotificationID {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case pushID = "pushID"
      case type = "type"
      case sendToAppboy = "sendToAppboy"
    }

    public enum `Type`: String, Sendable, Equatable, CaseIterable, Codable {
      case google = "google"
      case ios = "ios"
      case mac = "mac"
      case macExtension = "mac_extension"
      case standaloneExtension = "standalone_extension"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let pushID: String
    public let type: `Type`
    public let sendToAppboy: Bool

    public init(pushID: String, type: `Type`, sendToAppboy: Bool) {
      self.pushID = pushID
      self.type = type
      self.sendToAppboy = sendToAppboy
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(pushID, forKey: .pushID)
      try container.encode(type, forKey: .type)
      try container.encode(sendToAppboy, forKey: .sendToAppboy)
    }
  }
}

extension UserDeviceAPIClient.Devices.SetPushNotificationID {
  public typealias Response = Empty?
}
