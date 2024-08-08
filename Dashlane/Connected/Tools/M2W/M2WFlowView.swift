import CoreUserTracking
import DesignSystem
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
    .reportPageAppearance(.toolsNewDevice)
    .alert(
      L10n.Localizable.m2WConnectScreenConfirmationPopupTitle,
      isPresented: $viewModel.showAlert,
      actions: {
        Button(L10n.Localizable.m2WConnectScreenConfirmationPopupNo) {}
        Button(L10n.Localizable.m2WConnectScreenConfirmationPopupYes) {
          viewModel.handleAlertYesAction()
        }
      }
    )
    .onReceive(viewModel.dismissPublisher) {
      self.completion?($0)
    }
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
