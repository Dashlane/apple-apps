import Foundation
protocol UserSessionViewModelProtocol: ObservableObject {
        var sessionState: SessionState { get }
}


class UserSessionViewModelMock: UserSessionViewModelProtocol {
    let sessionState: SessionState
    
    init(state: SessionState) {
        self.sessionState = state
    }
}
