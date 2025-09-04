import CorePersonalData
import CorePremium
import Foundation
import ImportKit
import UserTrackingFoundation

extension SessionServicesContainer: ImportKitServicesContainer {
  var reporter: UserTrackingFoundation.ActivityReporterProtocol {
    sessionReporterService.activityReporter
  }

  var userSpacesServiceProcotol: CorePremium.UserSpacesService {
    return self.userSpacesService
  }

  var personalDataURLDecoder: PersonalDataURLDecoderProtocol {
    appServices.personalDataURLDecoder
  }

}
