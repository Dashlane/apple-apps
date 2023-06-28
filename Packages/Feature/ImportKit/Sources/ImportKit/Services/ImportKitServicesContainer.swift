import Foundation
import DashTypes
import CorePremium
import CoreUserTracking
import IconLibrary
import VaultKit
import CorePersonalData

public protocol ImportKitServicesContainer: DependenciesContainer {
    var reporter: ActivityReporterProtocol { get }
    var teamSpacesServiceProcotol: CorePremium.TeamSpacesServiceProtocol { get }
    var iconService: IconServiceProtocol { get }
    var personalDataURLDecoder: PersonalDataURLDecoderProtocol { get }
}
