import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension Company: VaultItem {
  public var enumerated: VaultItemEnumeration {
    .company(self)
  }

  public var localizedTitle: String {
    guard !name.isEmpty else {
      return CoreL10n.kwCompanyIOS
    }
    return name
  }

  public var localizedSubtitle: String {
    jobTitle
  }

  public static var localizedName: String {
    CoreL10n.kwCompanyIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwCompanyIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addCompany
  }
}
