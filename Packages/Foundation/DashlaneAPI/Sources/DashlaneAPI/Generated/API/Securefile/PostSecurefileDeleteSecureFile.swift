import Foundation

extension UserDeviceAPIClient.Securefile {
  public struct DeleteSecureFile: APIRequest {
    public static let endpoint: Endpoint = "/securefile/DeleteSecureFile"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(secureFileInfoId: String, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(secureFileInfoId: secureFileInfoId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deleteSecureFile: DeleteSecureFile {
    DeleteSecureFile(api: api)
  }
}

extension UserDeviceAPIClient.Securefile.DeleteSecureFile {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case secureFileInfoId = "secureFileInfoId"
    }

    public let secureFileInfoId: String

    public init(secureFileInfoId: String) {
      self.secureFileInfoId = secureFileInfoId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(secureFileInfoId, forKey: .secureFileInfoId)
    }
  }
}

extension UserDeviceAPIClient.Securefile.DeleteSecureFile {
  public typealias Response = SecurefileSecureFileResponse
}
