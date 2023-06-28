import Combine
import CorePersonalData
import Foundation
import SecurityDashboard
import UIKit
import VaultKit
import CorePremium

final class PasswordHealthViewModel: ObservableObject, SessionServicesInjecting {

    struct SummaryItem {
        let kind: PasswordHealthKind
        let count: Int
    }

    let passwordHealthListViewModelFactory: PasswordHealthListViewModel.Factory
    let passwordHealthService: IdentityDashboardServiceProtocol
    let origin: PasswordHealthFlowViewModel.Origin
    let teamSpaceService: TeamSpacesService
    let userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory

    @Published
    var score: Int?

    @Published
    var summary: [SummaryItem] = []

    var currentKind: PasswordHealthKind = .total

    lazy var summaryListViewModels: [PasswordHealthListViewModel] = {
        return [.compromised, .reused, .weak, .excluded].map { makePasswordHealthListViewModel(kind: $0) }
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
        teamSpaceService: TeamSpacesService,
        userSpaceSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory
    ) {
        self.passwordHealthListViewModelFactory = passwordHealthListViewModelFactory
        self.passwordHealthService = passwordHealthService
        self.origin = origin
        self.teamSpaceService = teamSpaceService
        self.userSpaceSwitcherViewModelFactory = userSpaceSwitcherViewModelFactory
        self.score = nil

        registerHandlers()
    }

    private func updateSpaceHandlers(spaceId: String?) {
        reportCancellable = passwordHealthService
            .reportPublisher(spaceId: spaceId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] report in
                self?.report = report
            }

        updateReport()
    }

    private func registerHandlers() {
        if teamSpaceService.availableSpaces.count > 1 {
            teamSpaceService.$selectedSpace
                .sink { [weak self] space in
                    self?.updateSpaceHandlers(spaceId: space.identityDashboardSpaceId)
                }
                .store(in: &cancellables)
        }

        updateSpaceHandlers(spaceId: teamSpaceService.currentIdentityDashboardSpaceId)
    }

    private func updateReport() {
        Task { @MainActor in
            report = await passwordHealthService.report(spaceId: teamSpaceService.currentIdentityDashboardSpaceId)
        }
    }

    private func updateData() {
        score = report?.score
        summary = [
            .init(kind: .total, count: report?.allCredentialsReport.totalCount ?? 0),
            .init(kind: .compromised, count: report?.allCredentialsReport.countsByFilter[.compromised] ?? 0),
            .init(kind: .reused, count: report?.allCredentialsReport.countsByFilter[.reused] ?? 0),
            .init(kind: .weak, count: report?.allCredentialsReport.countsByFilter[.weak] ?? 0)
        ]
    }

    private func makePasswordHealthListViewModel(kind: PasswordHealthKind) -> PasswordHealthListViewModel {
        passwordHealthListViewModelFactory.make(kind: kind, maximumCredentialsCount: 5, origin: origin)
    }
}

extension PasswordHealthViewModel {
    static let mock: PasswordHealthViewModel = .init(
        passwordHealthListViewModelFactory: .init { .mock(kind: $0, maximumCredentialsCount: $1, origin: $2) },
        passwordHealthService: IdentityDashboardService.mock,
        origin: .identityDashboard,
        teamSpaceService: .mock(),
        userSpaceSwitcherViewModelFactory: .init({ .mock })
    )
}
