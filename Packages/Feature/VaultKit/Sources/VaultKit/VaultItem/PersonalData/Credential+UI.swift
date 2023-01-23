import Foundation
import DashTypes
import CorePersonalData
import SwiftUI
import CoreLocalization
import CorePremium

extension Credential: VaultItem {
    public var enumerated: VaultItemEnumeration {
        .credential(self)
    }

    public var localizedTitle: String {
        displayTitle
    }

    public var localizedSubtitle: String {
        displaySubtitle ?? ""
    }

    public static var localizedName: String {
        L10n.Core.KWAuthentifiantIOS.password
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwAuthentifiantIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addPassword
    }

    public func isAssociated(to team: BusinessTeam) -> Bool {
        let properties = [
            self.login,
            self.email,
            self.url?.rawValue ?? "",
            self.secondaryLogin
        ]
        +
        self.linkedServices.associatedDomains.map { $0.domain }

        return properties.contains {
            team.isValueMatchingDomains($0)
        }
    }

        public var logData: VaultItemUsageLogData {
        let note: String? = self.note.isEmpty ? nil : self.note
        return VaultItemUsageLogData(website: url?.displayDomain,
                                     details: note,
                                     origin: .inApp,
                                     category: category?.name)
    }
}

extension Credential: CopiablePersonalData {
    public var fieldToCopy: DetailFieldType {
        return .password
    }

    public var valueToCopy: String {
        return password
    }
}
