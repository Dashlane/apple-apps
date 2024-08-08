import DesignSystem
import SwiftUI
import UIDelight

struct SharingToolsFlow: View {
  @StateObject
  var viewModel: SharingToolsFlowViewModel

  init(viewModel: @autoclosure @escaping () -> SharingToolsFlowViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .root:
        SharingToolView(model: viewModel.sharingToolViewModelFactory.make())
          .environment(\.showVaultItem, viewModel.makeShowVaultItemAction())
          .navigationBarHidden(false)
      case let .credentialDetails(item):
        VaultDetailView(model: viewModel.makeDetailViewModel(), itemDetailViewType: .viewing(item))
      }
    }
  }
}

struct SharingToolsFlow_Previews: PreviewProvider {
  static var previews: some View {
    SharingToolsFlow(viewModel: .mock)
  }
}
