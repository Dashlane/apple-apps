import Foundation
import DashTypes
import CorePersonalData
import SwiftUI
import CoreLocalization

extension DrivingLicence: VaultItem {
    public var enumerated: VaultItemEnumeration {
        .drivingLicence(self)
    }

    public var localizedTitle: String {
        L10n.Core.kwDriverLicenceIOS
    }

    public var localizedSubtitle: String {
        displayFullName
    }

    public static var localizedName: String {
        L10n.Core.kwDriverLicenceIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwDriverLicenceIOS
    }
    
    public static var nativeMenuAddTitle: String {
        L10n.Core.addDriverLicense
    }
}

extension DrivingLicence: CopiablePersonalData {
    public var valueToCopy: String {
        return number
    }

    public var fieldToCopy: DetailFieldType {
        return .number
    }
}

public extension DrivingLicence {
    var genderString: String {
        return sex?.localized ?? ""
    }

    var hasExpireDate: Bool {
        guard let country = country else { return false }
        return country.code.lowercased() != "fr"
    }
}
