import CoreTypes
import DashlaneAPI
import Foundation

struct DataForMasterPasswordChange: Encodable {
  struct TwoFASettings: Encodable {
    enum Status: String, Encodable {
      case disabled
      case login
    }

    let type: Status
    let serverKey: String?
  }

  let timestamp: Timestamp
  let new2FASetting: TwoFASettings?
  let sharingKeys: SyncSharingKeys
  let transactions: [UploadMigrationTransaction]
  let authTicket: String?
  let remoteKeys: SyncUploadDataRemoteKeys?
  let updateVerification: Verification?

}
