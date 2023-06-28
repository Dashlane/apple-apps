import Foundation
import CorePersonalData
import SwiftUI
import CoreLocalization

extension PersonalWebsite: VaultItem {
    public var enumerated: VaultItemEnumeration {
        return .personalWebsite(self)
    }

    public var localizedTitle: String {
        guard !name.isEmpty else {
            return L10n.Core.kwPersonalWebsiteIOS
        }
        return name
    }

    public var localizedSubtitle: String {
        return website
    }

    public static var localizedName: String {
        L10n.Core.kwPersonalWebsiteIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwPersonalWebsiteIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addWebsite
    }
}
