import CorePremium
import CoreSettings
import Foundation

extension UserEncryptedSettings: ReceiptHashStore {
  public func receiptHash() -> Data? {
    self[.receiptHash]
  }

  public func storeReceiptHash(_ data: Data?) {
    self[.receiptHash] = data
  }
}
