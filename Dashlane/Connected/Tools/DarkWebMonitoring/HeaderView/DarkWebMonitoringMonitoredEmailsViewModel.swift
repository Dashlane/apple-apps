import Foundation
import CorePersonalData
import Combine
import SecurityDashboard
import DashlaneAppKit
import VaultKit
import DashTypes

protocol DarkWebMonitoringMonitoredEmailsViewModelProtocol: ObservableObject {
    var registeredEmails: [DataLeakEmail] { get }
    var status: DarkWebMonitoringMonitoredEmailsViewModel.Status { get }
    var isMonitoringEnabled: Bool { get }
    var numberOfEmailsMonitored: Int { get }
    var availableSpots: Int { get }
    var canAddEmail: Bool { get }
    var maxMonitoredEmails: Int { get }
    var shouldShowEmailSection: Bool { get set }

    func addEmail()
    func makeRowViewModel(email: DataLeakEmail) -> DarkWebMonitoringEmailRowViewModel
}

class DarkWebMonitoringMonitoredEmailsViewModel: DarkWebMonitoringMonitoredEmailsViewModelProtocol, SessionServicesInjecting {

    enum Status {
        case active 
        case pending 
        case inactive 
    }

    @Published
    var registeredEmails: [DataLeakEmail] = [] 

    @Published
    var shouldShowEmailSection: Bool = false

    var isMonitoringEnabled: Bool {
        return darkWebMonitoringService.isDwmEnabled
    }

    var status: Status {
        if registeredEmails.first(where: { $0.state == .disabled }) != nil {
            return .inactive
        } else if registeredEmails.count > 0 && registeredEmails.allSatisfy({ $0.state == .active }) {
            return .active
        } else {
            return .pending
        }
    }

    var numberOfEmailsMonitored: Int {
        return registeredEmails.filter({ $0.state == .active }).count
    }

    var canAddEmail: Bool {
        return registeredEmails.count < maxMonitoredEmails
    }

    var maxMonitoredEmails: Int {
        return darkWebMonitoringService.maxMonitoredEmails
    }

    var availableSpots: Int {
        return maxMonitoredEmails - registeredEmails.count
    }

    private let actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
    private let iconService: IconServiceProtocol

    private var darkWebMonitoringService: DarkWebMonitoringServiceProtocol
    private var subscriptions = Set<AnyCancellable>()

    init(darkWebMonitoringService: DarkWebMonitoringServiceProtocol,
         iconService: IconServiceProtocol,
         actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>) {
        self.darkWebMonitoringService = darkWebMonitoringService
        self.iconService = iconService
        self.actionPublisher = actionPublisher

        subscribeToMonitoredEmails()
    }

    private func subscribeToMonitoredEmails() {
        darkWebMonitoringService.monitoredEmailsPublisher.assign(to: \.registeredEmails, on: self).store(in: &subscriptions)
        darkWebMonitoringService.monitoredEmailsPublisher.sink { [weak self] emails in
            guard let self = self else {
                return
            }
            self.shouldShowEmailSection = emails.allSatisfy { $0.state == .pending } || emails.allSatisfy { $0.state == .disabled } || self.shouldShowEmailSection
        }.store(in: &subscriptions)
    }

    func makeRowViewModel(email: DataLeakEmail) -> DarkWebMonitoringEmailRowViewModel {
        return DarkWebMonitoringEmailRowViewModel(email: email, iconService: iconService, actionPublisher: actionPublisher)
    }

    func addEmail() {
        actionPublisher.send(.addEmail)
    }
}

extension DarkWebMonitoringMonitoredEmailsViewModel {
    static var mock: DarkWebMonitoringMonitoredEmailsViewModel {
        .init(darkWebMonitoringService: DarkWebMonitoringServiceMock(),
              iconService: IconServiceMock(), actionPublisher: .init())
    }
}

class FakeDarkWebMonitoringMonitoredEmailsViewModel: DarkWebMonitoringMonitoredEmailsViewModelProtocol {
    var registeredEmails: [DataLeakEmail] = [DataLeakEmail("_")]
    var status: DarkWebMonitoringMonitoredEmailsViewModel.Status = .active
    var isMonitoringEnabled: Bool = true
    var numberOfEmailsMonitored: Int = 1
    var availableSpots: Int = 4
    var canAddEmail: Bool = true
    var maxMonitoredEmails: Int = 5
    var shouldShowEmailSection: Bool = false

    init(shouldShowEmailSection: Bool) {
        self.shouldShowEmailSection = shouldShowEmailSection
    }

    func addEmail() {}
    func makeRowViewModel(email: DataLeakEmail) -> DarkWebMonitoringEmailRowViewModel {
        return DarkWebMonitoringEmailRowViewModel(email: email, iconService: IconServiceMock(), actionPublisher: .init())
    }
}
