import DashlaneAPI
import Foundation

extension ActivityLogDataType {
  func makeActivityLog() -> AuditLogDetails {
    switch self {
    case let .credential(domain):
      return .init(type: .authentifiant, domain: domain)
    case .secret:
      return AuditLogDetails(type: .secret)
    }
  }
}
