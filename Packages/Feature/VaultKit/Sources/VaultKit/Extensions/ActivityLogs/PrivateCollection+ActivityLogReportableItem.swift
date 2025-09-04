import CorePersonalData
import CoreTeamAuditLogs
import DashlaneAPI
import Foundation

extension PrivateCollection: AuditLogReportableCollection {

  public func generateReportableInfo(with context: PrivateCollectionAuditLogContext)
    -> ReportableInfo?
  {
    switch context {
    case .create:
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userCreatedCollection,
          properties: .init(collectionName: name)),
        spaceId: spaceId)
    case .update(let oldCollectionName):
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userRenamedCollection,
          properties: .init(collectionName: name, oldCollectionName: oldCollectionName)),
        spaceId: spaceId)
    case .delete:
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userDeletedCollection,
          properties: .init(collectionName: name)),
        spaceId: spaceId)
    case .importCollection(let credentialCount):
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userImportedCollection,
          properties: .init(collectionName: name, credentialCount: credentialCount)),
        spaceId: spaceId)
    case .addCredential(let domainURL):
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userAddedCredentialToCollection,
          properties: .init(collectionName: name, domainURL: domainURL)),
        spaceId: spaceId)
    case .deleteCredential(let domainURL):
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userRemovedCredentialFromCollection,
          properties: .init(collectionName: name, domainURL: domainURL)),
        spaceId: spaceId)
    }
  }
}
