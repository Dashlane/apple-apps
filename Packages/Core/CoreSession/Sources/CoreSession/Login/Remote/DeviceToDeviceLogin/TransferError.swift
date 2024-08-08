import Foundation

public enum TransferError: String, Identifiable, Sendable {
  public var id: String {
    rawValue
  }
  case timeout
  case unknown
}
