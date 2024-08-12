import DashlaneAPI
import Foundation

public typealias Verification = UserDeviceAPIClient.Sync.UploadDataForMasterPasswordChange.Body
  .UpdateVerification

public struct AuthTicket {
  public let token: String
  public let verification: Verification

  public init(token: String, verification: Verification) {
    self.token = token
    self.verification = verification
  }
}
