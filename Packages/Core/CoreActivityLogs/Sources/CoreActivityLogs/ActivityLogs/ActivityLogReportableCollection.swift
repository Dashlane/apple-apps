import DashlaneAPI
import Foundation

public protocol ActivityLogReportableCollection {
  func reportableInfo(domainURL: String?, credentialCount: Int?, oldCollectionName: String?)
    -> ActivityLogReportableInfoCollection?
}

public struct ActivityLogReportableInfoCollection: Equatable {
  public let spaceId: String?
  public let properties: ActivityLog.Properties

  public init(
    spaceId: String?,
    properties: ActivityLog.Properties
  ) {
    self.spaceId = spaceId
    self.properties = properties
  }
}

extension ActivityLogReportableInfoCollection {

  func logType(for action: ActivityLogsService.CollectionAction) -> ActivityLog.LogType {
    switch action {
    case .creation:
      return .userCreatedCollection
    case .update:
      return .userRenamedCollection
    case .deletion:
      return .userDeletedCollection
    case .importCollection:
      return .userImportedCollection
    case .addCredential:
      return .userAddedCredentialToCollection
    case .deleteCredential:
      return .userRemovedCredentialFromCollection
    }
  }
}
