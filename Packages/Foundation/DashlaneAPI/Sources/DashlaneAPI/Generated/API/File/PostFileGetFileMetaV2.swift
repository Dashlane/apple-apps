import Foundation

extension UserDeviceAPIClient.File {
  public struct GetFileMetaV2: APIRequest {
    public static let endpoint: Endpoint = "/file/GetFileMetaV2"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(files: [String: Int], timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(files: files)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getFileMetaV2: GetFileMetaV2 {
    GetFileMetaV2(api: api)
  }
}

extension UserDeviceAPIClient.File.GetFileMetaV2 {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case files = "files"
    }

    public let files: [String: Int]

    public init(files: [String: Int]) {
      self.files = files
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(files, forKey: .files)
    }
  }
}

extension UserDeviceAPIClient.File.GetFileMetaV2 {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case fileInfos = "fileInfos"
    }

    public struct FileInfosValue: Codable, Equatable, Sendable {
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

    public let fileInfos: [String: FileInfosValue]

    public init(fileInfos: [String: FileInfosValue]) {
      self.fileInfos = fileInfos
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(fileInfos, forKey: .fileInfos)
    }
  }
}
