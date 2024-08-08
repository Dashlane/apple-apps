import CoreLocalization
import DesignSystem
import MacrosKit
import SwiftUI
import UIDelight
import VaultKit

@ViewInit
struct PasswordGeneratorToolsFlow: View {
  @StateObject
  var viewModel: PasswordGeneratorToolsFlowViewModel

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .root:
        PasswordGeneratorView(viewModel: viewModel.makePasswordGeneratorViewModel())
          .onReceive(viewModel.deepLinkShowPasswordHistoryPublisher) { _ in
            viewModel.showHistory()
          }
      case .history:
        PasswordGeneratorHistoryView(
          model: viewModel.passwordGeneratorHistoryViewModelFactory.make())
      }
    }
  }
}

struct PasswordGeneratorToolsFlow_Previews: PreviewProvider {
  static var previews: some View {
    PasswordGeneratorToolsFlow(viewModel: .mock)
  }
}
