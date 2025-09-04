import CorePersonalData
import CorePremium
import CoreTeamAuditLogs
import CoreTypes
import Foundation
import IconLibrary
import UserTrackingFoundation

public protocol ImportKitServicesContainer: DependenciesContainer {
  var reporter: ActivityReporterProtocol { get }
  var teamAuditLogsService: TeamAuditLogsServiceProtocol { get }
  var userSpacesService: UserSpacesService { get }
  var iconService: IconServiceProtocol { get }
  var personalDataURLDecoder: PersonalDataURLDecoderProtocol { get }
}
