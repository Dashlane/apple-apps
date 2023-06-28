import Foundation
import AppKit
import SwiftTreats
import VaultKit

struct OpenApplicationRequest: Decodable {

    let identifier: String
    let link: String

    func perform() {
        let dataType = AutofilledMaverickDataType(rawValue: link) ?? .credential
        let deepLink: DeepLink
        if identifier == "new" {
            deepLink = DeepLink.vault(.create(dataType.deeplinkComponent))
        } else {
            deepLink = DeepLink.vault(.fetchAndShow(.init(rawIdentifier: identifier, component: dataType.deeplinkComponent), useEditMode: false))
        }
        guard let url = deepLink.urlRepresentation else {
            assertionFailure()
            return
        }
        NSWorkspace.shared.openMainApplication(url: url)
    }
}

extension AutofilledMaverickDataType {
    var deeplinkComponent: VaultDeepLinkComponent {
        switch self {
        case .credential: return .credential
        case .paymentMeanCreditCard: return .creditCard
        case .address: return .address
        case .bankAccount: return .bankAccount
        case .company: return .company
        case .drivingLicense: return .driverLicense
        case .email: return .email
        case .fiscalInformation: return .fiscal
        case .idCard: return .identityCards
        case .identity: return .identity
        case .passport: return .passports
        case .personalWebsite: return .personalWebsite
        case .phone: return .phone
        case .socialSecurity: return .socialSecurityNumber
        }
    }
}
