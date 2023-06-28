import Foundation
import DashlaneAPI

extension ActivityLogDataType {
    func makeActivityLog() -> AuditLogDetails {
        switch self {
        case let .credential(domain):
            return .init(type: .authentifiant, domain: domain)
        }
    }
}
