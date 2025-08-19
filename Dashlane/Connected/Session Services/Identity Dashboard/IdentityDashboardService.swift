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
import LogFoundation
import SecurityDashboard
import UIKit
import VaultKit

public class IdentityDashboardService: IdentityDashboardServiceProtocol {

  let session: SecurityDashboard.IdentityDashboardSession
  private let breachesStore: BreachesStore
  private let credentialsProvider: CredentialsProvider
  let logger: LogFoundation.Logger
  let notificationManager = IdentityDashboardNotificationManager()
  let passwordEvaluator: PasswordEvaluatorProtocol

  #if !os(visionOS)
    private(set) var widgetService = IdentityDashboardWidgetService()
  #endif
  private let userSpacesService: UserSpacesService

  @Published
  public var breaches: [StoredBreach] = []
  public var breachesPublisher: Published<[StoredBreach]>.Publisher { $breaches }

  @Published
  public var dataLeaksLastUpdate: DataLeaksUpdate = DataLeaksUpdate()
  public var dataLeaksLastUpdatePublisher:
    Published<IdentityDashboardService.DataLeaksUpdate>.Publisher
  { $dataLeaksLastUpdate }

  @Published
  public var dataLeaksUpdateRequested = PassthroughSubject<Void, Never>()
  public var dataLeaksUpdateRequestedPublisher: Published<PassthroughSubject<Void, Never>>.Publisher
  { $dataLeaksUpdateRequested }

  @Published
  public var breachesToPresent = [PopupAlertProtocol]()
  public var breachesToPresentPublisher: Published<[PopupAlertProtocol]>.Publisher {
    $breachesToPresent
  }

  @Published
  private(set) var decryptor: DataLeakInformationDecryptor?
  public var decryptorPublisher: Published<DataLeakInformationDecryptor?>.Publisher { $decryptor }

  public let dataLeakMonitoringRegisterService: DataLeakMonitoringRegisterServiceProtocol
  let notificationService: SessionNotificationService

  private var dataLeaksUpdatePublisher = PassthroughSubject<Void, Error>()
  private var sharingServiceCancellable: AnyCancellable?
  private var cancellables = Set<AnyCancellable>()

  public var monitoredEmails: Set<SecurityDashboard.DataLeakEmail> {
    dataLeakMonitoringRegisterService.monitoredEmails
  }

  public var monitoredEmailsPublisher: AnyPublisher<Set<SecurityDashboard.DataLeakEmail>, Never> {
    dataLeakMonitoringRegisterService.monitoredEmailsPublisher
  }

  public func publisher(
    for notification: SecurityDashboard.IdentityDashboardNotificationManager.NotificationType
  ) -> NotificationCenter.Publisher {
    notificationManager.publisher(for: notification)
  }

  init(
    session: Session,
    settings: LocalSettingsStore,
    userDeviceAPIClient: UserDeviceAPIClient,
    database: ApplicationDatabase,
    vaultItemsStore: VaultItemsStore,
    sharingKeysStore: SharingKeysStore,
    featureService: FeatureServiceProtocol,
    premiumStatusProvider: any PremiumStatusProvider,
    capabilityService: CapabilityServiceProtocol,
    userSpacesService: UserSpacesService,
    passwordEvaluator: PasswordEvaluatorProtocol,
    domainParser: DomainParserProtocol,
    categorizer: Categorizer,
    notificationService: SessionNotificationService,
    logger: LogFoundation.Logger
  ) {
    credentialsProvider = CredentialsProvider(
      vaultItemsStore: vaultItemsStore,
      passwordEvaluator: passwordEvaluator,
      domainParser: domainParser,
      categorizer: categorizer
    )

    breachesStore = BreachesStore(
      session: session,
      database: database,
      settings: settings,
      log: logger)
    dataLeakMonitoringRegisterService = DataLeakMonitoringRegisterService(
      userDeviceAPIClient: userDeviceAPIClient,
      notificationService: notificationService,
      logger: logger
    )

    let alertInfoProvider = BreachAlertsInfoProvider(
      capabilityService: capabilityService, premiumStatusProvider: premiumStatusProvider,
      featureService: featureService)
    let localizationProvider = IdentityDashboardLocalizationProvider()

    self.session = IdentityDashboardSession(
      credentialsProvider: credentialsProvider,
      breachesStore: breachesStore,
      userDeviceAPIClient: userDeviceAPIClient,
      alertsInformationProvider: alertInfoProvider,
      localizationProvider: localizationProvider,
      notificationManager: notificationManager,
      logger: logger)

    self.logger = logger

    self.notificationService = notificationService
    self.userSpacesService = userSpacesService
    self.passwordEvaluator = passwordEvaluator
    self.session.delegate = self

    guard !SafeMode.isEnabled else {
      return
    }

    setupBreachesSubscription()
    setupDataLeaksUpdateSubscription()

    configureFetchingUsingDataLeakInformationDecryptor(
      sharingKeysStore: sharingKeysStore,
      featureService: featureService)
  }

  private func configureFetchingUsingDataLeakInformationDecryptor(
    sharingKeysStore: SharingKeysStore,
    featureService: FeatureServiceProtocol
  ) {
    Task {
      guard let keyPair = await sharingKeysStore.keyPair() else {
        return
      }

      let decryptor = DataLeakInformationDecryptor(privateKey: keyPair.privateKey)
      for await credentials in self.session.credentialsPublisher.values {
        self.logger.debug("Breaches Decryptor ready, start refresh")
        self.decryptor = decryptor

        try? await self.session.fetchPublicBreachesAndDataLeaks(for: credentials, using: decryptor)
        self.logger.debug("Did refresh public and data leak breaches")
        self.configureFetchDataLeakOnEmailsChange(using: decryptor)
        self.configureFetchDataLeakOnRequest(using: decryptor)

        return
      }
    }

    self.session
      .$popupAlerts
      .receive(on: DispatchQueue.main)
      .sink { [weak self] alerts in
        guard let self = self,
          alerts.count != 0
        else { return }
        self.breachesToPresent = alerts

        guard !self.breachesToPresent.isEmpty else {
          return
        }

        if UIApplication.shared.applicationState == .background {
          self.sendLocalNotification()
        }
      }
      .store(in: &cancellables)
  }

  public func trayAlertsPublisher() -> AnyPublisher<[TrayAlertProtocol], Never> {
    session.trayAlertsPublisher()
  }

  func configureFetchDataLeakOnRequest(using decryptor: DataLeakInformationDecryptor?) {
    self.$dataLeaksUpdateRequested
      .combineLatest(self.session.credentialsPublisher)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _, credentials in
        guard let self = self else {
          return
        }

        Task.detached {
          try await self.session.fetchDataLeaks(for: credentials, using: decryptor)
        }
      }.store(in: &cancellables)
  }

  func configureFetchDataLeakOnEmailsChange(using decryptor: DataLeakInformationDecryptor?) {
    dataLeakMonitoringRegisterService.monitoredEmailsPublisher.removeDuplicates(by: {
      first, second in
      first.elementsEqual(second, by: { $0.email == $1.email && $0.state == $1.state })
    }).dropFirst()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self = self else {
          return
        }
        self.logger.debug("Emails did change, start refresh data leak")
        let credentials = credentialsProvider.fetchCredentials()
        Task.detached {
          try await self.session.fetchDataLeaks(for: credentials, using: decryptor)
          self.logger.debug("Did refresh data leak")
        }
      }.store(in: &cancellables)
  }

  private func setupBreachesSubscription() {
    self.session.$breaches
      .receive(on: DispatchQueue.main)
      .assign(to: &$breaches)
  }

  private func setupDataLeaksUpdateSubscription() {
    let emailsPublisher = dataLeakMonitoringRegisterService.monitoredEmailsPublisher
      .map { emails in
        emails.filter { DataLeakEmail.State(rawValue: $0.state) == .active }
      }

    self.session.dataLeaksUpdatePublisher()
      .map { _ -> Error? in
        return nil
      }
      .catch({ error -> AnyPublisher<Error?, Never> in
        return Just<Error?>(error).setFailureType(to: Never.self).eraseToAnyPublisher()
      })
      .combineLatest(emailsPublisher)
      .map { updateError, emails in
        return DataLeaksUpdate(emails: emails, error: updateError)
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$dataLeaksLastUpdate)
  }

  deinit {
    logger.debug("deinit")
    NotificationCenter.default.removeObserver(self)

    self.session.finish {}
  }
}

extension IdentityDashboardService {
  public func report(spaceId: String?, completion: @escaping (PasswordHealthReport) -> Void) {
    session.report(spaceId: spaceId, onCompletion: completion)
  }

  public func report(spaceId: String?) async -> PasswordHealthReport {
    return await withCheckedContinuation { continuation in
      session.report(spaceId: spaceId) {
        continuation.resume(with: .success($0))
      }
    }
  }

  public func data(
    for requests: [PasswordHealthAnalyzer.Request],
    completion: @escaping ([PasswordHealthAnalyzer.Request: PasswordHealthResult]) -> Void
  ) {
    session.data(for: requests, onCompletion: completion)
  }

  public func data(for request: PasswordHealthAnalyzer.Request) async -> PasswordHealthResult {
    return await session.data(for: request)
  }

  public func data(for requests: [PasswordHealthAnalyzer.Request]) async -> [PasswordHealthAnalyzer
    .Request: PasswordHealthResult]
  {
    return await session.data(for: requests)
  }

  public func numberOfTimesPasswordIsReused(
    of credential: Credential, completion: @escaping (Int) -> Void
  ) {
    session.numberOfTimesPasswordIsReused(password: credential.password, onCompletion: completion)
  }

  public func reusedCredentials(in credentials: [Credential]) -> AnyPublisher<[Credential], Never> {
    return self.session.reusedCredentials().map { credentialIds -> [Credential] in
      return credentials.filter { credentialIds.contains($0.id.rawValue) }
    }.eraseToAnyPublisher()
  }

  public func isCompromised(_ credential: Credential, completion: @escaping (Bool) -> Void) {
    session.isCredentialCompromised(credentialID: credential.id.rawValue, onCompletion: completion)
  }

  public func compromisedCredentials(in credentials: [Credential]) -> AnyPublisher<
    [Credential], Never
  > {
    return self.session.compromisedCredentials().map { credentialIds -> [Credential] in
      return credentials.filter { credentialIds.contains($0.id.rawValue) }
    }.eraseToAnyPublisher()
  }

  public func trayAlerts() async -> [TrayAlertProtocol] {
    await session.trayAlerts()
  }

  public func mark(breaches: [BreachesService.Identifier], as status: StoredBreach.Status) async {
    await session.mark(breaches: breaches, as: status)
  }

  public func credentials(forBreachId breachId: String) -> [SecurityDashboardCredential] {
    return session.credentials(forBreachId: breachId)
  }

  public func registerEmail(email: String) async throws {
    try await dataLeakMonitoringRegisterService.webService.registerEmail(email: email)
  }

  public func updateMonitoredEmails(
    onCompletion: ((Result<SecurityDashboard.DataLeakStatusResponse, any Error>) -> Void)?
  ) {
    dataLeakMonitoringRegisterService.updateMonitoredEmails(onCompletion: onCompletion)
  }

  public func removeFromMonitoredEmails(email: String) {
    dataLeakMonitoringRegisterService.removeFromMonitoredEmails(email: email)
  }

  public func monitorNew(email: String) async throws {
    try await dataLeakMonitoringRegisterService.monitorNew(email: email)
  }

}

extension IdentityDashboardService {

  public func reportPublisher(spaceId: String?) -> AnyPublisher<PasswordHealthReport, Never> {
    return session.report(spaceId: spaceId)
  }

  public func dataPublisher(for request: PasswordHealthAnalyzer.Request) -> AnyPublisher<
    PasswordHealthResult, Never
  > {
    return session.data(for: request)
  }

  public func dataPublisher(for requests: [PasswordHealthAnalyzer.Request]) -> AnyPublisher<
    [PasswordHealthAnalyzer.Request: PasswordHealthResult], Never
  > {
    return session.data(for: requests)
  }
}

extension IdentityDashboardService {
  public struct DataLeaksUpdate {
    let emails: Set<DataLeakEmail>
    let error: Error?

    init(emails: Set<DataLeakEmail> = [], error: Error? = nil) {
      self.emails = emails
      self.error = error
    }
  }
}

extension IdentityDashboardService {

  public func vaultSnapshot(for credentials: [Credential]) async
    -> [UserSecureNitroEncryptionAPIClient.Uvvs.UploadUserSnapshot.Body.UvvsElement]
  {
    await credentials
      .asyncMap {
        return UserSecureNitroEncryptionAPIClient.Uvvs.UploadUserSnapshot.Body.UvvsElement.init(
          id: $0.id.rawValue, domain: $0.url?.domain?.name ?? "",
          creationDateUnix: Int(Date().timeIntervalSince1970))
      }
  }
}
