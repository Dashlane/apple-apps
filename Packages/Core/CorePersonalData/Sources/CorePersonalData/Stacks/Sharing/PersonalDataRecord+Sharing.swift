import DashTypes
import Foundation

extension PersonalDataContentType {
  public var sharingType: SharingType? {
    switch self {
    case .credential:
      return .password
    case .secureNote:
      return .note
    case .secret:
      return .secret
    default:
      return nil
    }
  }
}

extension RecordMetadata {
  public var isShareable: Bool {
    return contentType.sharingType != nil && (isShared && sharingPermission == .admin || !isShared)
  }
}
