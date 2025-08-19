import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension Identity: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .identity(self)
  }

  public var localizedTitle: String {
    let displayTitle = self.displayTitle
    guard !displayTitle.isEmpty else { return PersonalTitle.defaultValue.rawValue }
    return displayTitle
  }

  public var localizedSubtitle: String {
    var dob: String = ""
    if let birthDate = birthDate {
      dob = DateFormatter.birthDateFormatter.string(from: birthDate)
    }
    return [dob, birthPlace]
      .filter { !$0.isEmpty }
      .joined(separator: ", ")
  }

  public static var localizedName: String {
    CoreL10n.kwIdentityIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwIdentityIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addName
  }
}

extension Identity.PersonalTitle {

  public var localizedString: String {
    switch self {
    case .mr:
      return CoreL10n.KWIdentityIOS.Title.mr
    case .mrs:
      return CoreL10n.KWIdentityIOS.Title.mme
    case .miss:
      return CoreL10n.KWIdentityIOS.Title.mlle
    case .ms:
      return CoreL10n.KWIdentityIOS.Title.ms
    case .mx:
      return CoreL10n.KWIdentityIOS.Title.mx
    case .noneOfThese:
      return CoreL10n.KWIdentityIOS.Title.noneOfThese
    }
  }

  public static var displayableCases: [Identity.PersonalTitle] {
    return Identity.PersonalTitle.allCases.filterByLocalizedString()
  }
}

extension Identity: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}

extension Array where Element == Identity.PersonalTitle {
  func filterByLocalizedString() -> [Identity.PersonalTitle] {
    var localizedCases = Set<String>()
    return self.filter { value in
      if !localizedCases.contains(value.localizedString) {
        localizedCases.insert(value.localizedString)
        return true
      }
      return false
    }
  }
}
