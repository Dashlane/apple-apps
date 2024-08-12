import Combine
import CoreUserTracking
import DashTypes
import SecurityDashboard
import UIKit

public enum BreachListType: Int, CaseIterable {
  case pending
  case solved

  var title: String {
    switch self {
    case .pending: return "Pending"
    case .solved: return "Solved"
    }
  }

  var storedBreachStatuses: [StoredBreach.Status] {
    switch self {
    case .pending: return [.pending, .acknowledged, .unknown, .viewed]
    case .solved: return [.solved]
    }
  }
}

class DarkWebMonitoringBreachListViewModel: ObservableObject, SessionServicesInjecting {
  @Published var breaches: [DWMSimplifiedBreach] = []
  @Published var registeredEmails: [DataLeakEmail] = []

  @Published var pendingBreachesCount: Int = 0

  @Published var solvedBreachesCount: Int = 0

  var actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?

  func shouldShowList() -> Bool {
    return registeredEmails.first(where: { DataLeakEmail.State(rawValue: $0.state) == .active })
      != nil
  }

  var isMonitoringAvailable: Bool {
    return darkWebMonitoringService.isDwmEnabled
  }

  private let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  private let breachRowProvider: (DWMSimplifiedBreach) -> BreachViewModel
  private var subscriptions = Set<AnyCancellable>()

  init(
    darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?,
    breachRowProvider: @escaping (DWMSimplifiedBreach) -> BreachViewModel
  ) {
    self.darkWebMonitoringService = darkWebMonitoringService
    self.breachRowProvider = breachRowProvider
    self.actionPublisher = actionPublisher
    self.activityReporter = activityReporter

    self.darkWebMonitoringService.breachesPublisher
      .receive(on: RunLoop.main)
      .assign(to: \.breaches, on: self)
      .store(in: &subscriptions)

    self.darkWebMonitoringService
      .breachesPublisher
      .receive(on: RunLoop.main)
      .map { $0.filter { $0.status == .solved }.count }
      .assign(to: \.solvedBreachesCount, on: self)
      .store(in: &subscriptions)

    self.darkWebMonitoringService
      .breachesPublisher
      .receive(on: RunLoop.main)
      .map { $0.filter { BreachListType.pending.storedBreachStatuses.contains($0.status) }.count }
      .assign(to: \.pendingBreachesCount, on: self)
      .store(in: &subscriptions)

    self.darkWebMonitoringService.monitoredEmailsPublisher
      .receive(on: RunLoop.main)
      .assign(to: \.registeredEmails, on: self)
      .store(in: &subscriptions)
  }

  func makeRowViewModel(_ breach: DWMSimplifiedBreach) -> BreachViewModel {
    return breachRowProvider(breach)
  }

  func delete(_ breach: DWMSimplifiedBreach) {
    darkWebMonitoringService.delete(breach)
  }

  func viewed(_ breach: DWMSimplifiedBreach) {
    darkWebMonitoringService.viewed(breach)
  }

  func solved(_ breach: DWMSimplifiedBreach) {
    darkWebMonitoringService.solved(breach)
  }

  func reportPendingBreaches() {
    let pendingBreaches = breaches.filter {
      BreachListType.pending.storedBreachStatuses.contains($0.status)
    }

    pendingBreaches.forEach {
      activityReporter.report(
        UserEvent.ReceiveSecurityAlert(
          itemTypesAffected: [.securityBreach],
          securityAlertItemId: $0.breachId,
          securityAlertType: .darkWeb))
    }
  }
}

extension DarkWebMonitoringBreachListViewModel {
  static func mock(breaches: [DWMSimplifiedBreach]? = nil, isMonitoringAvailable: Bool = true)
    -> DarkWebMonitoringBreachListViewModel
  {
    let model = DarkWebMonitoringBreachListViewModel(
      darkWebMonitoringService: DarkWebMonitoringServiceMock(isDwmEnabled: isMonitoringAvailable),
      activityReporter: .mock,
      actionPublisher: nil,
      breachRowProvider: { _ in .mock(for: .init()) })
    if let breaches {
      model.breaches = breaches
    }
    return model

  }
}
