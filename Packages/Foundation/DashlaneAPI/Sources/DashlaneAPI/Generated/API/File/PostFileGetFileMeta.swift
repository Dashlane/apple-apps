import Foundation

extension UserDeviceAPIClient.File {
  public struct GetFileMeta: APIRequest {
    public static let endpoint: Endpoint = "/file/GetFileMeta"

    public let api: UserDeviceAPIClient

    @available(*, deprecated, message: "Deprecated in Spec")
    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @available(*, deprecated, message: "Deprecated in Spec")
    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getFileMeta: GetFileMeta {
    GetFileMeta(api: api)
  }
}

extension UserDeviceAPIClient.File.GetFileMeta {
  public typealias Body = [String: Int]
}

extension UserDeviceAPIClient.File.GetFileMeta {
  public struct ResponseValue: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case status = "status"
      case key = "key"
      case revision = "revision"
      case signature = "signature"
      case url = "url"
    }

    public enum Status: String, Sendable, Equatable, CaseIterable, Codable {
      case updateAvailable = "update_available"
      case notUpdated = "not_updated"
      case notFound = "not_found"
      case unknownRevision = "unknown_revision"
      case unspecifiedError = "unspecified_error"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let status: Status
    public let key: String?
    public let revision: Int?
    public let signature: String?
    public let url: String?

    public init(
      status: Status, key: String? = nil, revision: Int? = nil, signature: String? = nil,
      url: String? = nil
    ) {
      self.status = status
      self.key = key
      self.revision = revision
      self.signature = signature
      self.url = url
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(status, forKey: .status)
      try container.encodeIfPresent(key, forKey: .key)
      try container.encodeIfPresent(revision, forKey: .revision)
      try container.encodeIfPresent(signature, forKey: .signature)
      try container.encodeIfPresent(url, forKey: .url)
    }
  }
  public typealias Response = [String: ResponseValue]
}
