import CoreLocalization
import CorePersonalData
import CoreSpotlight
import SwiftUI

extension Phone: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .phone(self)
  }

  public var localizedTitle: String {
    guard !name.isEmpty else {
      return CoreL10n.KWAddressIOS.linkedPhone
    }
    return name
  }

  public var localizedSubtitle: String {
    displayPhone
  }

  public static var localizedName: String {
    CoreL10n.kwPhoneIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwPhoneIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addPhoneNumber
  }
}

extension Phone.NumberType {

  typealias KWPhoneIOSTypeL10n = CoreL10n.KWPhoneIOS.`Type`
  public var localizedString: String {
    switch self {
    case .mobile:
      return KWPhoneIOSTypeL10n.phoneTypeMobile
    case .fax:
      return KWPhoneIOSTypeL10n.phoneTypeFax
    case .landline:
      return KWPhoneIOSTypeL10n.phoneTypeLandline
    case .workMobile:
      return KWPhoneIOSTypeL10n.phoneTypeWorkMobile
    case .workLandline:
      return KWPhoneIOSTypeL10n.phoneTypeWorkLandline
    case .workFax:
      return KWPhoneIOSTypeL10n.phoneTypeWorkFax
    case .none:
      return CoreL10n.kwLinkedDefaultOther
    }
  }
}

extension CountryCodeNamePair {
  public static let countries: [CountryCodeNamePair] = {
    Locale.Region.isoRegions.filter { $0.subRegions.isEmpty }
      .compactMap { code -> CountryCodeNamePair? in
        guard let name = Locale.current.localizedString(forRegionCode: code.identifier) else {
          return nil
        }
        return CountryCodeNamePair(code: code.identifier, name: name)
      }
      .sorted { $0.name < $1.name }
  }()
}
