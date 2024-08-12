import Foundation

public struct QRCodeTransferInfo: Hashable, Sendable {
  public let qrCodeURL: String
  public let transferId: String
  public let accountRecoveryInfo: AccountRecoveryInfo?
}
