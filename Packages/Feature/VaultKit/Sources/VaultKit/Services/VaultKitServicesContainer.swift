import CoreFeature
import CorePersonalData
import CorePremium
import CoreSettings
import CoreTeamAuditLogs
import CoreTypes
import DocumentServices
import Foundation
import IconLibrary
import LogFoundation
import UserTrackingFoundation

public protocol VaultKitServicesContainer: DependenciesContainer {
  var database: ApplicationDatabase { get }
  var documentStorageService: DocumentStorageService { get }
  var logger: Logger { get }
  var reporter: ActivityReporterProtocol { get }
  var userSpacesService: UserSpacesService { get }
  var vaultServicesSuit: VaultServicesSuit { get }
  var vaultKitDeepLinkingService: DeepLinkingServiceProtocol { get }
  var vaultKitFeatureService: FeatureServiceProtocol { get }
  var vaultKitVaultStateService: VaultStateServiceProtocol { get }
  var capabilityService: CapabilityServiceProtocol { get }
  var teamAuditLogsService: TeamAuditLogsServiceProtocol { get }
  var domainIconLibrary: DomainIconLibraryProtocol { get }
  var vaultKitSharingServiceHandler: SharedVaultHandling { get }
  var vaultKitSharingService: SharingServiceProtocol { get }
  var vaultKitAccessControl: AccessControlHandler { get }
  var vaultKitPasteboardService: PasteboardServiceProtocol { get }
  var vaultKitUserSettings: UserSettings { get }
  var premiumStatusProvider: PremiumStatusProvider { get }
}
