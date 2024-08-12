import Combine
import DashTypes
import DashlaneAPI
import Foundation

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

  let appAPIClient: AppAPIClient
  let logger: Logger

  public init(appAPIClient: AppAPIClient, logger: Logger) {
    self.appAPIClient = appAPIClient
    self.logger = logger
  }

  public func iconInfo(for request: Request) async throws -> (URL, IconColorSet?)? {
    do {
      let iconDescription = try await appAPIClient.iconcrawler
        .getIcons(domainsInfo: [
          .init(domain: request.domain.name, type: request.format.parameterValue)
        ]).icons.first {
          $0.type == request.format.parameterValue
        }

      guard let stringURL = iconDescription?.url, let url = URL(string: stringURL) else {
        return nil
      }

      let colors = IconColorSet(iconDescription: iconDescription)
      return (url, colors)
    } catch {
      logger.error("Failed to fetch icon", error: error)
      throw error
    }
  }
}

@available(macOS 10.15, *)
public typealias DomainIconLibrary = IconLibrary<DomainIconInfoProvider>

public protocol DomainIconLibraryProtocol {
  func icon(for domain: Domain, format: DomainIconFormat) async throws -> Icon?
}

extension DomainIconLibrary: DomainIconLibraryProtocol {
  public init(
    cacheDirectory: URL,
    cacheValidationInterval: TimeInterval = Self.defaultCacheValidationInterval,
    inMemoryCacheSize: Int = 500,
    cryptoEngine: CryptoEngine,
    appAPIClient: AppAPIClient,
    logger: Logger
  ) {

    self.init(
      cacheDirectory: cacheDirectory,
      cacheValidationInterval: cacheValidationInterval,
      inMemoryCacheSize: inMemoryCacheSize,
      cryptoEngine: cryptoEngine,
      imageDownloader: FileDownloader(),
      provider: DomainIconInfoProvider(appAPIClient: appAPIClient, logger: logger),
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
}
