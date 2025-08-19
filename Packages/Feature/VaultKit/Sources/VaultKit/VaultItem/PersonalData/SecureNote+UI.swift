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
      return CoreL10n.KWSecureNoteIOS.protectedMessage
    }

    return displaySubtitle ?? ""
  }

  public static var localizedName: String {
    CoreL10n.kwSecureNoteIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwSecureNoteIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addSecureNote
  }
}
