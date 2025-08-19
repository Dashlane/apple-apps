import CorePersonalData
import CoreTypes
import Foundation
import SwiftUI
import UserTrackingFoundation
import VaultKit

class DomainsSectionModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  var canAddDomain: Bool {
    !hasLimitedRights && !service.isFrozen
  }

  var addedDomains: [LinkedServices.AssociatedDomain] {
    return item.linkedServices.associatedDomains
  }

  var linkedDomains: [String] {
    guard let linkedDomains = item.url?.domain?.linkedDomains else {
      return []
    }
    return linkedDomains
  }

  var linkedDomainsCount: Int {
    return linkedDomains.count + addedDomains.count
  }

  let service: DetailService<Credential>

  private var activityReporter: ActivityReporterProtocol {
    service.activityReporter
  }
  private var sharingService: SharedVaultHandling {
    service.sharingService
  }

  init(service: DetailService<Credential>) {
    self.service = service
  }

  func logOpenUrl() {
    let item = item
    activityReporter.report(
      UserEvent.OpenExternalVaultItemLink(
        domainType: .web,
        itemId: item.userTrackingLogID,
        itemType: .credential)
    )
    activityReporter.report(
      AnonymousEvent.OpenExternalVaultItemLink(
        domain: item.hashedDomainForLogs(),
        itemType: .credential)
    )
  }
}

extension DomainsSectionModel {
  static func mock(
    service: DetailService<Credential>
  ) -> DomainsSectionModel {
    DomainsSectionModel(
      service: service
    )
  }
}
