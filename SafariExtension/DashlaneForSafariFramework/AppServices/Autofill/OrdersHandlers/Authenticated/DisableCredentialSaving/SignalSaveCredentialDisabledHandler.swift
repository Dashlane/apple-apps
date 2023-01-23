import Foundation
import DashlaneAppKit
import CoreSettings
import DashTypes

struct SignalSaveCredentialDisabledHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {
        let domain: String
    }

    typealias Response = MaverickEmptyResponse

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
        userSettings.disableSaveCredential(forDomain: request.domain)
        return nil
    }
}
