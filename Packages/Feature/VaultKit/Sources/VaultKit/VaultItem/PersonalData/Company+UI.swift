import Foundation
import CorePersonalData
import SwiftUI
import CoreLocalization

extension Company: VaultItem {
    public var enumerated: VaultItemEnumeration {
        .company(self)
    }

    public var localizedTitle: String {
        guard !name.isEmpty else {
            return L10n.Core.kwCompanyIOS
        }
        return name
    }

    public var localizedSubtitle: String {
        jobTitle
    }

    public static var localizedName: String {
        L10n.Core.kwCompanyIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwCompanyIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addCompany
    }
}
