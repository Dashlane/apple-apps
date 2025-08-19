import Foundation

extension UserDeviceAPIClient.Securefile {
  public struct GetUploadLink: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/securefile/GetUploadLink"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      contentLength: Int, secureFileInfoId: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(contentLength: contentLength, secureFileInfoId: secureFileInfoId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getUploadLink: GetUploadLink {
    GetUploadLink(api: api)
  }
}

extension UserDeviceAPIClient.Securefile.GetUploadLink {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case contentLength = "contentLength"
      case secureFileInfoId = "secureFileInfoId"
    }

    public let contentLength: Int
    public let secureFileInfoId: String

    public init(contentLength: Int, secureFileInfoId: String) {
      self.contentLength = contentLength
      self.secureFileInfoId = secureFileInfoId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(contentLength, forKey: .contentLength)
      try container.encode(secureFileInfoId, forKey: .secureFileInfoId)
    }
  }
}

extension UserDeviceAPIClient.Securefile.GetUploadLink {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case url = "url"
      case fields = "fields"
      case key = "key"
      case quota = "quota"
      case acl = "acl"
    }

    public let url: String
    public let fields: [String: String]
    public let key: String
    public let quota: SecurefileQuota
    public let acl: String

    public init(
      url: String, fields: [String: String], key: String, quota: SecurefileQuota, acl: String
    ) {
      self.url = url
      self.fields = fields
      self.key = key
      self.quota = quota
      self.acl = acl
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(url, forKey: .url)
      try container.encode(fields, forKey: .fields)
      try container.encode(key, forKey: .key)
      try container.encode(quota, forKey: .quota)
      try container.encode(acl, forKey: .acl)
    }
  }
}
