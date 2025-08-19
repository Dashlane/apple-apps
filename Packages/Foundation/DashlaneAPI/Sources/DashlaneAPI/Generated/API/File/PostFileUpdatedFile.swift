import Foundation

extension AppAPIClient.File {
  public struct UpdatedFile: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/file/UpdatedFile"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      fileName: String, url: String, revision: Int, signature: String, encryptionKey: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        fileName: fileName, url: url, revision: revision, signature: signature,
        encryptionKey: encryptionKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var updatedFile: UpdatedFile {
    UpdatedFile(api: api)
  }
}

extension AppAPIClient.File.UpdatedFile {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case fileName = "fileName"
      case url = "url"
      case revision = "revision"
      case signature = "signature"
      case encryptionKey = "encryptionKey"
    }

    public let fileName: String
    public let url: String
    public let revision: Int
    public let signature: String
    public let encryptionKey: String?

    public init(
      fileName: String, url: String, revision: Int, signature: String, encryptionKey: String? = nil
    ) {
      self.fileName = fileName
      self.url = url
      self.revision = revision
      self.signature = signature
      self.encryptionKey = encryptionKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(fileName, forKey: .fileName)
      try container.encode(url, forKey: .url)
      try container.encode(revision, forKey: .revision)
      try container.encode(signature, forKey: .signature)
      try container.encodeIfPresent(encryptionKey, forKey: .encryptionKey)
    }
  }
}

extension AppAPIClient.File.UpdatedFile {
  public typealias Response = Empty?
}
