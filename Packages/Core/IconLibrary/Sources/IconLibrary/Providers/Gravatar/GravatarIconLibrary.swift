import CoreTypes
import Foundation
import LogFoundation
import UIKit

public struct GravatarIconInfoProvider: IconInfoProvider {
  public struct Request: IconLibraryRequest {
    public let email: String

    public init(email: String) {
      self.email = email
    }

    public var cacheKey: String {
      return email
    }
  }

  public func iconInfo(for request: Request) async throws -> (URL, UIColor?)? {
    guard let emailHash = request.email.md5() else { return nil }
    let url = URL(string: "_\(emailHash)?d=404")!
    return (url, nil)
  }
}

@available(macOS 10.15, *)
public typealias GravatarIconLibrary = IconLibrary<GravatarIconInfoProvider>

public protocol GravatarIconLibraryProtocol {
  func icon(forEmail email: String) async throws -> Icon?
}

@available(macOS 10.15, *)
extension GravatarIconLibrary: GravatarIconLibraryProtocol {
  public init(
    cacheDirectory: URL,
    cacheValidationInterval: TimeInterval = GravatarIconLibrary.defaultCacheValidationInterval,
    cryptoEngine: CryptoEngine,
    logger: Logger
  ) async {
    await self.init(
      cacheDirectory: cacheDirectory,
      cacheValidationInterval: cacheValidationInterval,
      cryptoEngine: cryptoEngine,
      imageDownloader: FileDownloader(),
      provider: GravatarIconInfoProvider(),
      logger: logger
    )

  }

  public func icon(forEmail email: String) async throws -> Icon? {
    let request = GravatarIconInfoProvider.Request(email: email)
    return try await icon(for: request)
  }
}

public struct FakeGravatarIconLibrary: GravatarIconLibraryProtocol {
  public let icon: Icon?

  public init(icon: Icon?) {
    self.icon = icon
  }

  public func icon(forEmail email: String) async throws -> Icon? {
    icon
  }
}
