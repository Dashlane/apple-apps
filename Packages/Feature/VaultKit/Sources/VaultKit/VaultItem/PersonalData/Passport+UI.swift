import CoreLocalization
import CorePersonalData
import CoreTypes
import Foundation
import SwiftUI

extension Passport: VaultItem {
  public var enumerated: VaultItemEnumeration {
    .passport(self)
  }

  public var localizedTitle: String {
    CoreL10n.kwPassportIOS
  }

  public var localizedSubtitle: String {
    displayFullName
  }

  public static var localizedName: String {
    CoreL10n.kwPassportIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwPassportIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addPassport
  }
}

extension Passport: CopiablePersonalData {
  public var valueToCopy: String {
    return number
  }

  public var fieldToCopy: DetailFieldType {
    return .number
  }
}

extension Passport {
  public var genderString: String {
    return sex?.localized ?? ""
  }
}
