import Foundation
import DashTypes

public extension LegacyWebServiceImpl {
    struct Configuration {

        let platform: Platform
        let environment: Environment

        public init(platform: Platform, environment: LegacyWebServiceImpl.Configuration.Environment = .default) {
            self.platform = platform
            self.environment = environment
        }
    }
}

extension LegacyWebServiceImpl.Configuration {
    public enum Environment {
        case production
#if DEBUG
                case staging(StagingInformation)
#endif

        var apiLegacyURL: URL {
            switch self {
            case .production:
                return URL(string: "_")!
#if DEBUG
            case let .staging(info):
                return info.apiLegacyURL
#endif
            }
        }

        var additionalHeaders: [String: String] {
            switch self {
            case .production:
                                return [:]
#if DEBUG
            case let .staging(info):
                return [
                    "CF-Access-Client-Id": info.cloudflareIdentifier,
                    "CF-Access-Client-Secret": info.cloudflareSecret
                ]
#endif
            }
        }
    }
}

extension LegacyWebServiceImpl.Configuration.Environment {
    public struct StagingInformation {
                let apiLegacyURL: URL
                let cloudflareIdentifier: String
                let cloudflareSecret: String

        public init(apiLegacyURL: URL, cloudflareIdentifier: String, cloudflareSecret: String) {
            self.apiLegacyURL = apiLegacyURL
            self.cloudflareIdentifier = cloudflareIdentifier
            self.cloudflareSecret = cloudflareSecret
        }

    }
}

extension URLRequest {
    mutating func addAdditionalHeaders(from information: LegacyWebServiceImpl.Configuration) {
        information.environment.additionalHeaders.forEach {
            addValue($0.value, forHTTPHeaderField: $0.key)
        }
    }
}
