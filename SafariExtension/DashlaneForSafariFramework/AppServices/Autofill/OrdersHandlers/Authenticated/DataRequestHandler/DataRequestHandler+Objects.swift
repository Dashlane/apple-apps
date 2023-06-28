import Foundation
import DomainParser
import CorePersonalData

extension DataRequestHandler {
    
    func objects(for dataTypes: [MaverickDataType],
                         request: Request,
                         hasSpaces: Bool) -> [String: Any] {
        var objects = [String: Any]()
        
        if dataTypes.contains(.email) {
            objects[MaverickDataType.email.rawValue] = vaultItemsService.emails.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.credential) {
            objects[MaverickDataType.credential.rawValue] = credentials(forUrlString: request.url)
        }
        
        if dataTypes.contains(.identity) {
            objects[MaverickDataType.identity.rawValue] =  vaultItemsService.identities.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.address) {
            objects[MaverickDataType.address.rawValue] = addresses()
        }
        
        if dataTypes.contains(.phone) {
            objects[MaverickDataType.phone.rawValue] = vaultItemsService.phones.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.company) {
            objects[MaverickDataType.company.rawValue] = vaultItemsService.companies.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.website) {
            objects[MaverickDataType.website.rawValue] = vaultItemsService.websites.toMaverickDictionary(hasSpaces: hasSpaces)
        }

        if dataTypes.contains(.idCard) {
            objects[MaverickDataType.idCard.rawValue] = vaultItemsService.idCards.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.passport) {
            objects[MaverickDataType.passport.rawValue] = vaultItemsService.passports.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.driverLicence) {
            objects[MaverickDataType.driverLicence.rawValue] = vaultItemsService.drivingLicenses.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.socialSecurity) {
            objects[MaverickDataType.socialSecurity.rawValue] = vaultItemsService.socialSecurityInformation.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.fiscalStatement) {
            objects[MaverickDataType.fiscalStatement.rawValue] = vaultItemsService.fiscalInformation.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.paymentMeanCreditCard) {
            objects[MaverickDataType.paymentMeanCreditCard.rawValue] = vaultItemsService.creditCards.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.bankStatement) {
            objects[MaverickDataType.bankStatement.rawValue] = vaultItemsService.bankAccounts.toMaverickDictionary(hasSpaces: hasSpaces)
        }
        
        if dataTypes.contains(.paymentMeanPaypal) {
                        objects[MaverickDataType.paymentMeanPaypal.rawValue] = []
        }
        
        if dataTypes.contains(.authCategory) {
            objects[MaverickDataType.authCategory.rawValue] = authCategories()
        }
        
        if dataTypes.contains(.generatedPassword) {
            objects[MaverickDataType.generatedPassword.rawValue] = generatedPasswords(forUrlString: request.url)
        }
        
        return objects
    }
    
    private func credentials(forUrlString urlString: String) -> [[String: Any]] {
        guard let domain = domainParser.parse(urlString: urlString) else {
            return []
        }
        
        return vaultItemsService
            .credentials
            .filter({ $0.isMatching(domain) })
            .compactMap(MaverickObject.toDictionaryWithUppercaseKeys)
            .map { MaverickObject.addPersonalSpaceIDIfNeeded(to: $0,
                                                             hasSpaces: hasSpaces) }
    }
    
    private func addresses() -> [[String: Any]] {
        vaultItemsService
            .addresses
            .compactMap(MaverickObject.toDictionaryWithUppercaseKeys)
            .map(MaverickObject.addCountryField)
            .map { MaverickObject.addPersonalSpaceIDIfNeeded(to: $0,
                                                             hasSpaces: hasSpaces) }
    }
    
    private func authCategories() -> [[String: Any]] {
                return []
    }
    
    private func generatedPasswords(forUrlString urlString: String) -> [[String: Any]] {
        guard let domain = domainParser.parse(urlString: urlString) else {
            return []
        }

        return generatedPasswords
            .filter { $0.domain?.rawValue.contains(domain.name) == true }
            .compactMap(MaverickObject.toDictionaryWithUppercaseKeys)
    }
}

private extension Sequence where Element: PersonalDataCodable {
        func toMaverickDictionary(hasSpaces: Bool) -> [[String: Any]] {
        compactMap(MaverickObject.toDictionaryWithUppercaseKeys)
            .map { MaverickObject.addPersonalSpaceIDIfNeeded(to: $0,
                                                             hasSpaces: hasSpaces) }
    }
}
