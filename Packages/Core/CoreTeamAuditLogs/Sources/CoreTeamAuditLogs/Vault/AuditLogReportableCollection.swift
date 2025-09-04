import DashlaneAPI
import Foundation

public protocol AuditLogReportableCollection {
  func generateReportableInfo(with context: PrivateCollectionAuditLogContext) -> ReportableInfo?
}

public enum PrivateCollectionAuditLogContext {
  case create
  case update(oldCollectionName: String)
  case delete
  case importCollection(credentialCount: Int)
  case addCredential(domainURL: String)
  case deleteCredential(domainURL: String)
}
