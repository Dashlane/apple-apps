import Combine
import CorePersonalData
import CorePremium
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import IconLibrary
import LogFoundation
import SecurityDashboard
import UserTrackingFoundation
import VaultKit

@Loggable
enum DWMBreachesFetchingError: Error {
  case connectionError
  @LogPublicPrivacy
  case unexpectedError(_ error: Error)
}

@Loggable
public enum DWMEmailRegistrationError: Error {
  case incorrectEmail
  case connectionError
  @LogPublicPrivacy
  case unexpectedError(_ error: Error)
}

public protocol DarkWebMonitoringServiceProtocol {
  var isDwmEnabled: Bool { get }
  var maxMonitoredEmails: Int { get set }
  var monitoredEmailsPublisher: AnyPublisher<[DataLeakEmail], Never> { get }
  var breachesPublisher: AnyPublisher<[DWMSimplifiedBreach], Never> { get }
  func register(email: DarkWebMonitoringService.Email) -> AnyPublisher<
    String, DWMEmailRegistrationError
  >
  func updateMonitoredEmails(completion: @escaping (Result<DataLeakStatusResponse, Error>) -> Void)
  func correspondingCredentials(for breach: DWMSimplifiedBreach) -> [Credential]
  func refresh()
  func delete(_ breach: DWMSimplifiedBreach)
  func viewed(_ breach: DWMSimplifiedBreach)
  func solved(_ breach: DWMSimplifiedBreach)
  func saveNewPassword(
    for credential: Credential, newPassword: String,
    completion: @escaping (Result<Credential, Error>) -> Void)
  func removeFromMonitoredEmails(email: String)
  func monitorNew(email: String) async throws
}

public class DarkWebMonitoringService: DarkWebMonitoringServiceProtocol {
  public func removeFromMonitoredEmails(email: String) {
    identityDashboardService.removeFromMonitoredEmails(email: email)
  }

  public func monitorNew(email: String) async throws {
    try await identityDashboardService.monitorNew(email: email)
  }

  public var isDwmEnabled: Bool {
    return capabilityService.status(of: .dataLeak).isAvailable
  }

  public var maxMonitoredEmails = 5

  public let identityDashboardService: IdentityDashboardServiceProtocol
  let deepLinkingService: DeepLinkingService

  private let iconService: IconServiceProtocol
  private let personalDataURLDecoder: PersonalDataURLDecoderProtocol
  private let vaultItemDatabase: VaultItemDatabaseProtocol
  private let capabilityService: CapabilityServiceProtocol
  private let userSpacesService: UserSpacesService
  private let activityReporter: ActivityReporterProtocol

  let userSettings: UserSettings

  private let breachContentDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return decoder
  }()

  @Published private(set) var monitoredEmails: [DataLeakEmail] = []
  @Published private(set) var breaches: [DWMSimplifiedBreach] = []

  public var monitoredEmailsPublisher: AnyPublisher<[DataLeakEmail], Never> {
    return $monitoredEmails.eraseToAnyPublisher()
  }

  public var breachesPublisher: AnyPublisher<[DWMSimplifiedBreach], Never> {
    return $breaches.eraseToAnyPublisher()
  }

  private var subscriptions = Set<AnyCancellable>()

  init(
    iconService: IconServiceProtocol,
    identityDashboardService: IdentityDashboardServiceProtocol,
    personalDataURLDecoder: PersonalDataURLDecoderProtocol,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    capabilityService: CapabilityServiceProtocol,
    deepLinkingService: DeepLinkingService,
    userSpacesService: UserSpacesService,
    activityReporter: ActivityReporterProtocol,
    userSettings: UserSettings
  ) {
    self.iconService = iconService
    self.identityDashboardService = identityDashboardService
    self.personalDataURLDecoder = personalDataURLDecoder
    self.vaultItemDatabase = vaultItemDatabase
    self.capabilityService = capabilityService
    self.deepLinkingService = deepLinkingService
    self.userSpacesService = userSpacesService
    self.userSettings = userSettings
    self.activityReporter = activityReporter

    updateMonitoredEmails(completion: { _ in })
    subscribeToMonitoredEmails()
    subscribeToBreaches()
  }

  public typealias Email = String

  public func register(email: DarkWebMonitoringService.Email) -> AnyPublisher<
    DarkWebMonitoringService.Email, DWMEmailRegistrationError
  > {
    let email = CoreTypes.Email(email)
    guard email.isValid else {
      return Fail(error: .incorrectEmail).eraseToAnyPublisher()
    }

    return Future<String, DWMEmailRegistrationError> { promise in
      Task {
        do {
          _ = try await self.identityDashboardService
            .registerEmail(email: email.address)
          self.updateMonitoredEmails(completion: { _ in })
          promise(.success(email.address))
        } catch {
          if error.isConnectionError {
            promise(.failure(.connectionError))
          } else {
            promise(.failure(.unexpectedError(error)))
          }
        }
      }
    }.eraseToAnyPublisher()
  }

  public func updateMonitoredEmails(
    completion: @escaping ((Result<DataLeakStatusResponse, Error>) -> Void)
  ) {
    identityDashboardService.updateMonitoredEmails { result in
      completion(result)
    }
  }

  private func decryptorPublisher() -> AnyPublisher<DataLeakInformationDecryptor?, Never> {
    identityDashboardService.decryptorPublisher
      .filter { $0 != nil }
      .timeout(.seconds(3), scheduler: DispatchQueue.main)
      .replaceEmpty(with: nil)
      .eraseToAnyPublisher()
  }

  public func correspondingCredentials(for breach: DWMSimplifiedBreach) -> [Credential] {
    guard
      let credentials = identityDashboardService.credentials(forBreachId: breach.breachId)
        as? [SecurityDashboardCredentialImplementation]
    else {
      return []
    }
    return credentials.map(\.credential)
  }
}

extension DarkWebMonitoringService {
  public func refresh() {
    updateMonitoredEmails(completion: { _ in })
  }

  public func delete(_ breach: DWMSimplifiedBreach) {
    breaches.removeAll { $0 == breach }
    Task {
      await identityDashboardService.mark(breaches: [breach.breachId], as: .acknowledged)
    }
    reportDismissed(breach)
  }

  public func viewed(_ breach: DWMSimplifiedBreach) {
    Task {
      await identityDashboardService.mark(breaches: [breach.breachId], as: .viewed)
    }
  }

  public func solved(_ breach: DWMSimplifiedBreach) {
    Task {
      await identityDashboardService.mark(breaches: [breach.breachId], as: .solved)
    }
  }

  private func reportDismissed(_ breach: DWMSimplifiedBreach) {
    self.activityReporter.report(
      UserEvent.DismissSecurityAlert(
        itemTypesAffected: [.securityBreach],
        securityAlertItemId: breach.breachId.id, securityAlertType: .darkWeb))
  }
}

extension DarkWebMonitoringService {
  public func saveNewPassword(
    for credential: Credential, newPassword: String,
    completion: @escaping (Result<Credential, Error>) -> Void
  ) {
    var updatedCredential = credential
    updatedCredential.password = newPassword
    let now = Date()
    updatedCredential.userModificationDatetime = now
    updatedCredential.passwordModificationDate = now

    DispatchQueue.main.async {
      do {
        completion(.success(try self.vaultItemDatabase.save(updatedCredential)))
      } catch let error {
        completion(.failure(error))
      }
    }
  }
}

extension DarkWebMonitoringService {
  fileprivate func subscribeToMonitoredEmails() {
    identityDashboardService.monitoredEmailsPublisher
      .map { $0.ordered() }
      .assign(to: \.monitoredEmails, on: self).store(in: &subscriptions)
  }

  fileprivate func subscribeToBreaches() {
    identityDashboardService.breachesPublisher.sink { [weak self] breaches in
      guard let self = self else { return }
      let simplifiedBreaches =
        breaches
        .compactMap(self.convertToDWMSimplifiedBreach)
        .sorted()
      self.breaches = simplifiedBreaches
    }
    .store(in: &subscriptions)
  }
}

extension DarkWebMonitoringService {
  fileprivate func convertToDWMSimplifiedBreach(_ breach: SecurityDashboard.StoredBreach)
    -> DWMSimplifiedBreach?
  {
    guard breach.status != .acknowledged else { return nil }
    guard breach.breach.kind == .dataLeak else { return nil }

    guard let url = breach.breach.domains().first,
      let decodedUrl = try? personalDataURLDecoder.decodeURL(url)
    else {
      return nil
    }

    let otherLeakedData = self.otherLeakedData(from: breach.breach.leakedData())

    return DWMSimplifiedBreach(
      breachId: breach.breachID,
      url: decodedUrl,
      leakedPassword: breach.leakedPasswords.first,
      date: breach.breach.eventDate?.dateValue,
      email: breach.breach.impactedEmails.first,
      otherLeakedData: otherLeakedData,
      status: breach.status
    )
  }

  fileprivate func otherLeakedData(from leakedData: [LeakedData]?) -> [String]? {
    guard let data = leakedData else { return nil }

    return data.compactMap {
      switch $0 {
      case .username:
        return L10n.Localizable.securityBreachLeakedUsername
      case .email:
        return L10n.Localizable.securityBreachLeakedEmail
      case .password:
        return L10n.Localizable.securityBreachLeakedPassword
      case .social:
        return L10n.Localizable.securityBreachLeakedSocial
      case .ssn:
        return L10n.Localizable.securityBreachLeakedSsn
      case .address:
        return L10n.Localizable.securityBreachLeakedAddress
      case .creditCard:
        return L10n.Localizable.securityBreachLeakedCreditCard
      case .phoneNumber:
        return L10n.Localizable.securityBreachLeakedPhoneNumber
      case .ip:
        return L10n.Localizable.securityBreachLeakedIp
      case .geolocation:
        return L10n.Localizable.securityBreachLeakedGeolocation
      case .personalInfo:
        return L10n.Localizable.securityBreachLeakedPersonalInfo
      case .unknown:
        return nil
      }
    }
  }
}

struct DarkWebMonitoringServiceMock: DarkWebMonitoringServiceProtocol {
  func removeFromMonitoredEmails(email: String) {

  }

  func monitorNew(email: String) async throws {

  }

  var maxMonitoredEmails: Int = 5
  var isDwmEnabled: Bool = true

  var monitoredEmailsPublisher: AnyPublisher<[DataLeakEmail], Never> = PassthroughSubject<
    [DataLeakEmail], Never
  >().eraseToAnyPublisher()
  var breachesPublisher: AnyPublisher<[DWMSimplifiedBreach], Never> = PassthroughSubject<
    [DWMSimplifiedBreach], Never
  >().eraseToAnyPublisher()

  func register(email: DarkWebMonitoringService.Email) -> AnyPublisher<
    String, DWMEmailRegistrationError
  > {
    PassthroughSubject<String, DWMEmailRegistrationError>().eraseToAnyPublisher()
  }

  func updateMonitoredEmails(completion: (Result<DataLeakStatusResponse, Error>) -> Void) {
    completion(.success(.init(emails: [])))
  }

  func correspondingCredentials(for breach: DWMSimplifiedBreach) -> [Credential] {
    return []
  }

  var identityDashboardService: IdentityDashboardServiceProtocol = IdentityDashboardService.mock

  func refresh() {
  }

  func delete(_ breach: DWMSimplifiedBreach) {
  }

  func viewed(_ breach: DWMSimplifiedBreach) {
  }

  func solved(_ breach: DWMSimplifiedBreach) {
  }

  func saveNewPassword(
    for credential: CorePersonalData.Credential, newPassword: String,
    completion: @escaping (Result<CorePersonalData.Credential, Error>) -> Void
  ) {
    completion(.success(credential))
  }
}

extension DarkWebMonitoringServiceProtocol where Self == DarkWebMonitoringServiceMock {
  static func mockAvailable() -> DarkWebMonitoringServiceProtocol {
    return DarkWebMonitoringServiceMock(isDwmEnabled: true)
  }

  static func mockUnavailable() -> DarkWebMonitoringServiceProtocol {
    return DarkWebMonitoringServiceMock(isDwmEnabled: false)
  }
}
