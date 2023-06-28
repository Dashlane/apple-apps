import Foundation

public enum NitroEnvironment {
    public static let specURL = URL(string: "_")!

    case production
#if DEBUG
        case staging(StagingInformation)
#endif

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

extension URLRequest {

    init(endpoint: String,
         timeoutInterval: TimeInterval? = nil,
         environment: NitroEnvironment,
         additionalHeaders: [String: String]) {
        let url = environment.apiURL.appendingPathComponent(endpoint)

        self.init(url: url,
                  cachePolicy: .reloadIgnoringCacheData,
                  timeoutInterval: timeoutInterval ?? 60)

        setValue(url.hostWithPort, forHTTPHeaderField: "Host")
        setHeaders(additionalHeaders)
    }
}
