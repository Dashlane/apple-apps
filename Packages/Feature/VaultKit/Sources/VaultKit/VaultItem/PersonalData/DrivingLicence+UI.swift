import CoreLocalization
import CorePersonalData
import CoreTypes
import Foundation
import SwiftUI

extension DrivingLicence: VaultItem {
  public var enumerated: VaultItemEnumeration {
    .drivingLicence(self)
  }

  public var localizedTitle: String {
    CoreL10n.kwDriverLicenceIOS
  }

  public var localizedSubtitle: String {
    displayFullName
  }

  public static var localizedName: String {
    CoreL10n.kwDriverLicenceIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwDriverLicenceIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addDriverLicense
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

extension DrivingLicence {
  public var genderString: String {
    return sex?.localized ?? ""
  }
}
