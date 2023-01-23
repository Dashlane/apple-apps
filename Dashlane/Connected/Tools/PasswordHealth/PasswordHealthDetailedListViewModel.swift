import Combine
import CorePersonalData
import Foundation
import SecurityDashboard
import VaultKit

final class PasswordHealthDetailedListViewModel: ObservableObject, SessionServicesInjecting {

    let passwordHealthListViewModelFactory: PasswordHealthListViewModel.Factory
    let passwordHealthService: IdentityDashboardServiceProtocol
    let teamSpaceService: TeamSpacesService

    let kind: PasswordHealthKind
    let origin: PasswordHealthFlowViewModel.Origin

    @Published
    var credentialsCount: Int = 0

    lazy private(set) var listViewModel: PasswordHealthListViewModel = makeListViewModel()

    private var report: PasswordHealthReport? {
        didSet {
            updateData()
        }
    }

    private var reportCancellable: AnyCancellable?

    init(
        kind: PasswordHealthKind,
        origin: PasswordHealthFlowViewModel.Origin,
        passwordHealthListViewModelFactory: PasswordHealthListViewModel.Factory,
        passwordHealthService: IdentityDashboardServiceProtocol,
        teamSpaceService: TeamSpacesService
    ) {
        self.kind = kind
        self.origin = origin
        self.passwordHealthListViewModelFactory = passwordHealthListViewModelFactory
        self.passwordHealthService = passwordHealthService
        self.teamSpaceService = teamSpaceService

        registerHandlers()
        fetchReport()
    }

    private func registerHandlers() {
        reportCancellable = passwordHealthService
            .reportPublisher(spaceId: teamSpaceService.currentIdentityDashboardSpaceId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] report in
                self?.report = report
            }
    }

    private func fetchReport() {
        Task { @MainActor in
            report = await passwordHealthService.report(spaceId: teamSpaceService.currentIdentityDashboardSpaceId)
        }
    }

    private func updateData() {
        switch kind {
        case .weak:
            self.credentialsCount = report?.allCredentialsReport.countsByFilter[.weak] ?? 0
        case .reused:
            self.credentialsCount = report?.allCredentialsReport.countsByFilter[.reused] ?? 0
        case .compromised:
            self.credentialsCount = report?.allCredentialsReport.countsByFilter[.compromised] ?? 0
        case .excluded:
            self.credentialsCount = report?.allCredentialsReport.countsByFilter[.checked] ?? 0
        case .total:
            assertionFailure()
            self.credentialsCount = 0
        }
    }

    private func makeListViewModel() -> PasswordHealthListViewModel {
        passwordHealthListViewModelFactory.make(kind: kind, origin: origin)
    }
}

extension PasswordHealthDetailedListViewModel {
    static let mock: PasswordHealthDetailedListViewModel = .init(
        kind: .reused,
        origin: .identityDashboard,
        passwordHealthListViewModelFactory: .init { .mock(kind: $0, origin: $2) },
        passwordHealthService: IdentityDashboardService.mock,
        teamSpaceService: .mock()
    )
}
