import CoreActivityLogs
import CorePersonalData
import CorePremium
import CoreUserTracking
import DashTypes
import Foundation
import IconLibrary
import VaultKit

public protocol ImportKitServicesContainer: DependenciesContainer {
  var reporter: ActivityReporterProtocol { get }
  var activityLogsService: ActivityLogsServiceProtocol { get }
  var userSpacesService: UserSpacesService { get }
  var iconService: IconServiceProtocol { get }
  var personalDataURLDecoder: PersonalDataURLDecoderProtocol { get }
}
