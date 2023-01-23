import Foundation
import DashTypes
import Combine

public struct DomainIconInfoProvider: IconInfoProvider {
    public struct Request: IconLibraryRequest {
        public let domain: Domain
        public let format: DomainIconFormat

        public init(domain: Domain, format: DomainIconFormat) {
            self.domain = domain
            self.format = format
        }

        public var cacheKey: String {
            return "\(domain.name)-\(format.parameterValue)"
        }
    }

    let iconService: GetIconServiceProtocol

    public init(webservice: LegacyWebService, logger: Logger) {
        self.init(iconService: GetIconService(networkEngine: webservice, logger: logger))
    }

    init(iconService: GetIconServiceProtocol) {
        self.iconService = iconService
    }

    public func iconInfo(for request: Request) async throws -> (URL, IconColorSet?)? {
        let iconDescription = try await iconService.iconDescription(for: request.domain, format: request.format)
            .first { $0.type == request.format.parameterValue  }

        guard let url = iconDescription?.url else {
            return nil
        }

        let colors = IconColorSet(iconDescription: iconDescription)
        return (url, colors)
    }
}


@available(macOS 10.15, *)
public typealias DomainIconLibrary = IconLibrary<DomainIconInfoProvider>

public protocol DomainIconLibraryProtocol {
    func icon(for domain: Domain, format: DomainIconFormat) async throws -> Icon?
    @available(*, deprecated, message: "Use async instead method")
    func publisher(for request: DomainIconInfoProvider.Request, on queue: DispatchQueue) -> IconPublisher
}

extension DomainIconLibrary: DomainIconLibraryProtocol {
    public init(cacheDirectory: URL,
                            cacheValidationInterval: TimeInterval = DomainIconLibrary.defaultCacheValidationInterval,
                            cryptoEngine: CryptoEngine,
                            webservice: LegacyWebService,
                            logger: Logger) {

        self.init(cacheDirectory: cacheDirectory,
                  cacheValidationInterval: cacheValidationInterval,
                  cryptoEngine: cryptoEngine,
                  imageDownloader: FileDownloader(),
                  provider: DomainIconInfoProvider(webservice: webservice, logger: logger),
                  logger: logger)

    }


            public func icon(for domain: Domain, format: DomainIconFormat) async throws -> Icon? {
        let request = DomainIconInfoProvider.Request(domain: domain, format: format)
        return try await icon(for: request)
    }
}

public struct FakeDomainIconLibrary: DomainIconLibraryProtocol {
    public let icon: Icon?
    
    public init(icon: Icon?) {
        self.icon = icon
    }
    
    public func icon(for domain: Domain, format: DomainIconFormat) async throws -> Icon? {
        icon
    }
    
    public func publisher(for request: DomainIconInfoProvider.Request, on queue: DispatchQueue) -> IconPublisher {
        Just(icon).eraseToAnyPublisher()
    }
}
