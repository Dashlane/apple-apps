import CoreLocalization
import CorePersonalData
import CoreSpotlight
import DocumentServices
import SwiftUI

extension SecureNote: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .secureNote(self)
  }

  public var localizedTitle: String {
    return displayTitle
  }

  public var localizedSubtitle: String {
    guard !secured else {
      return L10n.Core.KWSecureNoteIOS.protectedMessage
    }

    return displaySubtitle ?? ""
  }

  public static var localizedName: String {
    L10n.Core.kwSecureNoteIOS
  }

  public static var addTitle: String {
    L10n.Core.kwadddatakwSecureNoteIOS
  }

  public static var nativeMenuAddTitle: String {
    L10n.Core.addSecureNote
  }
}
