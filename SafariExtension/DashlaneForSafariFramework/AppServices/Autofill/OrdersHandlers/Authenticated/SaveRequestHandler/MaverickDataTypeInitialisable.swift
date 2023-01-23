import Foundation
import CorePersonalData
import CoreRegion
import DashlaneAppKit

enum MavericDataTypeSaveable: String {
    case email = "EMAIL"
    case credential = "AUTHENTIFIANT"
    case identity = "IDENTITY"
    case address = "ADDRESS"
    case phone = "PHONE"
    case company = "COMPANY"
    case website = "WEBSITE"
    case paymentMeanCreditCard = "PAYMENT_MEAN_CREDITCARD"
}

protocol MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { get }
    init()
}

extension MaverickDataTypeInitialisable {
    mutating func correctFields(regionInformationService: RegionInformationService) { }
}

extension Credential: MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { return .credential }
}

extension Address: MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { return .address }
}

extension Company: MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { return .company }
}

extension Email: MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { return .email }
}

extension Identity: MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { return .identity }
}

extension CreditCard: MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { return .paymentMeanCreditCard }
}

extension PersonalWebsite: MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { return .website }
}

extension Phone: MaverickDataTypeInitialisable {
    static var maverickSaveableType: MavericDataTypeSaveable { return .phone }
}
