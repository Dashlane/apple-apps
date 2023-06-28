import Foundation

public struct APIConfiguration {
    public let info: Info
    public let environment: Environment
    public let defaultTimeout: TimeInterval
    public let additionalHeaders: [String: String]

    public init(info: Info,
                environment: Environment = .production,
                defaultTimeout: TimeInterval = 60) throws {
        self.info = info
        self.environment = environment
        self.defaultTimeout = defaultTimeout
        self.additionalHeaders = try Self.makeAdditionalHeaders(info: info, environment: environment)
    }
}

extension APIConfiguration {
    public struct Info {
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
}

extension APIConfiguration {
    public enum Environment {
        case production
#if DEBUG
                case staging(StagingInformation)
#endif
    }
}

extension APIConfiguration.Environment {
    var apiURL: URL {
        switch self {
        case .production:
            return Self.specURL
#if DEBUG
        case let .staging(info):
            return info.apiURL
#endif
        }
    }
}

public struct StagingInformation {
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

    init(info: APIConfiguration.Info) {
        version = info.appVersion
        platform = info.platform
        osversion = info.osVersion
        partner = info.partner
        language = info.language
    }
}

extension APIConfiguration {

    static func makeAdditionalHeaders(info: APIConfiguration.Info, environment: Environment) throws -> [String: String] {
        let headers =  [
            "dashlane-client-agent": try JSONEncoder().encodeString(DashlaneClientAgent(info: info))
        ]

        switch environment {
        case .production:
            return headers
#if DEBUG
        case let .staging(info):
            let cloudflare =  [
                "CF-Access-Client-Id": info.cloudflareIdentifier,
                "CF-Access-Client-Secret": info.cloudflareSecret
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

extension APIConfiguration.Info {
    static var mock = APIConfiguration.Info(platform: "server_iphone", appVersion: "1", osVersion: "2", partnerId: "id")
}
