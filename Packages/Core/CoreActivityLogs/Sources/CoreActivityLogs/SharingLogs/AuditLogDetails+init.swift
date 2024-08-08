import DashlaneAPI
import Foundation

extension AuditLogDetails {
  public init(type: `Type`, domain: String? = nil) {
    self.init(
      type: type,
      captureLog: true,
      domain: domain)
  }
}
