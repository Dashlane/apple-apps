import Combine
import CoreCategorizer
import CoreFeature
import CorePasswords
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreSync
import CoreTypes
import DashlaneAPI
import DomainParser
import Foundation
import SecurityDashboard
import UIKit
import VaultKit

public protocol IdentityDashboardServiceProtocol {
  var monitoredEmails: Set<DataLeakEmail> { get }
  var monitoredEmailsPublisher: AnyPublisher<Set<DataLeakEmail>, Never> { get }
  var breaches: [StoredBreach] { get set }
  var breachesPublisher: Published<[StoredBreach]>.Publisher { get }
  var breachesToPresent: [PopupAlertProtocol] { get }
  var breachesToPresentPublisher: Published<[PopupAlertProtocol]>.Publisher { get }
  var dataLeaksLastUpdate: IdentityDashboardService.DataLeaksUpdate { get set }
  var dataLeaksLastUpdatePublisher: Published<IdentityDashboardService.DataLeaksUpdate>.Publisher {
    get
  }
  var dataLeaksUpdateRequested: PassthroughSubject<Void, Never> { get set }
  var dataLeaksUpdateRequestedPublisher: Published<PassthroughSubject<Void, Never>>.Publisher {
    get
  }
  var decryptorPublisher: Published<DataLeakInformationDecryptor?>.Publisher { get }
  func trayAlertsPublisher() -> AnyPublisher<[TrayAlertProtocol], Never>
  func report(spaceId: String?) async -> PasswordHealthReport
  func data(for request: PasswordHealthAnalyzer.Request) async -> PasswordHealthResult
  func numberOfTimesPasswordIsReused(of credential: Credential, completion: @escaping (Int) -> Void)
  func isCompromised(_ credential: Credential, completion: @escaping (Bool) -> Void)
  func trayAlerts() async -> [TrayAlertProtocol]
  func mark(breaches: [BreachesService.Identifier], as status: StoredBreach.Status) async
  func credentials(forBreachId breachId: String) -> [SecurityDashboardCredential]
  func reportPublisher(spaceId: String?) -> AnyPublisher<PasswordHealthReport, Never>
  func dataPublisher(for request: PasswordHealthAnalyzer.Request) -> AnyPublisher<
    PasswordHealthResult, Never
  >
  func vaultSnapshot(for credentials: [Credential]) async -> [UserSecureNitroEncryptionAPIClient
    .Uvvs.UploadUserSnapshot.Body.UvvsElement]
  func publisher(for notification: IdentityDashboardNotificationManager.NotificationType)
    -> NotificationCenter.Publisher
  func removeFromMonitoredEmails(email: String)
  func monitorNew(email: String) async throws
  func updateMonitoredEmails(onCompletion: ((Result<DataLeakStatusResponse, Error>) -> Void)?)
  func registerEmail(email: String) async throws
}
