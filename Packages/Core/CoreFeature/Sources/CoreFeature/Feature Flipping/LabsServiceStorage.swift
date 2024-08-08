import DashTypes
import Foundation

public protocol LabsServiceStorage {
  func hasStoredData() -> Bool
  func store(_ data: Data) throws
  func retrieve() throws -> Data
}

public class LabsServiceStorageMock: LabsServiceStorage {
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

extension LabsServiceStorage where Self == LabsServiceStorageMock {
  public static func mock() -> LabsServiceStorageMock {
    LabsServiceStorageMock()
  }
}
