import Foundation

extension UserDeviceAPIClient.Securefile {
  public struct CommitSecureFile: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/securefile/CommitSecureFile"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(key: String, secureFileInfoId: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(key: key, secureFileInfoId: secureFileInfoId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var commitSecureFile: CommitSecureFile {
    CommitSecureFile(api: api)
  }
}

extension UserDeviceAPIClient.Securefile.CommitSecureFile {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case key = "key"
      case secureFileInfoId = "secureFileInfoId"
    }

    public let key: String
    public let secureFileInfoId: String

    public init(key: String, secureFileInfoId: String) {
      self.key = key
      self.secureFileInfoId = secureFileInfoId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(key, forKey: .key)
      try container.encode(secureFileInfoId, forKey: .secureFileInfoId)
    }
  }
}

extension UserDeviceAPIClient.Securefile.CommitSecureFile {
  public typealias Response = SecurefileSecureFileResponse
}
