import Foundation
import CorePremium
import CoreSession
import CorePersonalData
import DashTypes

struct IsAutofillPasswordProtectedHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {

        enum DataType: String, Decodable {
            case credential
            case payment
        }

        let dataType: DataType?
        let credentialId: String?
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let isProtected: Bool
        let dataBackendHasBiometry: Bool
    }

    let maverickOrderMessage: MaverickOrderMessage
    let localAuthenticationService: LocalAuthenticationInformationService
    let vaultItemsService: VaultItemsService

    init(maverickOrderMessage: MaverickOrderMessage,
         localAuthenticationService: LocalAuthenticationInformationService,
         vaultItemsService: VaultItemsService) {
        self.maverickOrderMessage = maverickOrderMessage
        self.localAuthenticationService = localAuthenticationService
        self.vaultItemsService = vaultItemsService
    }
    
    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        
        let shouldAskForAuthentication: Bool
        let hasBiometry = localAuthenticationService.hasBiometry()
        
        switch localAuthenticationService.localAuthentication() {
        case .sso:
            shouldAskForAuthentication = false
        default:
            shouldAskForAuthentication = !localAuthenticationService.hasAuthorizationForSecureDataAccess()
        }
        
                guard let dataType = request.dataType else {
            assertionFailure("Unknown data type")
            return Response(id: actionMessageID, isProtected: false, dataBackendHasBiometry: hasBiometry)
        }
        
        let shouldProtectDataType: Bool = {
            switch dataType {
            case .payment:
                return true
            case .credential:
                guard let credentialId = request.credentialId else {
                    return false
                }
                return vaultItemsService.isCredentialProtected(credentialId: credentialId) == true
            }
        }()
        if shouldProtectDataType {
            return Response(id: actionMessageID, isProtected: shouldAskForAuthentication, dataBackendHasBiometry: hasBiometry)
        } else {
            return Response(id: actionMessageID, isProtected: false, dataBackendHasBiometry: hasBiometry)
        }
    }
}

private extension VaultItemsService {
    func isCredentialProtected(credentialId: String) -> Bool {
        guard let credential = credentials.first(where: { $0.id == Identifier(credentialId) }) else {
            return false
        }
        return credential.isProtected
    }
}
