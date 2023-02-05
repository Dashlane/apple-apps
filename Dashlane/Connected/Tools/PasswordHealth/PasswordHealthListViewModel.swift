import Combine
import CorePersonalData
import DashlaneReportKit
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
    let usageLogService: UsageLogServiceProtocol
    let vaultItemsService: VaultItemsServiceProtocol
    let teamSpaceService: TeamSpacesService

    @Published
    var credentials: [Credential] = []

    let kind: PasswordHealthKind
    var allCredentials: [Credential] = []
    let showSectionHeader: Bool
    let maximumCredentialsCount: Int?

    var showAllButtonState: ShowAllButtonState {
        .init(credentialsCount: allCredentials.count, maximumCredentials: maximumCredentialsCount)
    }

    private let vaultItemRowModelFactory: VaultItemRowModel.Factory
    private var score: Int?
    private var reportCancellable: AnyCancellable?
    private var dataCancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []

    init(
        kind: PasswordHealthKind,
        maximumCredentialsCount: Int? = nil,
        passwordHealthService: IdentityDashboardServiceProtocol,
        origin: PasswordHealthFlowViewModel.Origin,
        usageLogService: UsageLogServiceProtocol,
        vaultItemsService: VaultItemsServiceProtocol,
        teamSpaceService: TeamSpacesService,
        vaultItemRowModelFactory: VaultItemRowModel.Factory
    ) {
        self.kind = kind
        self.maximumCredentialsCount = maximumCredentialsCount
        self.showSectionHeader = maximumCredentialsCount != nil
        self.passwordHealthService = passwordHealthService
        self.origin = origin
        self.usageLogService = usageLogService
        self.vaultItemsService = vaultItemsService
        self.teamSpaceService = teamSpaceService
        self.vaultItemRowModelFactory = vaultItemRowModelFactory

        registerHandlers()
    }

    private func updateSpaceHandlers(spaceId: String?) {
        reportCancellable = passwordHealthService
            .reportPublisher(spaceId: spaceId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] report in
                guard report.score != self?.score else { return }
                self?.score = report.score
            }

        dataCancellable = passwordHealthService
            .dataPublisher(for: makeRequest(spaceId: spaceId))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateCredentials(with: data.elements.convertToCredentials())
            }

        fetchData(spaceId: spaceId)
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
        return await passwordHealthService.data(for: makeRequest(spaceId: spaceId)).elements.convertToCredentials()
    }

    func vaultItemRowModel(for credential: Credential) -> VaultItemRowModel {
        vaultItemRowModelFactory.make(
            configuration: .init(item: credential, isSuggested: false),
            additionalConfiguration: .init(quickActionsEnabled: false, shouldShowSpace: false)
        )
    }

        func exclude(credential: Credential) {
        var credential = credential
        if credential.disabledForPasswordAnalysis {
            usageLogger.logInclude(credential)
        } else {
            usageLogger.logExclude(credential)
        }
        credential.disabledForPasswordAnalysis.toggle()
        _ = try? vaultItemsService.save(credential)
    }

    func replace(credential: Credential) {
        guard let url = credential.url?.openableURL else { return }
        UIApplication.shared.open(url)
        usageLogger.logReplace(credential)
    }
}

extension PasswordHealthListViewModel {
    private var usageLogger: SecurityDashboardLogger {
        return SecurityDashboardLogger(
            usageLogService: usageLogService,
            type: logSubType,
            spaceId: teamSpaceService.currentIdentityDashboardSpaceId
        )
    }

    private var logSubType: UsageLogCode125PasswordHealthDashboard.Type_subType {
        switch kind {
        case .compromised:
            return .compromiseAll
        case .weak:
            return .weakAll
        case .reused:
            return .reusedAll
        case .excluded:
            return .excludedAll
        case .total:
            return .manageAccount
        }
    }

    func logDetailedList() {
        guard let score else { return }
        usageLogger.logShow(forScore: score, origin: origin.rawValue)
    }

    func logOpenDetails(for credential: Credential) {
        usageLogger.logOpenDetails(of: credential)
    }
}

private extension Array where Element == SecurityDashboardCredential {
    func convertToCredentials() -> [Credential] {
        return self
            .compactMap { $0 as? SecurityDashboardCredentialImplementation }
            .map(\.credential)
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
            usageLogService: UsageLogService.fakeService,
            vaultItemsService: MockServicesContainer().vaultItemsService,
            teamSpaceService: .mock(),
            vaultItemRowModelFactory: .init { .mock(configuration: $0, additionalConfiguration: $1) }
        )
    }
}
