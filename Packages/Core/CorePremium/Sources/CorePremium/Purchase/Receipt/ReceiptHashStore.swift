import Foundation
import SwiftTreats

public protocol ReceiptHashStore {
  func receiptHash() -> Data?
  func storeReceiptHash(_ data: Data?)
}

public class InMemoryHashStore: ReceiptHashStore {
  @Atomic
  private var data: Data?

  public init() {

  }

  public func receiptHash() -> Data? {
    data
  }

  public func storeReceiptHash(_ data: Data?) {
    self.data = data
  }
}

extension ReceiptHashStore where Self == InMemoryHashStore {
  public static var inMemory: InMemoryHashStore {
    InMemoryHashStore()
  }
}
