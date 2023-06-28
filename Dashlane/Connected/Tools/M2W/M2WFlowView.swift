import DesignSystem
import CoreUserTracking
import SwiftUI
import UIDelight

struct M2WFlowView: View {

    @StateObject
    var viewModel: M2WFlowViewModel

    let completion: (@MainActor (M2WDismissAction) -> Void)?

    var body: some View {
        StepBasedNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .start:
                M2WStartView(completion: viewModel.handleStartViewAction)
            case .connect:
                M2WConnectView(completion: viewModel.handleConnectViewAction)
            }
        }
        .navigationBarStyle(.transparent(tintColor: .ds.text.brand.standard, titleColor: nil))
        .reportPageAppearance(.toolsNewDevice)
        .alert(isPresented: $viewModel.showAlert, content: { alert })
        .onReceive(viewModel.dismissPublisher) {
            self.completion?($0)
        }
    }

    private var alert: Alert {
        Alert(title: Text(L10n.Localizable.m2WConnectScreenConfirmationPopupTitle),
              primaryButton: .cancel(Text(L10n.Localizable.m2WConnectScreenConfirmationPopupNo), action: viewModel.handleAlertNoAction),
              secondaryButton: .default(Text(L10n.Localizable.m2WConnectScreenConfirmationPopupYes), action: viewModel.handleAlertYesAction))
    }
}

struct M2WFlowView_Previews: PreviewProvider {

    static var previews: some View {
        MultiContextPreview {
            M2WFlowView(viewModel: .init(initialStep: .start), completion: nil)
            M2WFlowView(viewModel: .init(initialStep: .connect), completion: nil)
        }
    }
}
