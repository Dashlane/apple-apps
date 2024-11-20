import CoreCategorizer
import DashTypes
import DesignSystem
import SecurityDashboard
import SwiftUI
import UIKit

@MainActor
class UnresolvedAlertViewModel: SessionServicesInjecting {
  let service: IdentityDashboardServiceProtocol
  let deeplinkService: DeepLinkingServiceProtocol
  let passwordHealthFlowViewModelFactory: PasswordHealthFlowViewModel.Factory

  init(
    identityDashboardService: IdentityDashboardServiceProtocol,
    deeplinkService: DeepLinkingServiceProtocol,
    passwordHealthFlowViewModelFactory: PasswordHealthFlowViewModel.Factory
  ) {
    self.service = identityDashboardService
    self.deeplinkService = deeplinkService
    self.passwordHealthFlowViewModelFactory = passwordHealthFlowViewModelFactory
  }

  static var mock: UnresolvedAlertViewModel {
    .init(
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
        Image(
          asset: alert.alert.breach.kind == .default
            ? FiberAsset.securityBreachRegular : FiberAsset.securityBreachDataleak
        )
        .accessibilityHidden(true)
        VStack {
          if let title = alert.title {
            Text(AttributedString(title))
              .font(.footnote)
          }
        }
      }

      Text(AttributedString(alert.message))

      if let actionable = alert.actionableMessage {
        Text(AttributedString(actionable.message))
        Image(uiImage: actionable.icon)
      }

      if let actionable = alert.postActionableMessage {
        Text(AttributedString(actionable))
      }

      Button(
        action: {
          Task { @MainActor in
            await view()
          }
        },
        label: {
          Text(L10n.Localizable.securityAlertViewButton)
            .bold()
            .foregroundColor(Color.ds.text.danger.quiet)
        }
      )
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }

  @MainActor
  func view() async {
    await viewModel.service.mark(breaches: [alert.alert.breach.id], as: .acknowledged)
    _ = await viewModel.service.trayAlerts()

    dismiss()
  }
}
