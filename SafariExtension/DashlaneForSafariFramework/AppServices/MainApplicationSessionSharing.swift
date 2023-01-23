import Foundation
import CoreSession
import Combine
import DashTypes

class MainApplicationSessionSharing: Mockable {

    @Published
    private(set) var currentSession: ShareableUserSession?
    
    let communicationService: MainApplicationCommunicationServiceProtocol
    
    init(communicationService: MainApplicationCommunicationServiceProtocol) {
        self.communicationService = communicationService
        communicationService.lastMessage
            .compactMap({ $0 })
            .filter({ $0.isCurrentUserSessionMessage })
            .receive(on: DispatchQueue.main)
            .map({ $0.session })
            .assign(to: &$currentSession)
    }
    
    public func askForSession(silently: Bool) {
        communicationService.send(message: .askForSession(silently: silently))
    }

    func resetSession() {
        self.currentSession = nil
    }
}

private extension SafariExtensionExternalCommunications.MainApplicationToSafariExtensionMessage {
    
    var isCurrentUserSessionMessage: Bool {
        guard case .currentUserSession = self else {
            return false
        }
        return true
    }
    
    var session: ShareableUserSession? {
        guard case let .currentUserSession(session) = self else {
            return nil
        }
        return session
    }
}

struct MainApplicationSessionSharingMock: MainApplicationSessionSharingProtocol {
    func askForSession(silently: Bool) {
        print("Asking session silently \(silently)")
    }
}
