import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension PersonalWebsite: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .personalWebsite(self)
  }

  public var localizedTitle: String {
    guard !name.isEmpty else {
      return CoreL10n.kwPersonalWebsiteIOS
    }
    return name
  }

  public var localizedSubtitle: String {
    return website
  }

  public static var localizedName: String {
    CoreL10n.kwPersonalWebsiteIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwPersonalWebsiteIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addWebsite
  }
}
