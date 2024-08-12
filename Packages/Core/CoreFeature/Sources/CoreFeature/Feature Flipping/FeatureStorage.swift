import Foundation

public protocol FeatureFlipServiceStorage {
  func hasStoredData() -> Bool
  func store(_ data: Data) throws
  func retrieve() throws -> Data
}

public class FeatureFlipServiceStorageMock: FeatureFlipServiceStorage {
  var data: Data?

  public func hasStoredData() -> Bool {
    data != nil
  }

  public func store(_ data: Data) throws {
    self.data = data
  }

  public func retrieve() throws -> Data {
    guard let data else {
      throw URLError(.cannotOpenFile)
    }
    return data
  }
}

extension FeatureFlipServiceStorage where Self == FeatureFlipServiceStorageMock {
  public static func mock() -> FeatureFlipServiceStorageMock {
    FeatureFlipServiceStorageMock()
  }
}
