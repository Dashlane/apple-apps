import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import Foundation
import SecurityDashboard
import UIKit
import VaultKit

@MainActor
final class PasswordHealthViewModel: ObservableObject, SessionServicesInjecting {

  struct SummaryItem {
    let kind: PasswordHealthKind
    let count: Int
  }

  let passwordHealthListViewModelFactory: PasswordHealthListViewModel.Factory
  let passwordHealthService: IdentityDashboardServiceProtocol
  let origin: PasswordHealthFlowViewModel.Origin
  let vaultStateService: VaultStateServiceProtocol
  let deeplinkingService: DeepLinkingServiceProtocol
  let userSpacesService: UserSpacesService
  let userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory

  @Published
  var score: Int?

  @Published
  var summary: [SummaryItem] = []

  @Published
  var isFrozen: Bool = false

  var currentKind: PasswordHealthKind = .total

  lazy var summaryListViewModels: [PasswordHealthListViewModel] = {
    return [.compromised, .reused, .weak, .excluded].map {
      makePasswordHealthListViewModel(kind: $0)
    }
  }()

  var enoughDataToHaveAScore: Bool {
    return totalCredentials >= minimumPasswordsNeeded
  }

  var credentialsNeededToHaveAScore: Int {
    return minimumPasswordsNeeded - totalCredentials
  }

  var totalCredentials: Int {
    return report?.allCredentialsReport.totalCount ?? 0
  }

  private let minimumPasswordsNeeded: Int = 5
  private var report: PasswordHealthReport? {
    didSet {
      updateData()
    }
  }
  private var reportCancellable: AnyCancellable?
  private var cancellables: Set<AnyCancellable> = []

  init(
    passwordHealthListViewModelFactory: PasswordHealthListViewModel.Factory,
    passwordHealthService: IdentityDashboardServiceProtocol,
    origin: PasswordHealthFlowViewModel.Origin,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    userSpacesService: UserSpacesService,
    userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory
  ) {
    self.passwordHealthListViewModelFactory = passwordHealthListViewModelFactory
    self.passwordHealthService = passwordHealthService
    self.origin = origin
    self.vaultStateService = vaultStateService
    self.deeplinkingService = deeplinkingService
    self.userSpacesService = userSpacesService
    self.userSpaceSwitcherViewModelFactory = userSpaceSwitcherViewModelFactory
    self.score = nil

    registerHandlers()
  }

  private func updateSpaceHandlers(spaceId: String?) {
    reportCancellable =
      passwordHealthService
      .reportPublisher(spaceId: spaceId)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] report in
        self?.report = report
      }

    updateReport()
  }

  private func registerHandlers() {
    vaultStateService
      .vaultStatePublisher()
      .map { $0 == .frozen }
      .receive(on: DispatchQueue.main)
      .assign(to: &$isFrozen)

    userSpacesService.$configuration
      .receive(on: DispatchQueue.main)
      .sink { [weak self] configuration in
        self?.updateSpaceHandlers(spaceId: configuration.selectedSpace.identityDashboardSpaceId)
      }
      .store(in: &cancellables)

    updateSpaceHandlers(
      spaceId: userSpacesService.configuration.selectedSpace.identityDashboardSpaceId)
  }

  func displayPaywall() {
    deeplinkingService.handleLink(
      .premium(.planPurchase(initialView: .paywall(trigger: .frozenAccount))))
  }

  private func updateReport() {
    Task { @MainActor in
      report = await passwordHealthService.report(
        spaceId: userSpacesService.configuration.selectedSpace.identityDashboardSpaceId)
    }
  }

  private func updateData() {
    score = report?.score
    summary = [
      .init(kind: .total, count: report?.allCredentialsReport.totalCount ?? 0),
      .init(
        kind: .compromised, count: report?.allCredentialsReport.countsByFilter[.compromised] ?? 0),
      .init(kind: .reused, count: report?.allCredentialsReport.countsByFilter[.reused] ?? 0),
      .init(kind: .weak, count: report?.allCredentialsReport.countsByFilter[.weak] ?? 0),
    ]
  }

  private func makePasswordHealthListViewModel(kind: PasswordHealthKind)
    -> PasswordHealthListViewModel
  {
    passwordHealthListViewModelFactory.make(kind: kind, maximumCredentialsCount: 5, origin: origin)
  }
}

extension PasswordHealthViewModel {
  static let mock: PasswordHealthViewModel = .init(
    passwordHealthListViewModelFactory: .init {
      .mock(kind: $0, maximumCredentialsCount: $1, origin: $2)
    },
    passwordHealthService: IdentityDashboardService.mock,
    origin: .identityDashboard,
    vaultStateService: .mock,
    deeplinkingService: DeepLinkingService.fakeService,
    userSpacesService: .mock(),
    userSpaceSwitcherViewModelFactory: .init({ .mock })
  )
}
