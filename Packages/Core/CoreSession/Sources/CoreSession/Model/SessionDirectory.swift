import CommonCrypto
import CoreTypes
import Foundation
import LogFoundation

public struct SessionDirectory: Sendable {
  @Loggable
  enum Error: Swift.Error {
    case invalidKey
    case invalidLogin
  }

  private let reservedStoresFolderKey = "stores"
  private let extensionFolderKey = "extension"
  public var fileManager: FileManager {
    FileManager.default
  }
  internal static let sessionDirectoryExtension = "session"
  public private(set) var url: URL

  public init(url: URL) {
    self.url = url
  }

  public init(baseURL: URL, login: Login) throws {

    guard let directoryName = login.uniqueFilename else {
      throw Error.invalidLogin
    }

    let url =
      baseURL
      .appendingPathComponent(directoryName)
      .appendingPathExtension(SessionDirectory.sessionDirectoryExtension)

    self.init(url: url)
  }
}

extension SessionDirectory {
  public var exists: Bool {
    return fileManager.fileExists(atPath: url.path)
  }

  public mutating func create() throws {
    guard !exists else {
      return
    }

    try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try url.setResourceValues(values)
  }

  public func remove() throws {
    try fileManager.removeItem(at: url)
  }

  public func move(to directory: SessionDirectory) throws {
    try fileManager.moveItem(at: url, to: directory.url)
  }
}

extension SessionDirectory: StorePersistenceEngine {
  public func exists(for key: StoreKey) -> Bool {
    guard let fullUrl = try? makeURL(key: key) else {
      return false
    }

    return fileManager.fileExists(atPath: fullUrl.path)
  }

  private func makeURL(key: StoreKey) throws -> URL {
    let keyString = key.keyString
    guard !keyString.isEmpty else {
      throw Error.invalidKey
    }
    guard keyString != reservedStoresFolderKey else {
      throw Error.invalidKey
    }
    guard keyString != extensionFolderKey else {
      throw Error.invalidKey
    }

    let fullUrl = url.appendingPathComponent(keyString)
    guard !fullUrl.hasDirectoryPath else {
      throw URLError(.cannotWriteToFile)
    }

    return fullUrl
  }

  public func write(_ data: Data?, for key: StoreKey) throws {
    let fullUrl = try makeURL(key: key)

    if let data = data {
      try fileManager.createDirectory(
        at: fullUrl.deletingLastPathComponent(),
        withIntermediateDirectories: true,
        attributes: nil)
      try data.write(to: fullUrl)
    } else if fileManager.fileExists(atPath: fullUrl.path) {
      try fileManager.removeItem(at: fullUrl)
    }
  }

  public func read(for key: StoreKey) throws -> Data {
    let fullUrl = try makeURL(key: key)

    guard fileManager.fileExists(atPath: fullUrl.path) else {
      throw URLError(.cannotOpenFile)
    }

    return try Data(contentsOf: fullUrl)
  }
}

extension SessionDirectory {
  public func storeURLForData(identifiedBy identifier: String) throws -> URL {
    let storeURL =
      url
      .appendingPathComponent(reservedStoresFolderKey)
      .appendingPathComponent(identifier)
    return try createDirectoryIfNeeded(from: storeURL)
  }

  public func storeURLForData(
    inExtensionNamed extensionName: String, identifiedBy identifier: String
  ) throws -> URL {
    let folderURL =
      url
      .appendingPathComponent(extensionFolderKey)
      .appendingPathComponent(extensionName)
      .appendingPathComponent(reservedStoresFolderKey)
      .appendingPathComponent(identifier)
    return try createDirectoryIfNeeded(from: folderURL)
  }

  public func legacyExtensionStoreURLForData(identifiedBy identifier: String) -> URL {
    return
      url
      .appendingPathComponent(extensionFolderKey)
      .appendingPathComponent(reservedStoresFolderKey)
      .appendingPathComponent(identifier)
  }

  private func createDirectoryIfNeeded(from url: URL) throws -> URL {

    var isDirectory = ObjCBool(false)
    let exists = self.fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
    if !exists || !isDirectory.boolValue {
      try self.fileManager.createDirectory(
        at: url, withIntermediateDirectories: true, attributes: nil)
    }

    return url
  }
}

extension SessionDirectory {
  public func creationDate() throws -> Date? {
    let attributes = try fileManager.attributesOfItem(atPath: url.path)
    return attributes[FileAttributeKey.creationDate] as? Date
  }
}

extension URL {
  var isSessionDirectoryURL: Bool {
    return self.pathExtension == SessionDirectory.sessionDirectoryExtension
  }
}

extension Login {
  internal var uniqueFilename: String? {
    self.email.data(using: .utf8)?.hexEncodedString()
  }
}

extension Data {
  fileprivate func hexEncodedString() -> String {
    map { String(format: "%02hhx", $0) }.joined()
  }
}
