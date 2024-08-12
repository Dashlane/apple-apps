import Foundation

extension UserEvent {

  public struct `LaunchPasswordChanger`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`bulkChangeCredentialCount`: Int? = nil, `isBulkChange`: Bool, `isSuccess`: Bool) {
      self.bulkChangeCredentialCount = bulkChangeCredentialCount
      self.isBulkChange = isBulkChange
      self.isSuccess = isSuccess
    }
    public let bulkChangeCredentialCount: Int?
    public let isBulkChange: Bool
    public let isSuccess: Bool
    public let name = "launch_password_changer"
  }
}
