import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension IDCard: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .idCard(self)
  }

  public var localizedTitle: String {
    L10n.Core.kwidCardIOS
  }

  public var localizedSubtitle: String {
    displayFullName
  }

  public static var localizedName: String {
    L10n.Core.kwidCardIOS
  }

  public static var addTitle: String {
    L10n.Core.kwadddatakwidCardIOS
  }

  public static var nativeMenuAddTitle: String {
    L10n.Core.addIDCard
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
      return L10n.Core.KWIDCardIOS.Sex.female
    case .male:
      return L10n.Core.KWIDCardIOS.Sex.male
    }
  }
}
