import CoreTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public typealias UploadMigrationTransaction = SyncUploadDataTransactions

extension UploadMigrationTransaction: CustomDebugStringConvertible {
  public var debugDescription: String {
    return
      "UploadTransaction(action: \(action), type: \(type), identifier: \(identifier), contentSize: \(content.count))"
  }
}
