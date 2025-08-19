import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension IDCard: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .idCard(self)
  }

  public var localizedTitle: String {
    CoreL10n.kwidCardIOS
  }

  public var localizedSubtitle: String {
    displayFullName
  }

  public static var localizedName: String {
    CoreL10n.kwidCardIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwidCardIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addIDCard
  }
}

extension IDCard: CopiablePersonalData {
  public var valueToCopy: String {
    return number
  }

  public var fieldToCopy: DetailFieldType {
    return .number
  }
}

extension IDCard {
  public var genderString: String {
    return sex?.localized ?? ""
  }
}

extension Gender {
  public var localized: String {
    switch self {
    case .female:
      return CoreL10n.KWIDCardIOS.Sex.female
    case .male:
      return CoreL10n.KWIDCardIOS.Sex.male
    }
  }
}
