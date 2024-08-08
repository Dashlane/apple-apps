import SwiftUI
import UIDelight

struct VPNAvailableToolsFlow: View {

  @StateObject
  var viewModel: VPNAvailableToolsFlowViewModel

  init(viewModel: @autoclosure @escaping () -> VPNAvailableToolsFlowViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .root:
        VPNMainView(
          model: viewModel.vpnMainViewModelFactory.make(
            mode: .activationNeeded, actionPublisher: viewModel.actionPublisher))
      case .accountActivation:
        VPNActivationView(
          model: viewModel.vpnActivationViewModelFactory.make(
            actionPublisher: viewModel.actionPublisher))
      }
    }
  }
}

struct VPNAvailableToolsFlow_Previews: PreviewProvider {
  static var previews: some View {
    VPNAvailableToolsFlow(viewModel: .mock)
  }
}
