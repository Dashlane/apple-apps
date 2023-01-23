import Foundation
import TOTPGenerator
import DashTypes

struct GetOTPForCredentialHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {
        let credentialId: String
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let otpCode: String
    }

    let maverickOrderMessage: MaverickOrderMessage
    let vaultItemsService: VaultItemsService
    
    init(maverickOrderMessage: MaverickOrderMessage, vaultItemsService: VaultItemsService) {
        self.maverickOrderMessage = maverickOrderMessage
        self.vaultItemsService = vaultItemsService
    }

    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        
        guard let credential = vaultItemsService.credentials.first(where: { $0.id.rawValue == request.credentialId }),
              let otpURL = credential.otpURL, let otpInfo = try? OTPConfiguration(otpURL: otpURL) else {
            return Response(id: actionMessageID,
                            otpCode: "")
        }

        let generatedOTP = TOTPGenerator.generate(with: otpInfo.type, for: Date(), digits: otpInfo.digits, algorithm: otpInfo.algorithm, secret: otpInfo.secret)

        return Response(id: actionMessageID,
                        otpCode: generatedOTP)

    }
}
