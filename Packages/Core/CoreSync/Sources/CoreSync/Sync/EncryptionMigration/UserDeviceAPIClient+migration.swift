import CoreTypes
import DashlaneAPI
import Foundation

public enum MigrationUploadMode: Sendable {
  case masterKeyChange
  case cryptoConfigChange
}

extension UserDeviceAPIClient.Sync {
  func upload(
    using mode: MigrationUploadMode,
    content: DataForMasterPasswordChange
  ) async throws -> SyncUploadDataResponse {
    let timestamp = Int(content.timestamp.millisecondsSince1970)
    let transactions = content.transactions
    let sharingKeys = content.sharingKeys
    let remoteKeys = content.remoteKeys.map { [$0] }

    switch mode {
    case .masterKeyChange:
      return try await uploadDataForMasterPasswordChange(
        timestamp: timestamp,
        transactions: transactions,
        sharingKeys: sharingKeys,
        authTicket: content.authTicket,
        remoteKeys: remoteKeys ?? [],
        updateVerification: content.updateVerification,
        uploadReason: .masterPasswordMobileReset)
    case .cryptoConfigChange:
      return try await uploadDataForCryptoUpdate(
        timestamp: timestamp,
        transactions: transactions,
        sharingKeys: sharingKeys,
        remoteKeys: remoteKeys)
    }
  }
}
