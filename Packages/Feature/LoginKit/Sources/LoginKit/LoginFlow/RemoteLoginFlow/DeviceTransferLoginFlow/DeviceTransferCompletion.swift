import CoreSession
import Foundation

public enum DeviceTransferCompletion {
  case completed(AccountTransferInfo)
  case recovery(AccountRecoveryInfo)
  case dismiss
  case changeFlow
}
