import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public typealias DownloadedTransaction = UserDeviceAPIClient.Sync.GetLatestContent.Response
  .TransactionsElement

extension DownloadedTransaction: CustomDebugStringConvertible {
  public var debugDescription: String {
    return
      "Transaction(action: \(action), type: \(type), identifier: \(identifier), backupDate: \(backupDate), contentSize: \(content?.count ?? 0))"
  }
}
