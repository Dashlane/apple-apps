import CoreLocalization
import CorePersonalData
import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

#if canImport(MobileCoreServices)
  import MobileCoreServices
#endif

private let spotlightDefaultExpirationInterval: TimeInterval = 60 * 60 * 24 * 30 * 6

protocol SpotLightSearchable {
  var spotlightAttributeSet: CSSearchableItemAttributeSet? { get }
}

extension CSSearchableItem {
  convenience init?(item: VaultItem & SpotLightSearchable) {
    guard let attributeSet = item.spotlightAttributeSet else {
      return nil
    }

    self.init(
      uniqueIdentifier: item.deepLinkIdentifier.rawValue,
      domainIdentifier: SpotlightDomainIdentifier.vaultItem.rawValue,
      attributeSet: attributeSet)
    expirationDate = Date().addingTimeInterval(spotlightDefaultExpirationInterval)
  }
}

extension CSSearchableItemAttributeSet {
  public static func makeItem() -> CSSearchableItemAttributeSet {
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
    attr.contentDescription = L10n.Core.kwCorespotlightTitleAuth(domain)
    attr.keywords = [Credential.localizedName, domain]
    attr.relatedUniqueIdentifier = deepLinkIdentifier.rawValue
    return attr
  }
}

extension CreditCard: SpotLightSearchable {
  var spotlightAttributeSet: CSSearchableItemAttributeSet? {
    let attr = CSSearchableItemAttributeSet.makeItem()
    attr.title = L10n.Core.kwCorespotlightTitleCreditcard(self.localizedTitle)
    attr.contentDescription = L10n.Core.kwCorespotlightDescCreditcard
    attr.keywords = [Self.localizedName, bank?.name].compactMap { $0 }
    attr.relatedUniqueIdentifier = deepLinkIdentifier.rawValue
    return attr
  }
}

extension BankAccount: SpotLightSearchable {
  var spotlightAttributeSet: CSSearchableItemAttributeSet? {
    let attr = CSSearchableItemAttributeSet.makeItem()
    attr.title = L10n.Core.kwCorespotlightTitleCreditcard(self.localizedTitle)
    attr.contentDescription = L10n.Core.kwCorespotlightDescBankAccount
    attr.keywords = [
      Self.localizedName,
      L10n.Core.KWBankStatementIOS.bicFieldTitle(for: bicVariant),
      L10n.Core.KWBankStatementIOS.ibanFieldTitle(for: ibanVariant),
      bank?.name,
    ].compactMap { $0 }
    attr.relatedUniqueIdentifier = deepLinkIdentifier.rawValue
    return attr
  }
}

extension Passport: SpotLightSearchable {}
extension DrivingLicence: SpotLightSearchable {}
extension SocialSecurityInformation: SpotLightSearchable {}
extension IDCard: SpotLightSearchable {}
extension FiscalInformation: SpotLightSearchable {}

extension NSUserActivity {
  public func update<T: VaultItem>(with item: T) {
    let identifier = item.deepLinkIdentifier.rawValue
    if let item = item as? SpotLightSearchable {
      let set = item.spotlightAttributeSet
      isEligibleForSearch = true
      isEligibleForPrediction = true
      contentAttributeSet = set
      title = set?.title
    } else {
      let set = CSSearchableItemAttributeSet.makeItem()
      set.relatedUniqueIdentifier = identifier
      isEligibleForSearch = false
      isEligibleForPrediction = false
      contentAttributeSet = set
      title = T.localizedName
    }

    self[.deeplink] = identifier
  }
}

public enum UserActivityInfoKey: String {
  case deeplink
}

extension NSUserActivity {
  public subscript(_ key: UserActivityInfoKey) -> Any? {
    get {
      userInfo?[key.rawValue]
    }
    set {
      if let value = newValue {
        addUserInfoEntries(from: [key.rawValue: value])
      } else {
        self.userInfo?.removeValue(forKey: key.rawValue)
      }
    }
  }
}
