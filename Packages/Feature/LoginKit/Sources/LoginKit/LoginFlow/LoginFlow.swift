#if canImport(UIKit)
import SwiftUI
import UIDelight
import CoreSession

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
                LoginView(model: viewModel.makeLoginViewModel(email: email))
            case let .login(type):
                switch type {
                case let .localLogin(handler):
                    LocalLoginFlow(viewModel: viewModel.makeLocalLoginFlowViewModel(using: handler))
                case let .remoteLogin(remoteLoginType):
                    RemoteLoginFlowView(viewModel: viewModel.makeRemoteLoginFlowViewModel(using: remoteLoginType))
                }
            }
        }
    }
}
#endif
