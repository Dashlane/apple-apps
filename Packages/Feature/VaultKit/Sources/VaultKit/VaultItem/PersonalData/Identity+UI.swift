import Foundation
import CorePersonalData
import SwiftUI
import CoreLocalization

extension Identity: VaultItem {
    public var enumerated: VaultItemEnumeration {
        return .identity(self)
    }

    public var localizedTitle: String {
        let displayTitle = self.displayTitle
        guard !displayTitle.isEmpty else { return PersonalTitle.defaultValue.rawValue }
        return displayTitle
    }

    public var localizedSubtitle: String {
        var dob: String = ""
        if let birthDate = birthDate {
            dob = DateFormatter.mediumDateFormatter.string(from: birthDate)
        }
        return [dob, birthPlace]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    public static var localizedName: String {
        L10n.Core.kwIdentityIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwIdentityIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addName
    }
}

extension Identity.PersonalTitle {

    public var localizedString: String {
        switch self {
        case .mr:
            return L10n.Core.KWIdentityIOS.Title.mr
        case .mrs:
            return L10n.Core.KWIdentityIOS.Title.mme
        case .miss:
            return L10n.Core.KWIdentityIOS.Title.mlle
        case .ms:
            return L10n.Core.KWIdentityIOS.Title.ms
        case .mx:
            return L10n.Core.KWIdentityIOS.Title.mx
        case .noneOfThese:
            return L10n.Core.KWIdentityIOS.Title.noneOfThese
        }
    }

    public static var displayableCases: [Identity.PersonalTitle] {
        return Identity.PersonalTitle.allCases.filterByLocalizedString()
    }
}

extension Identity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension Array where Element == Identity.PersonalTitle {
    func filterByLocalizedString() -> [Identity.PersonalTitle] {
        var localizedCases = Set<String>()
        return self.filter { value in
            if !localizedCases.contains(value.localizedString) {
                localizedCases.insert(value.localizedString)
                return true
            }
            return false
        }
    }
}
