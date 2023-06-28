import Combine
import CorePersonalData
import CoreUserTracking
import Foundation
import SecurityDashboard
import UIKit
import VaultKit

enum PasswordHealthKind {
    case `weak`
    case reused
    case compromised
    case excluded
    case total

    var title: String {
        switch self {
        case .weak:
            return L10n.Localizable.passwordHealthModuleWeak
        case .reused:
            return L10n.Localizable.passwordHealthModuleReused
        case .compromised:
            return L10n.Localizable.passwordHealthModuleCompromised
        case .excluded:
            return L10n.Localizable.securityDashboardMenuChecked
        case .total:
            return L10n.Localizable.passwordHealthModuleTotal
        }
    }

    var pageEvent: CoreUserTracking.Page {
        switch self {
        case .weak:
            return .toolsPasswordHealthListWeak
        case .reused:
            return .toolsPasswordHealthListReused
        case .compromised:
            return .toolsPasswordHealthListCompromised
        case .excluded:
            return .toolsPasswordHealthListExcluded
        case .total:
            return .toolsPasswordHealthList
        }
    }
}

final class PasswordHealthFlowViewModel: ObservableObject, SessionServicesInjecting {

    enum Origin: String {
        case identityDashboard = "identity_dashboard"
        case trayAlert = "tray_alert"
        case popupAlert = "popup_alert"
    }

    enum Step {
        case main(PasswordHealthViewModel)
        case detailedList(PasswordHealthDetailedListViewModel)
        case credentialDetail(CredentialDetailViewModel)
    }

    @Published
    var steps: [Step]

    let origin: Origin
    let deeplinkingService: DeepLinkingServiceProtocol
    let activityReporter: ActivityReporterProtocol

    let passwordHealthDetailedListViewModelFactory: PasswordHealthDetailedListViewModel.Factory
    let credentialDetailViewModelFactory: CredentialDetailViewModel.Factory

    init(
        passwordHealthViewModelFactory: PasswordHealthViewModel.Factory,
        passwordHealthDetailedListViewModelFactory: PasswordHealthDetailedListViewModel.Factory,
        credentialDetailViewModelFactory: CredentialDetailViewModel.Factory,
        deeplinkingService: DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        origin: PasswordHealthFlowViewModel.Origin
    ) {
        self.passwordHealthDetailedListViewModelFactory = passwordHealthDetailedListViewModelFactory
        self.credentialDetailViewModelFactory = credentialDetailViewModelFactory
        let passwordHealthViewModel = passwordHealthViewModelFactory.make(origin: origin)
        self.steps = [.main(passwordHealthViewModel)]
        self.origin = origin
        self.deeplinkingService = deeplinkingService
        self.activityReporter = activityReporter
    }

    func handleAction(_ action: PasswordHealthView.Action) {
        switch action {
        case .addPasswords:
            deeplinkingService.handleLink(.vault(.create(.credential)))
        case .detailedList(let kind):
            openDetailedList(for: kind)
        case .credentialDetail(let credential):
            openCredentialDetails(for: credential)
        }
    }

    private func openDetailedList(for kind: PasswordHealthKind) {
        guard kind != .total else { return }
        let viewModel = passwordHealthDetailedListViewModelFactory.make(kind: kind, origin: origin)
        steps.append(.detailedList(viewModel))
        activityReporter.reportPageShown(for: kind)
    }

    private func openCredentialDetails(for credential: Credential) {
        steps.append(
            .credentialDetail(
                credentialDetailViewModelFactory.make(
                    item: credential,
                    actionPublisher: .init()
                )
            )
        )
    }
}

fileprivate extension ActivityReporterProtocol {
    func reportPageShown(for filter: PasswordHealthKind) {
        switch filter {
        case .compromised:
            reportPageShown(.toolsPasswordHealthListCompromised)
        case .weak:
            reportPageShown(.toolsPasswordHealthListWeak)
        case .reused:
            reportPageShown(.toolsPasswordHealthListReused)
        case .excluded:
            reportPageShown(.toolsPasswordHealthListExcluded)
        case .total:
            assertionFailure("We should not show any \"total passwords\" password health page")
        }
    }
}

extension PasswordHealthFlowViewModel {
    static var mock: PasswordHealthFlowViewModel {
        return .init(
            passwordHealthViewModelFactory: .init({ _  in .mock }),
            passwordHealthDetailedListViewModelFactory: .init({ _, _ in .mock }),
            credentialDetailViewModelFactory: .init { _, _, _, _, _, _ in
                MockVaultConnectedContainer().makeCredentialDetailViewModel(
                    item: PersonalDataMock.Credentials.amazon,
                    mode: .viewing
                )
            },
            deeplinkingService: DeepLinkingService.fakeService,
            activityReporter: .fake,
            origin: .identityDashboard
        )
    }
}
