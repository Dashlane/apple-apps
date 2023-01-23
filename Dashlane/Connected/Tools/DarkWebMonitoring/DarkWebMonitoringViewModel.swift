import Foundation
import Combine
import SecurityDashboard
import VaultKit
import DashTypes

class DarkWebMonitoringViewModel: ObservableObject, SessionServicesInjecting {

    let headerViewModelFactory: DarkWebMonitoringMonitoredEmailsViewModel.Factory
    let listViewModelFactory: DarkWebMonitoringBreachListViewModel.Factory

        var shouldShowIntroScreen: Bool {
        return (registeredEmails.count == 0 && darkWebMonitoringService.isDwmEnabled) || darkWebMonitoringService.isDwmEnabled == false
    }

        @Published private(set) var registeredEmails: [DataLeakEmail] = []

        @Published private(set) var monitoredEmails: [DataLeakEmail] = []

    private let iconService: IconServiceProtocol
    let darkWebMonitoringService: DarkWebMonitoringServiceProtocol
    let actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
    private var cancellables = Set<AnyCancellable>()

    init(darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
         headerViewModelFactory: DarkWebMonitoringMonitoredEmailsViewModel.Factory,
         listViewModelFactory: DarkWebMonitoringBreachListViewModel.Factory,
         actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never> = .init(),
         iconService: IconServiceProtocol) {
        self.darkWebMonitoringService = darkWebMonitoringService
        self.headerViewModelFactory = headerViewModelFactory
        self.listViewModelFactory = listViewModelFactory
        self.iconService = iconService
        self.actionPublisher = actionPublisher

        self.darkWebMonitoringService.monitoredEmailsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.registeredEmails, on: self)
            .store(in: &cancellables)

        self.darkWebMonitoringService.monitoredEmailsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] emails in
            self?.monitoredEmails = emails.filter({ $0.state == .active })
        }
            .store(in: &cancellables)
    }

    func addEmail() {
        actionPublisher.send(.addEmail)
    }
}

extension DarkWebMonitoringViewModel {
    static var mock: DarkWebMonitoringViewModel {
        .init(darkWebMonitoringService: DarkWebMonitoringServiceMock(),
              headerViewModelFactory: .init({ _ in .mock }),
              listViewModelFactory: .init({ _ in .mock() }),
              iconService: IconServiceMock())

    }
}
