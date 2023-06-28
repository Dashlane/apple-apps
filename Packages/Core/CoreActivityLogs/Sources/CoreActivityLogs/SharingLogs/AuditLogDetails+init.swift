import Foundation
import DashlaneAPI

extension AuditLogDetails {
    public init(type: `Type`, domain: String? = nil) {
                self.init(type: type,
                  captureLog: true,
                  domain: domain)
    }
}
