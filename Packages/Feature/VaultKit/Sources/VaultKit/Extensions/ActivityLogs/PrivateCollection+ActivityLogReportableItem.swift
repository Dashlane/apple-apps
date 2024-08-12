import CoreActivityLogs
import CorePersonalData
import Foundation

extension PrivateCollection: ActivityLogReportableCollection {

  public func reportableInfo(
    domainURL: String? = nil, credentialCount: Int? = nil, oldCollectionName: String? = nil
  ) -> ActivityLogReportableInfoCollection? {
    return .init(
      spaceId: spaceId,
      properties: .init(
        collectionName: name,
        credentialCount: credentialCount,
        domainURL: domainURL,
        oldCollectionName: oldCollectionName))
  }
}
