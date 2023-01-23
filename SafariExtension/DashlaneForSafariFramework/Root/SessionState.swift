import Foundation

enum SessionState {
    case login(LoginViewModel)
    case loading
    case connected(ConnectedViewModel)
}
