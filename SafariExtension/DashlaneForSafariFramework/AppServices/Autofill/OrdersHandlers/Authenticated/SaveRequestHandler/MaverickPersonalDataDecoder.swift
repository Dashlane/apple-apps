import Foundation
import CorePersonalData
import DashTypes
import CoreRegion
import DashlaneAppKit
import VaultKit

protocol MaverickPersonalDataDecoder {
    associatedtype MaverickObject: Decodable
    mutating func merge(withMaverickJSON json: [String : Any],
               using decoder: JSONDecoder,
               regionInformationService: RegionInformationService,
               vaultItemsService: VaultItemsServiceProtocol,
               logger: Logger)
}

extension MaverickPersonalDataDecoder {
    func decodeMaverickObject(fromJSON json: [String: Any]) -> MaverickObject? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed),
            let maverickObject = try? JSONDecoder().decode(MaverickObject.self, from: data) else {
                assertionFailure("Wrong data to parse")
                return nil
        }
        return maverickObject
    }
}

extension Credential: MaverickPersonalDataDecoder {

    typealias MaverickObject = MaverickCredential

    struct MaverickCredential: Decodable {
        let Id: String
        let Login: String
        let SecondaryLogin: String
        let SpaceId: String
        let Url: String
        let Password: String
        let Category: String
        let AutoProtected: Bool
        let Email: String
        let SubdomainOnly: Bool

        enum CodingKeys: String, CodingKey {
            case Id
            case Login
            case SecondaryLogin
            case SpaceId
            case Url
            case Password
            case Category
            case AutoProtected
            case Email
            case SubdomainOnly
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MaverickCredential.CodingKeys.self)
            self.Id = try container.decode(String.self, forKey: .Id)
            self.Login = try container.decode(String.self, forKey: .Login)
            self.SecondaryLogin = try container.decode(String.self, forKey: .SecondaryLogin)
            self.SpaceId = try container.decode(String.self, forKey: .SpaceId)
            self.Url = try container.decode(String.self, forKey: .Url)
            self.Password = try container.decode(String.self, forKey: .Password)
            self.Category = try container.decode(String.self, forKey: .Category)
            self.Email = try container.decode(String.self, forKey: .Email)
                                    self.AutoProtected = (try? container.decodeIfPresent(Bool.self, forKey: .AutoProtected)) ?? false
            self.SubdomainOnly = (try? container.decodeIfPresent(Bool.self, forKey: .SubdomainOnly)) ?? false
        }
    }

    mutating func merge(withMaverickJSON json: [String : Any],
                        using decoder: JSONDecoder,
                        regionInformationService: RegionInformationService,
                        vaultItemsService: VaultItemsServiceProtocol,
                        logger: Logger) {
        guard let maverickObject = decodeMaverickObject(fromJSON: json) else {
            return
        }

        login = maverickObject.Login
        secondaryLogin = maverickObject.SecondaryLogin
        spaceId = maverickObject.SpaceId
        url = PersonalDataURL(rawValue: maverickObject.Url)
        password = maverickObject.Password

        isProtected = maverickObject.AutoProtected
        email = maverickObject.Email
        subdomainOnly = maverickObject.SubdomainOnly
        
                if self.login.isEmpty && !self.secondaryLogin.isEmpty {
            login = secondaryLogin
            secondaryLogin = ""
        }
    }
}

extension CreditCard: MaverickPersonalDataDecoder {

    typealias MaverickObject = MaverickCreditCard

    struct MaverickCreditCard: Decodable {
        let cardName: String
        let cardNumber: String
        let expireMonth: String
        let expireYear: String
        let ownerName: String
        let securityCode: String
    }

            mutating func merge(withMaverickJSON json: [String : Any],
                        using decoder: JSONDecoder,
                        regionInformationService: RegionInformationService,
                        vaultItemsService: VaultItemsServiceProtocol,
                        logger: Logger) {

        guard let maverickObject = decodeMaverickObject(fromJSON: json) else {
            return
        }

        name = maverickObject.cardName
        cardNumber = maverickObject.cardNumber
        expireMonth = Int(maverickObject.expireMonth)
        expireYear = Int(maverickObject.expireYear)
        ownerName = maverickObject.ownerName
        securityCode = maverickObject.securityCode
    }
}

extension Address: MaverickPersonalDataDecoder {

    typealias MaverickObject = MaverickAddress

    struct MaverickAddress: Decodable {
        let digitCode: String
        let door: String
        let addressFull: String
        let zipcode: String
        let country: String
        let addressName: String
        let streetNumber: String
        let stairs: String
        let state: String
        let floor: String
        let city: String
        let building: String
        let receiver: String
    }

            mutating func merge(withMaverickJSON json: [String : Any],
                        using decoder: JSONDecoder,
                        regionInformationService: RegionInformationService,
                        vaultItemsService: VaultItemsServiceProtocol,
                        logger: Logger) {

        guard let maverickObject = decodeMaverickObject(fromJSON: json) else {
            return
        }

        name = maverickObject.addressName
        receiver = maverickObject.receiver
        addressFull = maverickObject.addressFull
        city = maverickObject.city
        zipCode = maverickObject.zipcode
        state = StateCodeNamePair(code: "", name: maverickObject.state)
        country = regionInformationService.countryPair(forCountryName: maverickObject.country)
        streetNumber = maverickObject.streetNumber
        building = maverickObject.building
        stairs = maverickObject.stairs
        floor = maverickObject.floor
        door = maverickObject.door
        digitCode = maverickObject.digitCode
    }
}

extension Company: MaverickPersonalDataDecoder {

    typealias MaverickObject = MaverickCompany

    struct MaverickCompany: Decodable {
        let jobTitle: String
        let name: String
    }

    mutating func merge(withMaverickJSON json: [String : Any],
                        using decoder: JSONDecoder,
                        regionInformationService: RegionInformationService,
                        vaultItemsService: VaultItemsServiceProtocol,
                        logger: Logger) {

        guard let maverickObject = decodeMaverickObject(fromJSON: json) else {
            return
        }

        name = maverickObject.name
        jobTitle = maverickObject.jobTitle
    }
}

extension Phone: MaverickPersonalDataDecoder {

    typealias MaverickObject = MaverickPhone

    struct MaverickPhone: Decodable {
        let number: String
        let phoneName: String
        let type: String
    }

    mutating func merge(withMaverickJSON json: [String : Any],
                        using decoder: JSONDecoder,
                        regionInformationService: RegionInformationService,
                        vaultItemsService: VaultItemsServiceProtocol,
                        logger: Logger) {

        guard let maverickObject = decodeMaverickObject(fromJSON: json) else {
            return
        }

        number = maverickObject.number
        name = maverickObject.phoneName.isEmpty ? maverickObject.number : maverickObject.phoneName
        type = NumberType(rawValue: maverickObject.type)

        if country == nil && number.starts(with: "+") {
            let noPlusSignNumber = String(number[number.index(after: number.startIndex)..<number.endIndex])
            if let code = regionInformationService.callingCodes.callingCodes.code(forPhoneNumber: noPlusSignNumber) {
                country = CountryCodeNamePair(code: code.region, name: "")
                number = number.replacingOccurrences(of: "+\(code.dialingCode)", with: "0")
            }
        } else {
            country = .systemCountryCode
        }
    }
}

private extension Array where Element == CallingCode {

    func code(forPhoneNumber number: String) -> CallingCode? {
        self.sorted(by: { $0.dialingCode > $1.dialingCode })
            .first { code -> Bool in
                number.starts(with: "\(code.dialingCode)")
        }
    }
}

extension Identity: MaverickPersonalDataDecoder {

    typealias MaverickObject = MaverickIdentity

    struct MaverickIdentity: Decodable {
        let birthDate: String
        let birthPlace: String
        let firstName: String
        let lastName: String
        let middleName: String
        let pseudo: String
        let title: String
    }

    mutating func merge(withMaverickJSON json: [String : Any],
                        using decoder: JSONDecoder,
                        regionInformationService: RegionInformationService,
                        vaultItemsService: VaultItemsServiceProtocol,
                        logger: Logger) {

        guard let maverickObject = decodeMaverickObject(fromJSON: json) else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: maverickObject.birthDate) {
            birthDate = date
        }
        birthPlace = maverickObject.birthPlace
        firstName = maverickObject.firstName
        lastName = maverickObject.lastName
        middleName = maverickObject.middleName
        pseudo = maverickObject.pseudo
        personalTitle = PersonalTitle(rawValue: maverickObject.title) ?? .noneOfThese
    }
}

extension CorePersonalData.Email: MaverickPersonalDataDecoder {

    typealias MaverickObject = MaverickEmail

    struct MaverickEmail: Decodable {
        let email: String
        let emailName: String
    }

    mutating func merge(withMaverickJSON json: [String : Any],
                        using decoder: JSONDecoder,
                        regionInformationService: RegionInformationService,
                        vaultItemsService: VaultItemsServiceProtocol,
                        logger: Logger) {

        guard let maverickObject = decodeMaverickObject(fromJSON: json) else {
            return
        }
        value = maverickObject.email
        name = maverickObject.emailName
    }
}

extension PersonalWebsite: MaverickPersonalDataDecoder {

    typealias MaverickObject = MaverickWebsite

    struct MaverickWebsite: Decodable {
        let name: String
        let website: String
    }

    mutating func merge(withMaverickJSON json: [String : Any],
                        using decoder: JSONDecoder,
                        regionInformationService: RegionInformationService,
                        vaultItemsService: VaultItemsServiceProtocol,
                        logger: Logger) {

        guard let maverickObject = decodeMaverickObject(fromJSON: json) else {
            return
        }

        name = maverickObject.name
        website = maverickObject.website
    }
}
