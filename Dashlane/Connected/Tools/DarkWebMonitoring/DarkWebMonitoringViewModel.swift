import Combine
import CoreTypes
import Foundation
import IconLibrary
import SecurityDashboard
import VaultKit

class DarkWebMonitoringViewModel: ObservableObject, SessionServicesInjecting {
  enum ViewState {
    case loading
    case intro
    case premium
    case enabled
  }

  let headerViewModelFactory: DarkWebMonitoringMonitoredEmailsViewModel.Factory
  let listViewModelFactory: DarkWebMonitoringBreachListViewModel.Factory

  @Published
  var viewState: ViewState = .loading

  private let iconService: IconServiceProtocol
  let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
  let actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  private var cancellables = Set<AnyCancellable>()

  init(
    darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
    headerViewModelFactory: DarkWebMonitoringMonitoredEmailsViewModel.Factory,
    listViewModelFactory: DarkWebMonitoringBreachListViewModel.Factory,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never> = .init(),
    iconService: IconServiceProtocol
  ) {
    self.darkWebMonitoringService = darkWebMonitoringService
    self.headerViewModelFactory = headerViewModelFactory
    self.listViewModelFactory = listViewModelFactory
    self.iconService = iconService
    self.actionPublisher = actionPublisher

    self.darkWebMonitoringService.monitoredEmailsPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] emailsList in
        guard let self else {
          return
        }

        if emailsList.isEmpty {
          if self.darkWebMonitoringService.isDwmEnabled {
            self.viewState = .intro
          } else {
            self.viewState = .premium
          }
        } else {
          self.viewState = .enabled
        }
      }
      .store(in: &cancellables)
  }

  func addEmail() {
    actionPublisher.send(.addEmail)
  }
}

extension DarkWebMonitoringViewModel {
  static var mock: DarkWebMonitoringViewModel {
    .init(
      darkWebMonitoringService: DarkWebMonitoringServiceMock(),
      headerViewModelFactory: .init({ _ in .mock }),
      listViewModelFactory: .init({ _ in .mock() }),
      iconService: IconServiceMock())

  }
}
