import Foundation
import DomainParser
import CorePersonalData
import DashlaneAppKit

struct AnalysisIsDisabledHandler: MaverickOrderHandleable {

    struct Request: Decodable {
        let url: String
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let disabled: String
        let onlyFillLoginInfo: String
    }
    
    enum SessionState {
        case loggedOut
        case loggedIn(SessionServicesContainer)
    }

    let maverickOrderMessage: MaverickOrderMessage
    let sessionState: SessionState
    let domainParser: DomainParser
    
    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        
        switch sessionState {
        case .loggedOut:
            return authoriseAnalysis()
        case let .loggedIn(services):
            return handleLoggedInOrder(url: request.url, services: services)
        }
    }
    
    private func handleLoggedInOrder(url: String, services: SessionServicesContainer) -> Response {
        
        let autofillData = services.spiegelUserEncryptedSettings.getAutofillPreferences()
        let autofillPolicy = autofillData.policy(forPageAtURL: url, domainParser: domainParser)
        
        
        var disabled = autofillPolicy?.policy == .disabled
        var onlyFillLoginInfo = autofillPolicy?.policy == .loginPasswordsOnly
        
        let disabledWebsites = services.premiumService.status?.disabledWebsites() ?? []

        if let domain = domainParser.parse(urlString: url),
           disabledWebsites.contains(domain.name) {
            disabled = true
            onlyFillLoginInfo = false
        }
        
        return Response(id: actionMessageID,
                        disabled: "\(disabled)",
                        onlyFillLoginInfo: "\(onlyFillLoginInfo)")
    }
    
    private func authoriseAnalysis() -> Response {
        Response(id: actionMessageID,
                 disabled: "false",
                 onlyFillLoginInfo: "false")
    }
}
