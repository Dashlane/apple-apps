import Foundation

public enum PurchaseStatus: Equatable {
  case deferred
  case purchasing
  case verifyingReceipt
  case updatingPremiumStatus
  case cancelled
  case success
}
