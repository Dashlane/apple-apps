import CoreSession
import SwiftUI
import UIDelight

public struct LoginFlow: View {
  @StateObject
  var viewModel: LoginFlowViewModel

  public init(viewModel: @autoclosure @escaping () -> LoginFlowViewModel) {
    self._viewModel = .init(wrappedValue: viewModel())
  }

  public var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case let .loginInput(email):
        LoginInputView(model: viewModel.makeLoginViewModel(email: email))
      case let .login(type):
        switch type {
        case let .localLogin(handler):
          LocalLoginFlow(viewModel: viewModel.makeLocalLoginFlowViewModel(using: handler))
        case let .remoteLogin(remoteLoginType):
          RemoteLoginFlowView(
            viewModel: viewModel.makeRemoteLoginFlowViewModel(using: remoteLoginType))
        }
      }
    }
  }
}
