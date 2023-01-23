import Foundation
import DashTypes

class MoreTabViewModel: SessionServicesInjecting {
    
    let login: String
    private let communicationService: MainApplicationCommunicationServiceProtocol
    
    init(communicationService: MainApplicationCommunicationServiceProtocol, login: String) {
        self.communicationService = communicationService
        self.login = login
    }

    func openMainApp() {
        communicationService.openMainAppManually()
    }

    func askForSupport() {
        communicationService.openSupport()
    }
    
}

extension MoreTabViewModel {
    static var mock: MoreTabViewModel {
        MoreTabViewModel(communicationService: MainApplicationCommunicationServiceMock(),
                         login: "_")
    }
}
