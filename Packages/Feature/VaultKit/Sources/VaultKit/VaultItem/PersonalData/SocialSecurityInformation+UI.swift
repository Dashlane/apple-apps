import CoreLocalization
import CorePersonalData
import DashTypes
import Foundation
import SwiftUI

extension SocialSecurityInformation: VaultItem {
  public var enumerated: VaultItemEnumeration {
    .socialSecurityInformation(self)
  }

  public var localizedTitle: String {
    return L10n.Core.kwSocialSecurityStatementIOS
  }

  public var localizedSubtitle: String {
    !displayFullName.isEmpty ? displayFullName : hiddenNumber
  }

  public static var localizedName: String {
    L10n.Core.kwSocialSecurityStatementIOS
  }

  public static var addTitle: String {
    L10n.Core.kwadddatakwSocialSecurityStatementIOS
  }

  public static var nativeMenuAddTitle: String {
    L10n.Core.addSocialSecurityNumber
  }
}

extension SocialSecurityInformation: CopiablePersonalData {
  public var valueToCopy: String {
    return number
  }

  public var fieldToCopy: DetailFieldType {
    return .socialSecurityNumber
  }
}

extension SocialSecurityInformation {
  var hiddenNumber: String {
    return !number.isEmpty ? "XXXXXXXXXX" : ""
  }
}

extension SocialSecurityInformation {
  public var editableBirthDate: Date? {
    get {
      dateOfBirth
    }
    set {
      guard newValue != nil else {
        dateOfBirth = nil
        return
      }
    }
  }

  public var genderString: String {
    return sex?.localized ?? ""
  }
}
