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
      case .main:
        PasswordHealthView(
          viewModel: viewModel.makePasswordHealthViewModel(), action: viewModel.handleAction)
      case .detailedList(let kind):
        PasswordHealthDetailedListView(
          viewModel: viewModel.makePasswordHealthDetailedListViewModel(kind: kind),
          action: viewModel.handleAction)
      case .credentialDetail(let credential):
        CredentialDetailView(model: viewModel.makeCredentialDetailViewModel(credential: credential))
      }
    }
  }
}
