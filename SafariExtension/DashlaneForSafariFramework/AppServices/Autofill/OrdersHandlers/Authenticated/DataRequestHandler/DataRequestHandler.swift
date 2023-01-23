import Foundation
import CorePersonalData
import DomainParser
import CorePremium
import DashTypes

struct DataRequestHandler: SessionServicesInjecting {
    struct Request: Decodable {
        let url: String
        let dataTypes: [String]
        let shouldReturnSpaces: Bool
    }
        
    typealias Response = String

    enum DataRequestError: Error {
        case encodingFailed
        case missingActionMessageId
    }

    let maverickOrderMessage: MaverickOrderMessage
    let domainParser: DomainParser
    let premiumService: PremiumService
    let vaultItemsService: VaultItemsServiceProtocol
    
    private var spaces: [[String: Any]]
    
    @FetchedPersonalData
    var generatedPasswords: FetchedPersonalData<GeneratedPassword>.Values
    
    var hasSpaces: Bool {
        !spaces.isEmpty
    }
    
    init(maverickOrderMessage: MaverickOrderMessage,
         domainParser: DomainParser,
         premiumService: PremiumService,
         vaultItemsService: VaultItemsServiceProtocol) {
        self.maverickOrderMessage = maverickOrderMessage
        self.domainParser = domainParser
        self.premiumService = premiumService
        self.vaultItemsService = vaultItemsService
        
        spaces = (premiumService.status?.spaces ?? [])
            .map { $0.maverickDictionary }
                        if !spaces.isEmpty {
            spaces.append(Space.personal.maverickDictionary)
        }
        
        _generatedPasswords = vaultItemsService.fetchedPersonalData(for: GeneratedPassword.self)
    }
    
    func performOrder() throws -> Response? {
        guard let request: DataRequestHandler.Request = maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        
        guard let actionMessageID = maverickOrderMessage.requestID else {
            throw DataRequestError.missingActionMessageId
        }

        let requestedDataTypes = request.dataTypes.compactMap(MaverickDataType.init)
        
        let objects = self.objects(for: requestedDataTypes,
                                   request: request,
                                   hasSpaces: !spaces.isEmpty)
        
        
        let response: [String: Any]
                        if request.shouldReturnSpaces {
            response = [
                "id": actionMessageID,
                "objects": [
                    "userData": objects,
                    "spacesInfos": ["spaces": spaces]
                ]
            ]
        } else {
            response = [
                "id": actionMessageID,
                "objects": objects
            ]
        }
        
        
        let data = try JSONSerialization.data(withJSONObject: response, options: [])
        
        guard let json = String(data: data, encoding: .utf8) else {
            throw DataRequestError.encodingFailed
        }
        
        return json
    }
}
