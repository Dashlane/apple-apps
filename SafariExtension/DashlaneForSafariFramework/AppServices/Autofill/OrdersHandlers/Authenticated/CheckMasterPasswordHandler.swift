import Foundation
import DashTypes

struct CheckMasterPasswordHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {
        let password: String
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let masterPasswordIsValid: Bool
    }

    let maverickOrderMessage: MaverickOrderMessage
    let localAuthenticationService: LocalAuthenticationInformationService

    internal init(maverickOrderMessage: MaverickOrderMessage, localAuthenticationService: LocalAuthenticationInformationService) {
        self.maverickOrderMessage = maverickOrderMessage
        self.localAuthenticationService = localAuthenticationService
    }
    
    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        
        let masterPasswordIsValid = localAuthenticationService.isMasterPasswordValid(autofillMasterPassword: request.password)

        if masterPasswordIsValid {
            localAuthenticationService.resetAuthorization()
        }

        return Response(id: actionMessageID, masterPasswordIsValid: masterPasswordIsValid)
    }
}
