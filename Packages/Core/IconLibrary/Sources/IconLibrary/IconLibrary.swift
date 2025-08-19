import Combine
import CoreTypes
import Foundation
import LogFoundation
import UIKit

public protocol IconLibraryRequest: Sendable {
  var cacheKey: String { get }
}

public protocol IconInfoProvider: Sendable {
  associatedtype Request: IconLibraryRequest
  @MainActor
  func iconInfo(for: Request) async throws -> (URL, UIColor?)?
}

private let colorCacheKeySuffix = "_color"

public actor IconLibrary<Provider: IconInfoProvider> {
  public typealias Request = Provider.Request

  public static var defaultCacheValidationInterval: TimeInterval {
    return 60 * 60 * 24 * 30
  }

  public let cacheValidationInterval: TimeInterval
  public let logger: Logger
  public let provider: Provider

  let onDiskCache: OnDiskRemoteFileCache
  @MainActor
  let inMemoryCache: InMemoryCache
  private let cryptoEngine: CryptoEngine
  private let imageDownloader: FileDownloaderProtocol

  public init(
    cacheDirectory: URL,
    cacheValidationInterval: TimeInterval = IconLibrary<Provider>.defaultCacheValidationInterval,
    inMemoryCacheSize: Int = 500,
    cryptoEngine: CryptoEngine,
    provider: Provider,
    logger: Logger
  ) async {
    await self.init(
      cacheDirectory: cacheDirectory,
      cacheValidationInterval: cacheValidationInterval,
      inMemoryCacheSize: inMemoryCacheSize,
      cryptoEngine: cryptoEngine,
      imageDownloader: FileDownloader(),
      provider: provider,
      logger: logger
    )
  }

  init(
    cacheDirectory: URL,
    cacheValidationInterval: TimeInterval = IconLibrary<Provider>.defaultCacheValidationInterval,
    inMemoryCacheSize: Int = 500,
    cryptoEngine: CryptoEngine,
    imageDownloader: FileDownloaderProtocol,
    provider: Provider,
    logger: Logger
  ) async {
    onDiskCache = OnDiskRemoteFileCache(
      cacheDirectory: cacheDirectory, cryptoEngine: cryptoEngine, logger: logger)
    inMemoryCache = await InMemoryCache(limit: inMemoryCacheSize)
    self.cacheValidationInterval = cacheValidationInterval

    self.provider = provider
    self.cryptoEngine = cryptoEngine
    self.logger = logger
    self.imageDownloader = imageDownloader
  }

  @MainActor
  public func icon(for request: Request) async throws -> Icon? {
    let cacheKey = request.cacheKey
    switch inMemoryCache[cacheKey] {
    case .inProgress(let handle):
      return try await handle.value.icon
    case .ready(let iconCache) where !shouldUpdate(forModificationDate: iconCache.modificationDate):
      return iconCache.icon
    default:
      let task = Task<IconCache, Error> { [weak self] in
        guard let self = self else { throw URLError(.cancelled) }
        return try await self.fetch(using: request)
      }

      inMemoryCache[cacheKey] = .inProgress(task)

      do {
        let iconCache = try await task.value
        inMemoryCache[cacheKey] = .ready(iconCache)
        return iconCache.icon
      } catch {
        let iconCache = IconCache()
        inMemoryCache[cacheKey] = .ready(iconCache)
        return iconCache.icon
      }
    }
  }

  private nonisolated func shouldUpdate(forModificationDate date: Date?) -> Bool {
    guard let modificationDate = date else {
      return true
    }
    return Date().timeIntervalSince(modificationDate) > cacheValidationInterval
  }

  private func fetch(using request: Request) async throws -> IconCache {
    do {
      var cache = try self.readFromCache(usingCacheKey: request.cacheKey)
      if shouldUpdate(forModificationDate: cache?.modificationDate) {
        cache = try await downloadAndUpdateCache(
          for: request, cacheKey: request.cacheKey, diskCache: cache)
      }
      guard let cache = cache else { throw URLError(.unknown) }
      return cache
    } catch {
      logger.error("DomainIconLibrary did trigger error ", error: error)
      throw error
    }
  }

  private func readFromCache(usingCacheKey cacheKey: String) throws -> IconCache? {
    guard let (data, modificationDate) = try onDiskCache.cache(forKey: cacheKey)
    else { return nil }

    let color: UIColor? = try {
      guard
        let (colorData, _) = try onDiskCache.cache(forKey: cacheKey.appending(colorCacheKeySuffix)),
        let colorRepresentation = String(data: colorData, encoding: .utf8)
      else { return nil }

      return UIColor(ciColor: CIColor(string: colorRepresentation))
    }()

    guard let image = UIImage(data: data) else { return nil }

    let icon = Icon(image: image, color: color)
    return IconCache(icon: icon, modificationDate: modificationDate)
  }

  private func downloadAndUpdateCache(for request: Request, cacheKey: String, diskCache: IconCache?)
    async throws -> IconCache
  {
    let colorsCacheKey = cacheKey.appending(colorCacheKeySuffix)

    guard let (url, color) = try await provider.iconInfo(for: request)
    else { return IconCache() }

    let etag = diskCache != nil ? try onDiskCache.etag(forKey: cacheKey) : nil
    let result = try await imageDownloader.download(at: url, etag: etag)
    switch result {
    case .notModified:
      let date = Date()
      var iconCache = diskCache ?? IconCache()
      iconCache.modificationDate = date

      try onDiskCache.setModificationDate(date, forKey: cacheKey)

      return iconCache

    case let .data(data, etag: etag):
      let image = UIImage(data: data)
      let encodedColor = color.flatMap(CIColor.init(color:))?.stringRepresentation.data(
        using: .utf8)

      try onDiskCache.save(data, forKey: cacheKey)
      try onDiskCache.saveETag(etag, forKey: cacheKey)
      try onDiskCache.save(encodedColor, forKey: colorsCacheKey)
      let modificationDate = try onDiskCache.modificationDate(forKey: cacheKey)

      return IconCache(icon: Icon(image: image, color: color), modificationDate: modificationDate)

    case .noFile:
      try onDiskCache.save(Data(), forKey: cacheKey)
      let modificationDate = try onDiskCache.modificationDate(forKey: cacheKey)

      return IconCache(modificationDate: modificationDate)
    }
  }

  @MainActor
  public func flushCache() {
    inMemoryCache.clear()
  }
}
