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
            case let .login(viewModel):
                LoginView(model: viewModel)
            case let .localLogin(viewModel):
                LocalLoginFlow(viewModel: viewModel)
            case let .remoteLogin(viewModel):
                RemoteLoginFlow(viewModel: viewModel)
            }
        }
    }
}
#endif
