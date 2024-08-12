import DashTypes
import Foundation

extension PersonalDataContentType {
  var historyTitleKey: String? {
    switch self {
    case .credential:
      return Credential.CodingKeys.title.rawValue
    default:
      return nil
    }
  }
}
