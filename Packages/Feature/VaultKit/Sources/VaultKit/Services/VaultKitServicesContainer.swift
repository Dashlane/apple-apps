import Foundation
import CoreFeature
import CorePersonalData
import CorePremium
import CoreUserTracking
import DashTypes
import DocumentServices
import CoreActivityLogs

public protocol VaultKitServicesContainer: DependenciesContainer {
    var database: ApplicationDatabase { get }
    var documentStorageService: DocumentStorageService { get }
    var logger: Logger { get }
    var reporter: ActivityReporterProtocol { get }
    var teamSpacesServiceProcotol: CorePremium.TeamSpacesServiceProtocol { get }
    var vaultItemsService: VaultItemsService { get }
    var vaultKitDeepLinkingService: DeepLinkingServiceProtocol { get }
    var vaultKitFeatureService: FeatureServiceProtocol { get }
    var vaultKitPremiumService: PremiumServiceProtocol { get }
    var vaultKitTeamSpacesServiceProcotol: TeamSpacesServiceProtocol { get }
    var activityLogsService: ActivityLogsServiceProtocol { get }
}
