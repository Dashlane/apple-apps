import Combine
import CorePersonalData
import CorePremium
import Foundation
import SecurityDashboard
import UIKit
import VaultKit

final class PasswordHealthListViewModel: ObservableObject, SessionServicesInjecting {

  enum ShowAllButtonState {
    case hidden
    case shown(Int)

    init(credentialsCount: Int, maximumCredentials: Int?) {
      if let maximumCredentials, credentialsCount > maximumCredentials {
        self = .shown(credentialsCount)
      } else {
        self = .hidden
      }
    }
  }

  let passwordHealthService: IdentityDashboardServiceProtocol
  let origin: PasswordHealthFlowViewModel.Origin
  let vaultItemDatabase: VaultItemDatabaseProtocol
  let userSpacesService: UserSpacesService

  @Published
  var credentials: [Credential] = []

  let kind: PasswordHealthKind
  var allCredentials: [Credential] = []
  let showSectionHeader: Bool
  let maximumCredentialsCount: Int?

  var showAllButtonState: ShowAllButtonState {
    .init(credentialsCount: allCredentials.count, maximumCredentials: maximumCredentialsCount)
  }

  let rowViewFactory: PasswordHealthListRowView.Factory
  private var score: Int?
  private var reportCancellable: AnyCancellable?
  private var dataCancellable: AnyCancellable?
  private var cancellables: Set<AnyCancellable> = []

  init(
    kind: PasswordHealthKind,
    maximumCredentialsCount: Int? = nil,
    passwordHealthService: IdentityDashboardServiceProtocol,
    origin: PasswordHealthFlowViewModel.Origin,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    userSpacesService: UserSpacesService,
    rowViewFactory: PasswordHealthListRowView.Factory
  ) {
    self.kind = kind
    self.maximumCredentialsCount = maximumCredentialsCount
    self.showSectionHeader = maximumCredentialsCount != nil
    self.passwordHealthService = passwordHealthService
    self.origin = origin
    self.vaultItemDatabase = vaultItemDatabase
    self.userSpacesService = userSpacesService
    self.rowViewFactory = rowViewFactory

    registerHandlers()
  }

  private func updateSpaceHandlers(spaceId: String?) {
    reportCancellable =
      passwordHealthService
      .reportPublisher(spaceId: spaceId)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] report in
        guard report.score != self?.score else { return }
        self?.score = report.score
      }

    dataCancellable =
      passwordHealthService
      .dataPublisher(for: makeRequest(spaceId: spaceId))
      .receive(on: DispatchQueue.main)
      .sink { [weak self] data in
        self?.updateCredentials(with: data.elements.convertToCredentials())
      }

    fetchData(spaceId: spaceId)
  }

  private func registerHandlers() {
    userSpacesService.$configuration
      .receive(on: DispatchQueue.main)
      .sink { [weak self] configuration in
        self?.updateSpaceHandlers(spaceId: configuration.selectedSpace.identityDashboardSpaceId)
      }
      .store(in: &cancellables)

    updateSpaceHandlers(
      spaceId: userSpacesService.configuration.selectedSpace.identityDashboardSpaceId)
  }

  private func fetchData(spaceId: String?) {
    Task { @MainActor in
      score = await passwordHealthService.report(spaceId: spaceId).score
      updateCredentials(with: await credentials(spaceId: spaceId))
    }
  }

  private func updateCredentials(with credentials: [Credential]) {
    guard credentials != allCredentials else { return }
    if let maximumCredentialsCount {
      self.credentials = Array(credentials.prefix(maximumCredentialsCount))
    } else {
      self.credentials = credentials
    }
    allCredentials = credentials
  }

  private func makeRequest(spaceId: String?) -> PasswordHealthAnalyzer.Request {
    switch kind {
    case .weak:
      return .init(filtering: .weak, spaceID: spaceId)
    case .reused:
      return .init(filtering: .reused, spaceID: spaceId)
    case .compromised:
      return .init(filtering: .compromised, spaceID: spaceId)
    case .excluded:
      return .init(filtering: .checked, spaceID: spaceId)
    case .total:
      assertionFailure("Should not show any password health list for this kind")
      return .init(filtering: .weak, spaceID: spaceId)
    }
  }

  private func credentials(spaceId: String?) async -> [Credential] {
    return await passwordHealthService.data(for: makeRequest(spaceId: spaceId)).elements
      .convertToCredentials()
  }

  func exclude(credential: Credential) {
    var credential = credential
    credential.disabledForPasswordAnalysis.toggle()
    _ = try? vaultItemDatabase.save(credential)
  }

  func replace(credential: Credential) {
    guard let url = credential.url?.openableURL else { return }
    UIApplication.shared.open(url)
  }
}

extension Array where Element == SecurityDashboardCredential {
  fileprivate func convertToCredentials() -> [Credential] {
    return
      self
      .compactMap { $0 as? SecurityDashboardCredentialImplementation }
      .map(\.credential)
      .alphabeticallySorted()
  }
}

extension PasswordHealthListViewModel {
  static let mock: PasswordHealthListViewModel = .mock(kind: .reused, origin: .identityDashboard)

  static func mock(
    kind: PasswordHealthKind,
    maximumCredentialsCount: Int? = nil,
    origin: PasswordHealthFlowViewModel.Origin
  ) -> PasswordHealthListViewModel {
    .init(
      kind: kind,
      maximumCredentialsCount: maximumCredentialsCount,
      passwordHealthService: IdentityDashboardService.mock,
      origin: .identityDashboard,
      vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
      userSpacesService: .mock(),
      rowViewFactory: .init { item, _, _, _ in .mock(item: item) }
    )
  }
}
