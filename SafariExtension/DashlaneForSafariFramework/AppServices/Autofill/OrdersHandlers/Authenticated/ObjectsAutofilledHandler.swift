import Foundation
import CorePersonalData
import DashlaneAppKit
import DashTypes

enum AutofilledMaverickDataType: String, Codable {
    case credential = "AUTHENTICATION"
    case paymentMeanCreditCard = "PAYMENT_MEAN_CREDITCARD"
    case address = "ADDRESS"
    case bankAccount = "BANK_STATEMENT"
    case company = "COMPANY"
    case drivingLicense = "DRIVER_LICENCE"
    case email = "EMAIL"
    case fiscalInformation = "FISCAL"
    case idCard = "ID_CARD"
    case identity = "IDENTITY"
    case passport = "PASSPORT"
    case personalWebsite = "WEBSITE"
    case phone = "PHONE"
    case socialSecurity = "SOCIAL_SECURITY"
}

struct ObjectsAutofilledHandler: MaverickOrderHandleable, SessionServicesInjecting {
    struct Request: Decodable {
        let objectId: String
        let url: URL
        let informationNeeded: AutofilledMaverickDataType
    }

    typealias Response = MaverickEmptyResponse

    let maverickOrderMessage: MaverickOrderMessage
    let database: ApplicationDatabase

    init(maverickOrderMessage: MaverickOrderMessage, database: ApplicationDatabase) {
        self.maverickOrderMessage = maverickOrderMessage
        self.database = database
    }
    
    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        
        #warning("Date usage broken: Credential update the legacy synced value, where as other item update only local date not understood by autofill engine.")
        switch request.informationNeeded {
            case .credential:
                guard var credential: Credential = try database.fetch(with: Identifier(request.objectId), type: Credential.self) else {
                    break
                }
                let trustedUrl = TrustedURL(url: request.url.absoluteString, creationDate: Date())
                credential.lastUseDate = Date()
                credential.numberOfUse += 1
                credential.trustedUrlGroup = addTrustedUrl(trustedUrl: trustedUrl, in: credential.trustedUrlGroup)
                try database.save(credential)
            default:
                updateLastUse(ofObjectId: request.objectId)
        }

        return nil
    }

    func updateLastUse(ofObjectId objectId: String) {
        do {
            try database.updateLastUseDate(for: [.init(objectId)], origin: [.default])
        }
        catch { }
    }

        func addTrustedUrl(trustedUrl: TrustedURL, in trustedUrls: [TrustedURL]) -> [TrustedURL] {
        var updatedTrustedUrlGroup = Array(trustedUrls)

                if let existingObjectIndex = updatedTrustedUrlGroup.firstIndex(of: trustedUrl) {
            updatedTrustedUrlGroup.remove(at: existingObjectIndex)
        }

        updatedTrustedUrlGroup.append(trustedUrl)

        return Array(
            updatedTrustedUrlGroup
            .sorted(by: { a, b -> Bool in
                guard let dateA = a.creationDate, let dateB = b.creationDate else { return false }
                return dateA>dateB
            })
            .prefix(20)
        )
    }
}
