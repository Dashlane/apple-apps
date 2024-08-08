import SwiftUI
import UIDelight

struct DarkWebToolsFlow: View {

  @StateObject
  var viewModel: DarkWebToolsFlowViewModel

  init(viewModel: @autoclosure @escaping () -> DarkWebToolsFlowViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .root:
        DarkWebMonitoringView(
          model: viewModel.darkWebMonitoringViewModelFactory.make(
            actionPublisher: viewModel.actionPublisher)
        )
        .onAppear {
          viewModel.appeared()
        }
      case let .detail(breach):
        DarkWebMonitoringDetailsView(
          model: viewModel.makeDarkWebMonitoringDetailsViewModel(for: breach))
      case let .credentialDetails(credential):
        CredentialDetailView(model: viewModel.makeCredentialDetailViewModel(credential: credential))
          .navigationBarHidden(true)
      }
    }
    .sheet(item: $viewModel.presentedSheet) { sheet in
      switch sheet {
      case .addEmail:
        DataLeakMonitoringAddEmailView(
          viewModel: viewModel.makeDataLeakMonitoringAddEmailViewModel())
      }
    }
  }
}

struct DarkWebToolsFlow_Previews: PreviewProvider {
  static var previews: some View {
    DarkWebToolsFlow(viewModel: .mock)
  }
}
