import CorePersonalData
import SwiftUI
import CoreSpotlight
import CoreLocalization

extension Phone: VaultItem {
    public var enumerated: VaultItemEnumeration {
        return .phone(self)
    }

    public var localizedTitle: String {
        guard !name.isEmpty else {
            return L10n.Core.KWAddressIOS.linkedPhone
        }
        return name
    }

    public var localizedSubtitle: String {
        displayPhone
    }

    public static var localizedName: String {
        L10n.Core.kwPhoneIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwPhoneIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addPhoneNumber
    }
}

extension Phone {
    public var displayPhone: String {
        if !interNationalNumber.isEmpty {
            return interNationalNumber
        } else if !nationalNumber.isEmpty {
            return nationalNumber
        }
        return number
    }
}

extension Phone.NumberType {

    typealias KWPhoneIOSTypeL10n = L10n.Core.KWPhoneIOS.`Type`
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
            return L10n.Core.kwLinkedDefaultOther
        }
    }
}

extension CountryCodeNamePair {
    public static let countries: [CountryCodeNamePair] = {
        Locale.Region.isoRegions
            .compactMap { code -> CountryCodeNamePair? in
                guard let name = Locale.current.localizedString(forRegionCode: code.identifier) else {
                    return nil
                }
                return CountryCodeNamePair(code: code.identifier, name: name)
            }
            .sorted { $0.name < $1.name }
    }()
}
