import Foundation
import CoreSpotlight
import CorePersonalData
#if canImport(MobileCoreServices)
import MobileCoreServices
#endif
import DashlaneAppKit
import VaultKit
import UniformTypeIdentifiers

private let spotlightDefaultExpirationInterval: TimeInterval = 60 * 60 * 24 * 30 * 6; 

protocol SpotLightSearchable {
    var spotlightAttributeSet: CSSearchableItemAttributeSet? { get }
}

extension CSSearchableItem {
    convenience init?(item: VaultItem & SpotLightSearchable) {
        guard let attributeSet = item.spotlightAttributeSet else {
            return nil
        }

        self.init(uniqueIdentifier: item.deepLinkIdentifier.rawValue,
                  domainIdentifier: SpotlightDomainIdentifier.vaultItem.rawValue,
                  attributeSet: attributeSet)
        expirationDate = Date().addingTimeInterval(spotlightDefaultExpirationInterval)
    }
}

extension CSSearchableItemAttributeSet {
    static func makeItem() -> CSSearchableItemAttributeSet {
        return CSSearchableItemAttributeSet(contentType: UTType.item)
    }
}

extension SpotLightSearchable where Self: VaultItem {
    var spotlightAttributeSet: CSSearchableItemAttributeSet? {
        let attr = CSSearchableItemAttributeSet.makeItem()
        attr.title = localizedTitle
        attr.contentDescription = localizedSubtitle
        attr.keywords = [Self.localizedName].compactMap { $0 }
        attr.relatedUniqueIdentifier = deepLinkIdentifier.rawValue
        return attr
    }
}

extension Credential: SpotLightSearchable {
    var spotlightAttributeSet: CSSearchableItemAttributeSet? {
        guard let domain = url?.displayDomain else {
            return nil
        }

        let attr = CSSearchableItemAttributeSet.makeItem()
        attr.title = self.localizedTitle
        attr.contentDescription = L10n.Localizable.kwCorespotlightTitleAuth(domain)
        attr.keywords = [Credential.localizedName, domain]
        attr.relatedUniqueIdentifier = deepLinkIdentifier.rawValue
        return attr
    }
}

extension CreditCard: SpotLightSearchable {
    var spotlightAttributeSet: CSSearchableItemAttributeSet? {
        let attr = CSSearchableItemAttributeSet.makeItem()
        attr.title = L10n.Localizable.kwCorespotlightTitleCreditcard(self.localizedTitle)
        attr.contentDescription = L10n.Localizable.kwCorespotlightDescCreditcard
        attr.keywords = [Self.localizedName, bank?.name].compactMap { $0 }
        attr.relatedUniqueIdentifier = deepLinkIdentifier.rawValue
        return attr
    }
}

extension BankAccount: SpotLightSearchable {
    var spotlightAttributeSet: CSSearchableItemAttributeSet? {
        let attr = CSSearchableItemAttributeSet.makeItem()
        attr.title = L10n.Localizable.kwCorespotlightTitleCreditcard(self.localizedTitle)
        attr.contentDescription =  L10n.Localizable.kwCorespotlightDescBankAccount
        attr.keywords = [Self.localizedName,
                         L10n.Localizable.KWBankStatementIOS.bicFieldTitle(for: bicVariant),
                         L10n.Localizable.KWBankStatementIOS.ibanFieldTitle(for: ibanVariant),
                         bank?.name].compactMap { $0 }
        attr.relatedUniqueIdentifier = deepLinkIdentifier.rawValue
        return attr
    }
}

extension Passport: SpotLightSearchable { }
extension DrivingLicence: SpotLightSearchable { }
extension SocialSecurityInformation: SpotLightSearchable { }
extension IDCard: SpotLightSearchable { }
extension FiscalInformation: SpotLightSearchable { }

extension NSUserActivity {
    func update<T: VaultItem>(with item: T) {
        let identifier = item.deepLinkIdentifier.rawValue
        if let item = item as? SpotLightSearchable {
            let set = item.spotlightAttributeSet
            isEligibleForSearch = true
            #if os(iOS)
            isEligibleForPrediction = true
            #endif
            contentAttributeSet = set
            title = set?.title
        } else {
            let set = CSSearchableItemAttributeSet.makeItem()
            set.relatedUniqueIdentifier = identifier
            isEligibleForSearch = false
            #if os(iOS)
            isEligibleForPrediction = false
            #endif
            contentAttributeSet = set
            title = T.localizedName
        }

        self[.deeplink] = identifier
    }
}
