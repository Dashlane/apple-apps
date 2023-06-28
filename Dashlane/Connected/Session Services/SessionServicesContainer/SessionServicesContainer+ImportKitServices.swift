import Foundation
import ImportKit
import CoreUserTracking
import CorePremium
import CorePersonalData

extension SessionServicesContainer: ImportKitServicesContainer {
    var reporter: CoreUserTracking.ActivityReporterProtocol {
        activityReporter.activityReporter
    }

    var teamSpacesServiceProcotol: TeamSpacesServiceProtocol {
        return self.teamSpacesService
    }

    var personalDataURLDecoder: PersonalDataURLDecoderProtocol {
        appServices.personalDataURLDecoder
    }

}
