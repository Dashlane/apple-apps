import DesignSystem
import ImportKit
import SwiftUI
import UIDelight

@ViewInit
struct SettingsFlowView: View {
  @Environment(\.toast)
  var toast

  @StateObject
  var viewModel: SettingsFlowViewModel

  var body: some View {
    NavigationStack(path: $viewModel.subSectionsPath) {
      MainSettingsView(viewModel: viewModel.makeMainViewModel())
        .navigationDestination(for: SettingsSubSection.self) { step in
          switch step {
          case .security:
            SecuritySettingsView(viewModel: viewModel.securitySettingsViewModelFactory.make())
          case .general:
            GeneralSettingsView(viewModel: viewModel.generalSettingsViewModelFactory.make())
          case .helpCenter:
            HelpCenterSettingsView(viewModel: viewModel.helpCenterSettingsViewModelFactory.make())
          case .accountSummary:
            AccountSummaryView(model: viewModel.makeAccountSummaryViewModel())
          }
        }
    }
    .tint(.ds.text.brand.standard)
    .toasterOn()
  }
}

struct SettingsFlowView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsFlowView(viewModel: .mock)
  }
}
