import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol OpenAPISpecClient {
  static var specDefinedServerURL: URL { get }
}

public struct ClientConfiguration<Client: OpenAPISpecClient>: Sendable {
  public let info: ClientInfo
  public let environment: Environment
  public let defaultTimeout: TimeInterval
  public let additionalHeaders: [String: String]

  public init(
    info: ClientInfo,
    environment: Environment = .production,
    defaultTimeout: TimeInterval = 60
  ) throws {
    self.info = info
    self.environment = environment
    self.defaultTimeout = defaultTimeout
    self.additionalHeaders = try Self.makeAdditionalHeaders(info: info, environment: environment)
  }
}

public struct ClientInfo: Sendable {
  let platform: String
  let appVersion: String
  let osVersion: String
  let partner: String = "dashlane"
  let partnerId: String
  let language: String = Locale.current.identifier

  public init(platform: String, appVersion: String, osVersion: String, partnerId: String) {
    self.platform = platform
    self.appVersion = appVersion
    self.osVersion = osVersion
    self.partnerId = partnerId
  }
}

extension ClientInfo {
  static let mock = ClientInfo(
    platform: "server_iphone",
    appVersion: "1",
    osVersion: "2",
    partnerId: "id")
}

public struct StagingInformation: Sendable {
  let apiURL: URL
  let cloudflareIdentifier: String
  let cloudflareSecret: String

  public init(apiURL: URL, cloudflareIdentifier: String, cloudflareSecret: String) {
    self.apiURL = apiURL
    self.cloudflareIdentifier = cloudflareIdentifier
    self.cloudflareSecret = cloudflareSecret
  }
}

struct DashlaneClientAgent: Encodable {
  let version: String
  let platform: String
  let osversion: String
  let partner: String
  let language: String

  init(info: ClientInfo) {
    version = info.appVersion
    platform = info.platform
    osversion = info.osVersion
    partner = info.partner
    language = info.language
  }
}

extension ClientConfiguration {
  public enum Environment: Sendable {
    case production
    #if DEBUG || NIGHTLY
      case staging(StagingInformation)
    #endif
  }
}

extension ClientConfiguration.Environment {
  var apiURL: URL {
    switch self {
    case .production:
      return Client.specDefinedServerURL
    #if DEBUG || NIGHTLY
      case let .staging(info):
        return info.apiURL
    #endif
    }
  }
}

extension URLRequest {
  init(
    endpoint: String,
    timeoutInterval: TimeInterval? = nil,
    configuration: ClientConfiguration<some OpenAPISpecClient>
  ) {
    let url = configuration.environment.apiURL.appendingPathComponent(endpoint)

    self.init(
      url: url,
      cachePolicy: .reloadIgnoringCacheData,
      timeoutInterval: timeoutInterval ?? configuration.defaultTimeout)

    setValue(url.hostWithPort, forHTTPHeaderField: "Host")
    setHeaders(configuration.additionalHeaders)
  }
}

extension ClientConfiguration {

  static func makeAdditionalHeaders(
    info: ClientInfo, environment: ClientConfiguration<some OpenAPISpecClient>.Environment
  ) throws -> [String: String] {
    let headers = [
      "dashlane-client-agent": try JSONEncoder().encodeString(DashlaneClientAgent(info: info))
    ]

    switch environment {
    case .production:
      return headers
    #if DEBUG || NIGHTLY
      case let .staging(info):
        let cloudflare = [
          "CF-Access-Client-Id": info.cloudflareIdentifier,
          "CF-Access-Client-Secret": info.cloudflareSecret,
        ]
        return headers.merging(cloudflare) { left, _ in return left }
    #endif
    }
  }
}

extension JSONEncoder {
  func encodeString<T: Encodable>(_ value: T) throws -> String {
    let data = try encode(value)
    return String(data: data, encoding: .utf8)!
  }
}
