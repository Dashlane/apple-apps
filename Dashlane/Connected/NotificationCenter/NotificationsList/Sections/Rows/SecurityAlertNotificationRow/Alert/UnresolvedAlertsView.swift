import CoreCategorizer
import CoreTypes
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
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .reportPageAppearance(.notificationSecurityDetails)
  }

  @ViewBuilder
  func cell(for alert: UnresolvedAlert) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        BreachIcon(kind: alert.alert.breach.kind)
        VStack {
          if let title = alert.title {
            Text(title)
              .font(.footnote)
          }
        }
      }

      Text(alert.message)

      if let actionable = alert.actionableMessage {
        Text(actionable.message)
        actionable.icon
      }

      if let actionable = alert.postActionableMessage {
        Text(actionable)
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
            .foregroundStyle(Color.ds.text.danger.quiet)
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

private struct BreachIcon: View {
  let kind: BreachKind

  var image: Image {
    switch kind {
    case .default:
      .ds.notification.outlined
    case .dataLeak:
      .ds.feature.darkWebMonitoring.outlined
    }
  }

  var body: some View {
    image
      .foregroundStyle(Color.white)
      .padding(14)
      .background(Color.ds.container.expressive.danger.catchy.idle, in: Circle())
      .frame(width: 44, height: 44)
      .accessibilityHidden(true)
  }
}

#Preview {
  BreachIcon(kind: .dataLeak)
  BreachIcon(kind: .default)
}
