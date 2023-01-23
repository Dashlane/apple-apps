import DesignSystem
import SwiftUI
import UIDelight

struct PasswordHealthFlowView: View {

    @StateObject
    var viewModel: PasswordHealthFlowViewModel

    public init(viewModel: @autoclosure @escaping () -> PasswordHealthFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .main(let model):
                PasswordHealthView(viewModel: model, action: viewModel.handleAction)
                    .navigationBarHidden(false)
            case .detailedList(let model):
                PasswordHealthDetailedListView(viewModel: model, action: viewModel.handleAction)
                    .navigationBarHidden(false)
            case .credentialDetail(let model):
                CredentialDetailView(model: model)
                    .navigationBarHidden(true)
            }
        }
        .resetTabBarItemTitle(L10n.Localizable.toolsTitle)
    }
}
