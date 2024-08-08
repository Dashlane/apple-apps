import DashTypes
import DashlaneAPI
import Foundation

public enum MigrationUploadMode: String {
  case masterKeyChange = "UploadDataForMasterPasswordChange"
  case cryptoConfigChange = "UploadDataForCryptoUpdate"
}

extension UserDeviceAPIClient.Sync {
  func upload(
    using mode: MigrationUploadMode,
    content: DataForMasterPasswordChange
  ) async throws -> SyncUploadDataResponse {
    let timestamp = Int(content.timestamp.millisecondsSince1970)
    let transactions = content.transactions
    let sharingKeys = content.sharingKeys

    switch mode {
    case .masterKeyChange:
      return try await uploadDataForMasterPasswordChange(
        timestamp: timestamp,
        transactions: transactions,
        sharingKeys: sharingKeys,
        authTicket: content.authTicket,
        remoteKeys: (content.remoteKeys ?? []),
        updateVerification: content.updateVerification,
        uploadReason: .masterPasswordMobileReset)
    case .cryptoConfigChange:
      return try await uploadDataForCryptoUpdate(
        timestamp: timestamp,
        transactions: transactions,
        sharingKeys: sharingKeys,
        remoteKeys: content.remoteKeys)
    }
  }
}
