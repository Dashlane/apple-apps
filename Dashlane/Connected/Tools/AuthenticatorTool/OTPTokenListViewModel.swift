import AuthenticatorKit
import Combine
import CorePersonalData
import CoreUserTracking
import DashTypes
import DomainParser
import Foundation
import IconLibrary
import UIKit
import VaultKit

@MainActor
class OTPTokenListViewModel: ObservableObject, SessionServicesInjecting {

  enum Action {
    case setupAuthentication
    case displayExplorer
  }

  private let databaseService: AuthenticatorDatabaseServiceProtocol
  private let domainParser: DomainParserProtocol
  private let domainIconLibrary: DomainIconLibraryProtocol
  private let actionHandler: (Action) -> Void
  private let activityReporter: ActivityReporterProtocol

  @Published
  var tokens = [OTPInfo]()

  init(
    activityReporter: ActivityReporterProtocol,
    authenticatorDatabaseService: OTPDatabaseService,
    domainParser: DomainParserProtocol,
    domainIconLibrary: DomainIconLibraryProtocol,
    actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void
  ) {
    self.domainIconLibrary = domainIconLibrary
    self.domainParser = domainParser
    self.databaseService = authenticatorDatabaseService
    self.actionHandler = actionHandler
    self.activityReporter = activityReporter
    databaseService.codesPublisher
      .map({ $0.sortedByIssuer() })
      .assign(to: &$tokens)
  }

  func makeTokenRowViewModel(for token: OTPInfo) -> TokenRowViewModel {
    return TokenRowViewModel(
      token: token, domainIconLibrary: domainIconLibrary, databaseService: databaseService,
      domainParser: domainParser)
  }

  func delete(item: OTPInfo) {
    try? databaseService.delete(item)
  }

  func startSetupOTPFlow() {
    actionHandler(.setupAuthentication)
  }

  func copy(_ code: String, for otpInfo: OTPInfo) {
    UIPasteboard.general.string = code
    activityReporter.report(
      UserEvent.CopyVaultItemField(
        field: .otpSecret,
        isProtected: false,
        itemId: otpInfo.id.rawValue,
        itemType: .credential))
    if let domain = otpInfo.configuration.issuer {
      activityReporter.report(
        AnonymousEvent.CopyVaultItemField(
          domain: domain.hashedDomainForLogs(),
          field: .otpSecret,
          itemType: .credential))
    }
  }

  func startExplorer() {
    actionHandler(.displayExplorer)
  }
}

extension OTPTokenListViewModel {
  static var mock: OTPTokenListViewModel {
    let mockServices = MockServicesContainer()
    _ = try? mockServices.database.save([
      PersonalDataMock.Credentials.github, PersonalDataMock.Credentials.amazon,
    ])
    return OTPTokenListViewModel(
      activityReporter: .mock,
      authenticatorDatabaseService: OTPDatabaseService(
        vaultItemsStore: MockVaultConnectedContainer().vaultItemsStore,
        vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
        activityReporter: .mock,
        userSpacesService: .mock()
      ),
      domainParser: FakeDomainParser(),
      domainIconLibrary: IconServiceMock().domain
    ) { _ in }
  }
}
