import CoreTypes
import DashlaneAPI
import Foundation

public struct TeamVaultAuditLog: Equatable {
  public enum AuditData: Equatable {
    case credential(domain: String)
  }

  public let id = UUID()
  public let spaceId: String
  public let data: AuditData

  public init(spaceId: String, data: AuditData) {
    self.spaceId = spaceId
    self.data = data
  }
}

extension TeamVaultAuditLog {
  func makeAuditLogDetails() -> AuditLogDetails {
    switch self.data {
    case let .credential(domain):
      return .init(type: .authentifiant, domain: domain)
    }
  }
}

extension AuditLogDetails {
  public init(type: `Type`, domain: String? = nil) {
    self.init(
      type: type,
      captureLog: true,
      domain: domain)
  }
}
