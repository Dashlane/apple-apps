import SwiftUI

struct RootView<ViewModel: UserSessionViewModelProtocol>: View {
    
    @ObservedObject
    var viewModel: ViewModel
    
    var body: some View {
        switch viewModel.sessionState {
        case let .login(loginViewModel):
            LoginView(viewModel: loginViewModel)
        case .loading:
            LoadingView()
        case let .connected(connectedViewModel):
            ConnectedView(viewModel: connectedViewModel)
        }
    }
}
