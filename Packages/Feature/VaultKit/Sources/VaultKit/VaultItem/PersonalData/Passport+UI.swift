import CoreLocalization
import CorePersonalData
import DashTypes
import Foundation
import SwiftUI

extension Passport: VaultItem {
  public var enumerated: VaultItemEnumeration {
    .passport(self)
  }

  public var localizedTitle: String {
    L10n.Core.kwPassportIOS
  }

  public var localizedSubtitle: String {
    displayFullName
  }

  public static var localizedName: String {
    L10n.Core.kwPassportIOS
  }

  public static var addTitle: String {
    L10n.Core.kwadddatakwPassportIOS
  }

  public static var nativeMenuAddTitle: String {
    L10n.Core.addPassport
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
