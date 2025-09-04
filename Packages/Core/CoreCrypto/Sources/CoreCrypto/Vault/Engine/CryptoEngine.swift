import CoreTypes
import CyrilKit
import Foundation

struct CryptoEngineImpl {
  let configuration: CryptoConfiguration
  let secret: EncryptionSecret
  private let defaultProvider: any EncryptionProvider

  init(configuration: CryptoConfiguration, secret: EncryptionSecret, fixedSalt: Data?) throws {
    self.configuration = configuration
    self.secret = secret
    self.defaultProvider = try configuration.makeEncryptionProvider(
      secret: secret, fixedSalt: fixedSalt)
  }

  fileprivate func provider(forEncryptedData data: Data) throws -> EncryptionProvider {
    let configuration = try CryptoConfiguration(encryptedData: data)
    let provider: any EncryptionProvider

    if self.configuration == configuration {
      provider = defaultProvider
    } else {
      provider = try configuration.makeEncryptionProvider(secret: secret, fixedSalt: nil)
    }

    return provider
  }
}

extension CryptoConfiguration {
  public func makeCryptoEngine(secret: EncryptionSecret, fixedSalt: Data? = nil) throws
    -> CryptoEngine & FileCryptoEngine
  {
    return try CryptoEngineImpl(configuration: self, secret: secret, fixedSalt: fixedSalt)
  }
}

extension CryptoEngineImpl: CryptoEngine {
  func encrypt(_ data: Data) throws -> Data {
    let (header, encrypter) = try defaultProvider.makeEncrypter()
    return try header + encrypter.encrypt(data)
  }

  func decrypt(_ data: Data) throws -> Data {
    let provider = try provider(forEncryptedData: data)
    let (dataPosition, decrypter) = try provider.makeDecrypter(forEncryptedData: data)
    return try decrypter.decrypt(data[dataPosition...])
  }
}

extension CryptoEngineImpl: FileCryptoEngine {
  private func makeFileHandles(source: URL, destination: URL) throws -> (
    input: FileHandle, output: FileHandle
  ) {
    let path = destination.path(percentEncoded: false)
    if FileManager.default.fileExists(atPath: path) {
      try FileManager.default.removeItem(atPath: path)
    }
    FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)

    let input = try FileHandle(forReadingFrom: source)
    let output = try FileHandle(forWritingTo: destination)
    return (input, output)
  }

  func encrypt(_ source: URL, to destination: URL) throws {
    let (input, output) = try makeFileHandles(source: source, destination: destination)
    let (header, encrypter) = try defaultProvider.makeEncrypter()

    try output.write(contentsOf: header)
    try encrypter.encrypt(input, to: output)
  }

  func decrypt(_ source: URL, to destination: URL) throws {
    let (input, output) = try makeFileHandles(source: source, destination: destination)

    guard let data = try input.read(upToCount: 100) else {
      throw URLError(.cannotOpenFile)
    }

    let provider = try provider(forEncryptedData: data)
    let (dataPosition, decrypter) = try provider.makeDecrypter(forEncryptedData: data)
    try input.seek(toOffset: UInt64(dataPosition))

    try decrypter.decrypt(input, to: output)
  }
}
