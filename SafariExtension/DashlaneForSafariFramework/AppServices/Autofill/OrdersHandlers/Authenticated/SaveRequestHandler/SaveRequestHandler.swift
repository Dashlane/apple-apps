import Foundation
import CorePersonalData
import DomainParser
import DashTypes
import DashlaneAppKit
import VaultKit

struct SaveRequestHandler: MaverickOrderHandleable, SessionServicesInjecting {

    typealias Request = MaverickEmptyRequest
    typealias Response = MaverickEmptyResponse

    let maverickOrderMessage: MaverickOrderMessage
    let database: ApplicationDatabase
    let vaultItemsService: VaultItemsServiceProtocol
    let personalDataURLDecoder: PersonalDataURLDecoderProtocol
    let regionInformationService: RegionInformationService
    let logger: Logger
    
    init(maverickOrderMessage: MaverickOrderMessage,
         database: ApplicationDatabase,
         vaultItemsService: VaultItemsServiceProtocol,
         personalDataURLDecoder: PersonalDataURLDecoderProtocol,
         regionInformationService: RegionInformationService,
         logger: Logger) {
        self.maverickOrderMessage = maverickOrderMessage
        self.database = database
        self.vaultItemsService = vaultItemsService
        self.personalDataURLDecoder = personalDataURLDecoder
        self.regionInformationService = regionInformationService
        self.logger = logger
    }
    
    func performOrder() throws -> Response? {

        guard let request = maverickOrderMessage.request?.data(using: .utf8) else {
            throw MaverickRequestHandlerError.wrongRequest
        }

        guard let jsonRepresentation = try? JSONSerialization.jsonObject(with: request, options: .allowFragments),
            let dictionary = jsonRepresentation as? [String: Any],
            let content = dictionary["content"] as? [String: Any] else {
                throw MaverickRequestHandlerError.wrongRequest
        }

                if let item: Credential = parseElementIfExistAndUpdateFields(inJSON: content) {
            _ = try vaultItemsService.save(item)
            return nil
        }
        if let item: Address = parseElementIfExistAndUpdateFields(inJSON: content) {
            _ = try vaultItemsService.save(item)
            return nil
        }
        if let item: Company = parseElementIfExistAndUpdateFields(inJSON: content) {
            _ = try vaultItemsService.save(item)
            return nil
        }
        if let item: CorePersonalData.Email = parseElementIfExistAndUpdateFields(inJSON: content) {
            _ = try vaultItemsService.save(item)
            return nil
        }
        if let item: Identity = parseElementIfExistAndUpdateFields(inJSON: content) {
            _ = try vaultItemsService.save(item)
            return nil
        }
        if let item: CreditCard = parseElementIfExistAndUpdateFields(inJSON: content) {
            _ = try vaultItemsService.save(item)
            return nil
        }
        if let item: PersonalWebsite = parseElementIfExistAndUpdateFields(inJSON: content) {
            _ = try vaultItemsService.save(item)
            return nil
        }
        if let item: Phone = parseElementIfExistAndUpdateFields(inJSON: content) {
            _ = try vaultItemsService.save(item)
            return nil
        }

        return nil
    }


    private func parseElementIfExistAndUpdateFields<T: PersonalDataCodable & MaverickDataTypeInitialisable & MaverickPersonalDataDecoder>(inJSON content: [String: Any]) -> T? {

        guard let objectJSON = content[T.maverickSaveableType.rawValue] as? [String: Any] else {
            return nil
        }

                let item: T
        
        if let id = objectJSON["Id"] as? String, let fetchedItem: T = try? database.fetch(with: Identifier(id), type: T.self) {
            item = fetchedItem
            logger.debug("Item with id \(id) already exists, it will be replaced")
        } else {
            item = T()
            logger.debug("Item with needs to be created")
        }

        let element: T? = mergeObjectWithRawContent(item: item, jsonContent: objectJSON)

        return element
    }

        private func lowercasedKeys(forContentOfKey key: String, inJSON json: [String: Any]) -> [String: String]? {

        guard let rawContent = json[key] as? [String: String] else {
            return nil
        }
        let lowercasedJSON = rawContent.reduce(into: [String: String](), { (result, tuple) in
            result[tuple.key.lowercasingFirstLetter()] = tuple.value
        })

        return lowercasedJSON
    }

        private func mergeObjectWithRawContent<T: PersonalDataCodable & MaverickDataTypeInitialisable & MaverickPersonalDataDecoder>(item: T, jsonContent: [String: Any]) -> T? {

        var mutableItem = item
        
        let decoder = JSONDecoder()
        mutableItem.merge(withMaverickJSON: jsonContent,
                          using: decoder,
                          regionInformationService: regionInformationService,
                          vaultItemsService: vaultItemsService,
                          logger: logger)

        return mutableItem
    }
}

