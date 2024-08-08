import CoreSettings
import DashlaneAPI
import Foundation

enum VersionValidityStatus: Equatable {
  case valid
  case updateRecommended(updatePossible: Bool)
  case updateStronglyEncouraged(updatePossible: Bool, helpCenterUrl: String)
  case updateRequired(updatePossible: Bool, daysBeforeExpiration: Int?, helpCenterUrl: String)
  case expired(updatePossible: Bool, helpCenterUrl: String)

  static var defaultHelpCenterUrl: String {
    return "_"
  }

  var isValid: Bool {
    switch self {
    case .expired:
      return false
    default:
      return true
    }
  }

  init?(response: AppAPIClient.Platforms.AppVersionStatus.Response) {
    switch response.status {
    case .validVersion:
      self = .valid
    case .updateRecommended:
      self = .updateRecommended(updatePossible: response.updatePossible)
    case .updateStronglyEncouraged:
      self = .updateStronglyEncouraged(
        updatePossible: response.updatePossible,
        helpCenterUrl: response.userSupportLink ?? Self.defaultHelpCenterUrl)
    case .updateRequired:
      self = .updateRequired(
        updatePossible: response.updatePossible,
        daysBeforeExpiration: response.daysBeforeExpiration,
        helpCenterUrl: response.userSupportLink ?? Self.defaultHelpCenterUrl)
    case .expiredVersion:
      self = .expired(
        updatePossible: response.updatePossible,
        helpCenterUrl: response.userSupportLink ?? Self.defaultHelpCenterUrl)
    case .undecodable:
      return nil
    }
  }
}
