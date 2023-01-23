import Foundation
import CorePersonalData
import SecurityDashboard
import Combine
import DashTypes

protocol BreachesListViewModelProtocol: ObservableObject {
    var pendingBreaches: [DWMSimplifiedBreach] { get }
    var securedItems: [Credential] { get }

    func logDisplay()
    func breachesViewed()
    func makeRowViewModel(_ breach: DWMSimplifiedBreach) -> BreachViewModel
    func makeRowViewModel(_ credential: Credential) -> BreachViewModel
    func select(_ breach: DWMSimplifiedBreach)
    func select(_ credential: Credential)
    func delete(_ breach: DWMSimplifiedBreach)
}

class BreachesListViewModel: BreachesListViewModelProtocol, SessionServicesInjecting {

    enum Completion {
        case breachSelected(DWMSimplifiedBreach)
        case securedItemSelected(Credential)
    }

    @Published
    var pendingBreaches: [DWMSimplifiedBreach] = []

    @Published
    var securedItems: [Credential] = []

    var dwmOnboardingService: DWMOnboardingService
    var completion: (Completion) -> Void

    private let usageLogService: DWMLogService
    private let breachRowProvider: (DWMSimplifiedBreach) -> BreachViewModel
    private let credentialRowProvider: (Credential) -> BreachViewModel
    private var cancellables = Set<AnyCancellable>()

    init(dwmOnboardingService: DWMOnboardingService,
         usageLogService: UsageLogServiceProtocol,
         breachRowProvider: @escaping (DWMSimplifiedBreach) -> BreachViewModel,
         credentialRowProvider: @escaping (Credential) -> BreachViewModel,
         completion: @escaping (BreachesListViewModel.Completion) -> Void) {
        self.dwmOnboardingService = dwmOnboardingService
        self.pendingBreaches = dwmOnboardingService.pendingBreaches
        self.breachRowProvider = breachRowProvider
        self.credentialRowProvider = credentialRowProvider
        self.completion = completion
        self.usageLogService = usageLogService.dwmLogService

        self.dwmOnboardingService.$pendingBreaches.assign(to: \.pendingBreaches, on: self).store(in: &cancellables)
        self.dwmOnboardingService.securedItemsPublisher().assign(to: \.securedItems, on: self).store(in: &cancellables)
    }

    func logDisplay() {
        usageLogService.log(.breachesListDisplayed)
    }

    func breachesViewed() {
        dwmOnboardingService.breachesViewed()
    }

    func select(_ breach: DWMSimplifiedBreach) {
        completion(.breachSelected(breach))
    }

    func select(_ credential: Credential) {
        completion(.securedItemSelected(credential))
    }

    func delete(_ breach: DWMSimplifiedBreach) {
        usageLogService.log(.breachesListItemDeleted(domain: breach.url.displayDomain))
        dwmOnboardingService.remove(breach)
    }

    func makeRowViewModel(_ breach: DWMSimplifiedBreach) -> BreachViewModel {
        return breachRowProvider(breach)
    }

    func makeRowViewModel(_ credential: Credential) -> BreachViewModel {
        return credentialRowProvider(credential)
    }
}
