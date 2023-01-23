import SwiftUI
import UIDelight
import ImportKit

struct SettingsFlowView: View {

    @StateObject
    var viewModel: SettingsFlowViewModel

    var body: some View {
        StepBasedNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .main:
                MainSettingsView(viewModel: viewModel.mainSettingsViewModelFactory.make(labsService: viewModel.labsService), action: { viewModel.handleMainAction($0) })
            case .security:
                SecuritySettingsView(viewModel: viewModel.securitySettingsViewModelFactory.make())
            case .general:
                GeneralSettingsView(viewModel: viewModel.generalSettingsViewModelFactory.make(), action: { viewModel.handleGeneralSettingsAction($0) })
            case .helpCenter:
                HelpCenterSettingsView(viewModel: viewModel.helpCenterSettingsViewModelFactory.make())
            case .import(let viewModel):
                ImportFlowView(viewModel: viewModel)
                    .hideTabBar()
            case .labs:
                LabsSettingsView(viewModel: viewModel.labsSettingsViewModelFactory.make(labsService: viewModel.labsService))
            }
        }
        .accentColor(Color(asset: FiberAsset.dashGreen))
    }
}

struct SettingsFlowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFlowView(viewModel: .mock)
    }
}
