import Foundation
import DashlaneAppKit
import CoreSettings
import DashTypes

struct SaveCredentialDisabledHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {
        let domain: String
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let isSaveCredentialDisabled: Bool
    }

    let maverickOrderMessage: MaverickOrderMessage
    let userSettings: UserSettings

    init(maverickOrderMessage: MaverickOrderMessage, spiegelUserSettings: UserSettings) {
        self.maverickOrderMessage = maverickOrderMessage
        self.userSettings = spiegelUserSettings
    }
    
    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        
        let isSaveCredentialDisabled = userSettings.isSaveCredentialDisabled(forDomain: request.domain)

        return Response(id: actionMessageID, isSaveCredentialDisabled: isSaveCredentialDisabled)
    }
}
