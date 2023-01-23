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
                    "CF-Access-Client-Id": info.cloudfareIdentifier,
                    "CF-Access-Client-Secret": info.cloudfareSecret
                ]
#endif
            }
        }
    }
}

extension LegacyWebServiceImpl.Configuration.Environment {
    public struct StagingInformation {
                let apiLegacyURL: URL
                let cloudfareIdentifier: String
                let cloudfareSecret: String
        
        public init(apiLegacyURL: URL, cloudfareIdentifier: String, cloudfareSecret: String) {
            self.apiLegacyURL = apiLegacyURL
            self.cloudfareIdentifier = cloudfareIdentifier
            self.cloudfareSecret = cloudfareSecret
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
