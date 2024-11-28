import CorePersonalData
import CorePremium
import CoreUserTracking
import Foundation
import ImportKit

extension SessionServicesContainer: ImportKitServicesContainer {
  var reporter: CoreUserTracking.ActivityReporterProtocol {
    sessionReporterService.activityReporter
  }

  var userSpacesServiceProcotol: CorePremium.UserSpacesService {
    return self.userSpacesService
  }

  var personalDataURLDecoder: PersonalDataURLDecoderProtocol {
    appServices.personalDataURLDecoder
  }

}
