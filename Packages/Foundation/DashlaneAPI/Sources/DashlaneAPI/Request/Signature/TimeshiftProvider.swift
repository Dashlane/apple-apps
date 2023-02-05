import Foundation

struct TimeshiftProvider {
    typealias Request = AppAPIClient.Time.GetRemoteTime
    struct TimeResponse: Codable {
        let timestamp: TimeInterval
    }

    let configuration: APIConfiguration
    let session: URLSession
    let decoder: JSONDecoder
    let additionalHeaders: [String: String]

    init(configuration: APIConfiguration,
         additionalHeaders: [String: String],
         session: URLSession,
         decoder: JSONDecoder,
         currentTimeshift: TimeInterval? = nil) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
        self.additionalHeaders = additionalHeaders
    }

    func fetch() async throws -> TimeInterval {
        var urlRequest = URLRequest(endpoint: Request.endpoint,
                                    configuration: configuration)
        urlRequest.setHeaders(additionalHeaders)

        let result: Request.Response = try await session.response(from: urlRequest, using: decoder)
        let timeshift = TimeInterval(result.timestamp)

        guard let bootTime = TimeInterval.currentKernelBootTime() else {
            let now = Date()
            return now.timeIntervalSince(Date(timeIntervalSince1970: timeshift))
        }

        let intervalBetweenBootTimeAndServer: TimeInterval = timeshift - bootTime

        return intervalBetweenBootTimeAndServer
    }
}

extension TimeInterval {
            static func currentKernelBootTime() -> TimeInterval? {
        var managementInformationBase = [CTL_KERN, KERN_BOOTTIME]
        var bootTime = timeval()
        var bootTimeSize: Int = MemoryLayout<timeval>.size
        guard sysctl(&managementInformationBase, UInt32(managementInformationBase.count), &bootTime, &bootTimeSize, nil, 0) != -1 else {
            assertionFailure("sysctl call failed")
            return nil
        }
        return Date().timeIntervalSince1970 - (TimeInterval(bootTime.tv_sec) + TimeInterval(bootTime.tv_usec) / 1_000_000.0)
    }
}
