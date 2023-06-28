import Foundation
import DashTypes
import Combine

private let colorsCacheKeySuffix = "_colors"

public protocol IconLibraryRequest {
    var cacheKey: String { get }
}

public protocol IconInfoProvider {
    associatedtype Request: IconLibraryRequest
    func iconInfo(for: Request) async throws -> (URL, IconColorSet?)?
}

@available(macOS 10.15, *)
public actor IconLibrary<Provider: IconInfoProvider> {
    public typealias Request = Provider.Request
    enum CacheEntry {
        case inProgress(Task<IconCache, Error>)
        case ready(IconCache)
    }

    public static var defaultCacheValidationInterval: TimeInterval { 
        return 60 * 60 * 24 * 30
    }

    public let cacheValidationInterval: TimeInterval
    public var logger: Logger
    public let provider: Provider

    nonisolated let onDiskCache: OnDiskRemoteFileCache
    private var cache: [String: CacheEntry] = [:]
    private let cryptoEngine: CryptoEngine
    private let imageDownloader: FileDownloaderProtocol

    public init(cacheDirectory: URL,
                cacheValidationInterval: TimeInterval = IconLibrary<Provider>.defaultCacheValidationInterval,
                cryptoEngine: CryptoEngine,
                provider: Provider,
                logger: Logger) {
        self.init(cacheDirectory: cacheDirectory,
                  cacheValidationInterval: cacheValidationInterval,
                  cryptoEngine: cryptoEngine,
                  imageDownloader: FileDownloader(),
                  provider: provider,
                  logger: logger)
    }

    init(cacheDirectory: URL,
         cacheValidationInterval: TimeInterval = IconLibrary<Provider>.defaultCacheValidationInterval,
         cryptoEngine: CryptoEngine,
         imageDownloader: FileDownloaderProtocol,
         provider: Provider,
         logger: Logger) {
        onDiskCache = OnDiskRemoteFileCache(cacheDirectory: cacheDirectory, cryptoEngine: cryptoEngine, logger: logger)
        self.cacheValidationInterval = cacheValidationInterval

        self.provider = provider
        self.cryptoEngine = cryptoEngine
        self.logger = logger
        self.imageDownloader = imageDownloader
    }

        public func icon(for request: Request) async throws -> Icon? {
        let cacheKey = request.cacheKey
        switch cache[cacheKey] {
            case .inProgress(let handle):
                return try await handle.value.icon
            case .ready(let iconCache) where !shouldUpdate(forModificationDate: iconCache.modificationDate):
                return iconCache.icon
            default:
                let task = Task<IconCache, Error> {
                    do {
                        var cache = try readFromCache(usingCacheKey: cacheKey)
                        if shouldUpdate(forModificationDate: cache?.modificationDate) {
                            cache = try await downloadAndUpdateCache(for: request, cacheKey: cacheKey, diskCache: cache)
                        }
                        guard let cache = cache else {
                            throw URLError(.unknown)
                        }

                        return cache
                    } catch {
                        logger.error("DomainIconLibrary did trigger error ", error: error)
                        throw error
                    }
                }

                cache[cacheKey] = .inProgress(task)
                let iconCache = try await task.value
                cache[cacheKey] = .ready(iconCache)
                return iconCache.icon
        }
    }

        private func shouldUpdate(forModificationDate date: Date?) -> Bool {
        guard let modificationDate = date else {
            return true
        }
        return Date().timeIntervalSince(modificationDate) > cacheValidationInterval
    }

        private func readFromCache(usingCacheKey cacheKey: String) throws -> IconCache? {
        guard let (data, modificationDate) = try onDiskCache.cache(forKey: cacheKey) else {
            return nil
        }

        let colorSet: IconColorSet?
        if let (colorData, _) = try onDiskCache.cache(forKey: cacheKey.appending(colorsCacheKeySuffix)), let decodedColorSet = try? JSONDecoder().decode(IconColorSet.self, from: colorData) {
            colorSet = decodedColorSet
        } else {
            colorSet = nil
        }

        guard let image = Image(data: data) else {
            return nil
        }

        let icon = Icon(image: image, colors: colorSet)
        return IconCache(icon: icon, modificationDate: modificationDate)
    }

    private func downloadAndUpdateCache(for request: Request, cacheKey: String, diskCache: IconCache?) async throws -> IconCache {
        let colorsCacheKey = cacheKey.appending(colorsCacheKeySuffix)

                guard let (url, iconColorSet) = try await provider.iconInfo(for: request) else {
            return IconCache()
        }

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
                let image = Image(data: data)
                let colors = iconColorSet

                try onDiskCache.save(data, forKey: cacheKey)
                try onDiskCache.saveETag(etag, forKey: cacheKey)
                try onDiskCache.save(JSONEncoder().encode(colors), forKey: colorsCacheKey)
                let modificationDate = try onDiskCache.modificationDate(forKey: cacheKey)

                return IconCache(icon: Icon(image: image, colors: colors), modificationDate: modificationDate)

            case .noFile:
                try onDiskCache.save(Data(), forKey: cacheKey)
                let modificationDate = try onDiskCache.modificationDate(forKey: cacheKey)

                return IconCache(modificationDate: modificationDate)
        }
    }

    public func flushCache() {
        cache.removeAll()
    }

    func set(_ entry: CacheEntry, forKey key: String) {
        cache[key] = entry
    }
}
