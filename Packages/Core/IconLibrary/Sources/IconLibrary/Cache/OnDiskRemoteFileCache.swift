import Foundation
import DashTypes
import CommonCrypto
import SwiftTreats

struct OnDiskRemoteFileCache {
    private static let etagFilenameSuffix = "Etag"

    enum Error: Swift.Error {
        case cannotCreateObfuscatedCacheKey
    }

    let cacheDirectory: URL
    let cryptoEngine: CryptoEngine

    private let fileManager = FileManager.default

    init(cacheDirectory: URL, cryptoEngine: CryptoEngine, logger: Logger) {
        self.cacheDirectory = cacheDirectory
        do {
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: [:])
        } catch {
            logger.error("Create icon cache folder failed", error: error)
        }
        self.cryptoEngine = cryptoEngine
    }

                private func localCacheURL(for cacheKey: String) throws -> URL {
        guard let obfuscatedCacheKey = cacheKey.sha512() else {
            throw Error.cannotCreateObfuscatedCacheKey
        }

        return self.cacheDirectory.appendingPathComponent(obfuscatedCacheKey)
    }

        func cache(forKey key: String) throws -> (data: Data, modificationDate: Date)? {
        let url = try localCacheURL(for: key)
        guard fileManager.fileExists(atPath: url.path),
            let attributes = try? fileManager.attributesOfItem(atPath: url.path),
            let modificationDate = attributes[.modificationDate] as? Date else {
            return nil
        }

        let data = try Data(contentsOf: url)
        guard let plaintext = cryptoEngine.decrypt(data: data) else {
            return nil
        }
        return (plaintext, modificationDate)
    }

    func modificationDate(forKey key: String) throws -> Date? {
        let url = try localCacheURL(for: key)
        guard fileManager.fileExists(atPath: url.path),
            let attributes = try? fileManager.attributesOfItem(atPath: url.path),
            let modificationDate = attributes[.modificationDate] as? Date else {
            return nil
        }
        return modificationDate
    }

    func etag(forKey key: String) throws -> String? {
        let url = try localCacheURL(for: key).appendingPathExtension(OnDiskRemoteFileCache.etagFilenameSuffix)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        return try String(contentsOf: url)
    }

        func save(_ data: Data?, forKey key: String) throws {
        let url = try localCacheURL(for: key)
        if let data = data {
            let encryptedData = cryptoEngine.encrypt(data: data)
            try encryptedData?.write(to: url)

        } else if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    func saveETag(_ etag: String?, forKey key: String) throws {
        let url = try localCacheURL(for: key)
        let etagURL = url.appendingPathExtension(OnDiskRemoteFileCache.etagFilenameSuffix)
        if let etag = etag {
            try etag.write(to: etagURL, atomically: true, encoding: .utf8)
        } else if FileManager.default.fileExists(atPath: etagURL.path) {
            try FileManager.default.removeItem(at: etagURL)
        }
    }

    func setModificationDate(_ date: Date, forKey key: String) throws {
        let url = try localCacheURL(for: key)
        try fileManager.setAttributes([.modificationDate: date], ofItemAtPath: url.path)
    }
}
