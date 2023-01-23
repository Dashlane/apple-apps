import Foundation
import DashTypes

struct AskForBiometryHandler: SessionServicesInjecting {
    
    let maverickOrderMessage: MaverickOrderMessage
    let tabId: Int?
    let localAuthenticationService: LocalAuthenticationInformationService


    struct Response: Encodable {
        
        let subject = "stateResponse"
        let action = "biometryStatus"
        let forwardedTabId: Int
        let passed: Bool
        let canceled: Bool
        
                        func communication() -> Communication {
            let encoded = try! JSONEncoder().encode(self)
            let object = try! JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as! [String: Any]
            let body: [String: Any] = [
                "message": object
            ]
            return Communication(from: .plugin, to: .background, subject: subject, body: body)
        }        
    }
    
    init(maverickOrderMessage: MaverickOrderMessage, localAuthenticationService: LocalAuthenticationInformationService) {
        self.maverickOrderMessage = maverickOrderMessage
        self.tabId = maverickOrderMessage.tabId()
        self.localAuthenticationService = localAuthenticationService
    }
    
    func performOrder() async -> Response? {
        guard let tabId = tabId else {
            return nil
        }
        
        guard await localAuthenticationService.authorizeWithBiometry() else {
            return Response(forwardedTabId: tabId, passed: false, canceled: true)
        }
        localAuthenticationService.resetAuthorization()
        return Response(forwardedTabId: tabId, passed: true, canceled: false)
    }
}
