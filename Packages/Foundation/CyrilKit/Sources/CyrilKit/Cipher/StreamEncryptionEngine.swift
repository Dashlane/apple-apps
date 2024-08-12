import Foundation

public protocol StreamEncryptionEngine: StreamEnrypterProvider & StreamDecrypterProvider {}

public protocol StreamEnrypterProvider {
  func makeStreamEncrypter() throws -> StreamEncrypter
}

public protocol StreamDecrypterProvider {
  func makeStreamDecrypter() throws -> StreamEncrypter
}

public protocol StreamEncrypter {
  func update(with data: Data) throws -> Data
  func finalize() throws -> Data
}
