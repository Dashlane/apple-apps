import Combine
import CoreTypes
import CryptoKit
import DashlaneAPI
import Foundation
import LogFoundation
import UIKit

public struct DomainIconInfoProvider: IconInfoProvider {
  public struct Request: IconLibraryRequest {
    public let domain: Domain

    public init(domain: Domain) {
      self.domain = domain
    }

    public var cacheKey: String {
      return domain.name
    }
  }

  let logger: Logger
  let userDeviceAPIClient: UserDeviceAPIClient

  public init(userDeviceAPIClient: UserDeviceAPIClient, logger: Logger) {
    self.userDeviceAPIClient = userDeviceAPIClient
    self.logger = logger
  }

  public func iconInfo(for request: Request) async throws -> (URL, UIColor?)? {
    let domainHash = request.domainHash
    let shortDomainHash = String(domainHash.prefix(6))

    let response = try await userDeviceAPIClient.icons.getIcons(
      hashes: [shortDomainHash]
    )

    guard let matchingIcon = response.icons.first(where: { $0.hash == domainHash })
    else { return .none }

    switch matchingIcon.validity {
    case .expired, .invalid:
      try await userDeviceAPIClient.icons.requestIcons(domains: [request.domain.name])
    case .valid:
      guard let url = (matchingIcon.url.map(URL.init(string:)))?.flatMap({ $0 })
      else { return .none }

      let color: UIColor? = {
        guard let components = matchingIcon.backgroundColor?.split(separator: ","),
          let red = components.first.flatMap({ Int($0) }),
          let green = (components.indices.contains(1) ? components[1] : nil).flatMap({ Int($0) }),
          let blue = (components.indices.contains(2) ? components[2] : nil).flatMap({ Int($0) }),
          let alpha = (components.indices.contains(3) ? components[3] : nil).flatMap({ Double($0) })
        else { return nil }

        return UIColor(
          red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, alpha: alpha
        )
      }()

      return (url, color)
    default:
      break
    }

    return .none
  }
}

extension DomainIconInfoProvider.Request {
  fileprivate var domainHash: String {
    let digest = SHA256.hash(data: domain.name.data(using: .utf8)!)
    return digest.compactMap({ String(format: "%02x", $0) }).joined()
  }
}

@available(macOS 10.15, *)
public typealias DomainIconLibrary = IconLibrary<DomainIconInfoProvider>

public protocol DomainIconLibraryProtocol: Sendable {
  @MainActor
  func icon(for domain: Domain) async throws -> Icon?
}

extension DomainIconLibrary: DomainIconLibraryProtocol {
  public init(
    cacheDirectory: URL,
    cacheValidationInterval: TimeInterval = DomainIconLibrary.defaultCacheValidationInterval,
    inMemoryCacheSize: Int = 500,
    cryptoEngine: CryptoEngine,
    userDeviceAPIClient: UserDeviceAPIClient,
    logger: Logger
  ) async {
    await self.init(
      cacheDirectory: cacheDirectory,
      cacheValidationInterval: cacheValidationInterval,
      inMemoryCacheSize: inMemoryCacheSize,
      cryptoEngine: cryptoEngine,
      imageDownloader: FileDownloader(),
      provider: DomainIconInfoProvider(userDeviceAPIClient: userDeviceAPIClient, logger: logger),
      logger: logger
    )
  }

  public func icon(for domain: Domain) async throws -> Icon? {
    let request = DomainIconInfoProvider.Request(domain: domain)
    return try await icon(for: request)
  }
}

public struct FakeDomainIconLibrary: DomainIconLibraryProtocol {
  public let icon: Icon?

  public init(icon: Icon?) {
    self.icon = icon
  }

  public func icon(for domain: Domain) async throws -> Icon? {
    icon
  }
}
