import Foundation
import LogFoundation
import SwiftTreats

@Loggable
struct DocumentCacheError: Error {
  @LogPublicPrivacy
  let message: String
  public init(_ message: String) {
    self.message = message
  }
}

public struct DocumentCache {

  public enum CacheScope {
    case allDirectories
    case encryptedDirectory
    case decryptedDirectory
  }

  private func cacheURL() throws -> URL {
    return try FileManager.default.cacheDirectory()
      .appendingPathComponent(
        "documentStorageCache",
        isDirectory: true)
  }

  private func encryptedFilesURL() throws -> URL {
    return try cacheURL().appendingPathComponent(
      "encryptedFiles",
      isDirectory: true)
  }

  private func decryptedFilesURL() throws -> URL {
    return try cacheURL().appendingPathComponent(
      "decryptedFiles",
      isDirectory: true)
  }

  init() {
    try? clear(.decryptedDirectory)
  }

  private func cacheDirectory() throws -> URL {
    let cacheURL = try self.cacheURL()
    try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
    return cacheURL
  }

  private func destination(scope: CacheScope, filename: String, isUnique: Bool = false) throws
    -> URL
  {
    var destination: URL
    switch scope {
    case .allDirectories:
      throw DocumentCacheError("Cannot write to this scope")
    case .decryptedDirectory:
      destination = try self.urlOfDecryptedDirectory(with: filename, isUnique: isUnique)
    case .encryptedDirectory:
      destination = try self.urlOfEncryptedDirectory(with: filename, isUnique: isUnique)
    }
    return destination
  }

  public func urlOfEncryptedDirectory(
    with fileComponent: String? = nil,
    isUnique: Bool = false
  ) throws -> URL {
    let encryptedFilesURL = try self.encryptedFilesURL()
    let url =
      isUnique
      ? encryptedFilesURL.appendingPathComponent(UUID().uuidString, isDirectory: true)
      : encryptedFilesURL
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    guard let fileComponent = fileComponent else {
      return url
    }
    return url.appendingPathComponent(fileComponent)
  }

  public func urlOfDecryptedDirectory(
    with fileComponent: String? = nil,
    isUnique: Bool = false
  ) throws -> URL {
    let decryptedFilesURL = try self.decryptedFilesURL()
    let url =
      isUnique
      ? decryptedFilesURL.appendingPathComponent(UUID().uuidString, isDirectory: true)
      : decryptedFilesURL
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    guard let fileComponent = fileComponent else {
      return url
    }
    return url.appendingPathComponent(fileComponent)
  }

  public func clear(_ scope: CacheScope) throws {
    switch scope {
    case .allDirectories:
      try FileManager.default.removeItem(at: self.cacheURL())
    case .decryptedDirectory:
      try FileManager.default.removeItem(at: self.decryptedFilesURL())
    case .encryptedDirectory:
      try FileManager.default.removeItem(at: self.encryptedFilesURL())
    }
  }

  @discardableResult
  public func write(
    _ data: Data,
    to scope: CacheScope,
    filename: String,
    isUnique: Bool = false
  ) throws -> URL {
    var destination = try self.destination(scope: scope, filename: filename, isUnique: isUnique)
    try? FileManager.default.removeItem(at: destination)
    try data.write(to: destination, options: [.atomic])
    try? destination.setExcludedFromiCloudBackup()
    return destination
  }

  @discardableResult
  public func move(
    _ url: URL,
    to scope: CacheScope,
    filename: String,
    isUnique: Bool = false
  ) throws -> URL {
    let destination = try self.destination(scope: scope, filename: filename, isUnique: isUnique)
    try? FileManager.default.removeItem(at: destination)
    try FileManager.default.moveItem(at: url, to: destination)
    return destination
  }

  @discardableResult
  public func copy(
    _ url: URL,
    to scope: CacheScope,
    filename: String,
    isUnique: Bool = false
  ) throws -> URL {
    let destination = try self.destination(scope: scope, filename: filename, isUnique: isUnique)
    try? FileManager.default.removeItem(at: destination)
    try FileManager.default.copyItem(at: url, to: destination)
    return destination
  }
}

extension FileManager {
  fileprivate func createDirectory(at path: String) throws {
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
  }
  fileprivate func cacheDirectory() throws -> URL {
    return try FileManager.default
      .url(
        for: .cachesDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true)
  }
}
