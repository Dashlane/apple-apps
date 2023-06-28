import Foundation
import CorePersonalData
import DashTypes
import DashlaneAppKit

struct SaveGeneratedPasswordHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {
        let password: String
        let url: String
    }

    typealias Response = MaverickEmptyResponse

    let maverickOrderMessage: MaverickOrderMessage
    let personalDataURLDecoder: PersonalDataURLDecoderProtocol
    let database: ApplicationDatabase

    init(maverickOrderMessage: MaverickOrderMessage, personalDataURLDecoder: PersonalDataURLDecoderProtocol, database: ApplicationDatabase) {
        self.maverickOrderMessage = maverickOrderMessage
        self.personalDataURLDecoder = personalDataURLDecoder
        self.database = database
    }

    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }

        var generated = GeneratedPassword()
        generated.password = request.password
        generated.domain = try personalDataURLDecoder.decodeURL(request.url)
        generated.generatedDate = Date()
        generated.platform = System.platform

        try database.save(generated)

        return nil
    }
}
