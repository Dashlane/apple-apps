import LoginKit
import SwiftUI
import UIDelight

struct MP2SSOAccountMigrationFlow: View {

  @StateObject private var viewModel: MP2SSOAccountMigrationViewModel

  init(viewModel: @escaping @autoclosure () -> MP2SSOAccountMigrationViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: .constant(viewModel.steps)) { step in
      switch step {
      case .confirmation:
        SSOMigrationView(completion: viewModel.makeInitialViewCompletion())
      case .ssoAuthentication(let authenticationInfo):
        SSOView(model: viewModel.makeSSOViewModel(with: authenticationInfo))
      case .migrationInProgress(let configuration):
        MigrationProgressView(
          model: viewModel.makeMigrationProgressViewModel(configuration: configuration))
      }
    }
  }
}
