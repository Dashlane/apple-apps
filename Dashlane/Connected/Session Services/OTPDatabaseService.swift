import AuthenticatorKit
import Combine
import CorePersonalData
import CorePremium
import CoreTypes
import Foundation
import TOTPGenerator
import UserTrackingFoundation
import VaultKit

class OTPDatabaseService: AuthenticatorDatabaseServiceProtocol {
  let login: String?

  private let vaultItemsStore: VaultItemsStore
  private let vaultItemDatabase: VaultItemDatabaseProtocol
  private let activityReporter: ActivityReporterProtocol
  private let userSpacesService: UserSpacesService

  @Published
  public var codes: Set<OTPInfo> = []

  @Published
  var isLoaded = false

  var codesPublisher: AnyPublisher<Set<OTPInfo>, Never> {
    $codes.eraseToAnyPublisher()
  }

  var isLoadedPublisher: AnyPublisher<Bool, Never> {
    $isLoaded.eraseToAnyPublisher()
  }

  init(
    vaultItemsStore: VaultItemsStore,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    activityReporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService
  ) {
    self.vaultItemsStore = vaultItemsStore
    self.vaultItemDatabase = vaultItemDatabase
    self.activityReporter = activityReporter
    self.userSpacesService = userSpacesService
    self.login = nil
    load()
  }

  func delete(_ item: OTPInfo) throws {
    guard var credential = vaultItemsStore.credentials.first(where: { $0.id == item.id }) else {
      return
    }
    credential.otpURL = nil
    try _ = vaultItemDatabase.save(credential)
    let logCredential = credential
    activityReporter.report(
      AnonymousEvent.RemoveTwoFactorAuthenticationFromCredential(
        authenticatorIssuerId: item.authenticatorIssuerId,
        domain: logCredential.hashedDomainForLogs(), space: logCredential.userTrackingSpace))
    activityReporter.report(
      AnonymousEvent.UpdateCredential(
        action: .edit, domain: logCredential.hashedDomainForLogs(), fieldList: [.otpSecret],
        space: logCredential.userTrackingSpace))
  }

  func add(_ items: [OTPInfo]) throws {
    let credentials = items.map { info in
      var credential = Credential(info)
      credential.spaceId =
        userSpacesService.configuration.defaultSpace(for: credential).personalDataId
      return credential
    }

    try _ = vaultItemDatabase.save(credentials)
  }

  func update(_ item: OTPInfo) throws {
    let credential = vaultItemsStore.credentials.first { $0.id == item.id }

    guard var credential = credential else {
      return
    }
    credential.otpURL = item.configuration.otpURL
    try _ = vaultItemDatabase.save(credential)
  }

  func load() {
    vaultItemsStore.$credentials.map {
      return Set(
        $0.compactMap {
          OTPInfo(credential: $0, supportDashlane2FA: true)
        })
    }
    .handleEvents(receiveOutput: { [weak self] _ in
      self?.isLoaded = true
    })
    .assign(to: &$codes)
  }

}

extension OTPDatabaseService {
  static var mock: OTPDatabaseService {
    .init(
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
      activityReporter: .mock,
      userSpacesService: .mock()
    )
  }
}
