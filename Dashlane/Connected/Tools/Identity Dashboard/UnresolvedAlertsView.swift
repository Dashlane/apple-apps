import UIKit
import SecurityDashboard
import CoreCategorizer
import DashlaneAppKit
import DashTypes
import SwiftUI
import DesignSystem

class UnresolvedAlertViewModel: SessionServicesInjecting {
    let logger: SecurityBreachLogger
    let service: IdentityDashboardServiceProtocol
    let deeplinkService: DeepLinkingServiceProtocol
    let passwordHealthFlowViewModelFactory: PasswordHealthFlowViewModel.Factory

    init(
        usageLogService: UsageLogServiceProtocol,
        identityDashboardService: IdentityDashboardServiceProtocol,
        deeplinkService: DeepLinkingServiceProtocol,
        passwordHealthFlowViewModelFactory: PasswordHealthFlowViewModel.Factory
    ) {
        self.logger = usageLogService.securityBreach
        self.service = identityDashboardService
        self.deeplinkService = deeplinkService
        self.passwordHealthFlowViewModelFactory = passwordHealthFlowViewModelFactory
    }

    static var mock: UnresolvedAlertViewModel {
        .init(usageLogService: UsageLogService.fakeService,
              identityDashboardService: IdentityDashboardService.mock,
              deeplinkService: DeepLinkingService.fakeService,
              passwordHealthFlowViewModelFactory: .init({ _ in .mock }))
    }
}

struct UnresolvedAlertView: View {

    @Environment(\.dismiss)
    var dismiss

    let viewModel: UnresolvedAlertViewModel
    let alert: UnresolvedAlert

    init(viewModel: UnresolvedAlertViewModel, trayAlert: TrayAlertProtocol) {
        self.viewModel = viewModel
        self.alert = UnresolvedAlert(trayAlert)
    }

    var body: some View {
        List {
            cell(for: alert)
        }
        .navigationTitle(L10n.Localizable.actionItemBreachTitle)
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .reportPageAppearance(.notificationSecurityDetails)
    }

    @ViewBuilder
    func cell(for alert: UnresolvedAlert) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(asset: alert.alert.breach.kind == .default ? FiberAsset.securityBreachRegular : FiberAsset.securityBreachDataleak)
                VStack {
                    if let title = alert.title {
                        Text(AttributedString(title))
                            .font(.footnote)
                    }
                }
            }

            if let message = alert.message {
                Text(AttributedString(message))
            }

            if let actionable = alert.actionableMessage {
                Text(AttributedString(actionable.message))
                Image(uiImage: actionable.icon)
            }

            if let actionable = alert.postActionableMessage {
                Text(AttributedString(actionable))
            }

            Button(action: {
                view()
            }, label: {
                Text(L10n.Localizable.securityAlertViewButton)
                    .bold()
                    .foregroundColor(Color.ds.text.danger.quiet)
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    func view() {
        Task {
            await self.viewModel.service.mark(breaches: [alert.alert.breach.id], as: .acknowledged)
            _ = await self.viewModel.service.trayAlerts()
            _ = await MainActor.run {
                viewModel.deeplinkService.handleLink(.tool(.identityDashboard))
            }
        }
    }
}
