import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension SecureNoteColor {
  public var color: Color {
    switch self {
    case .blue:
      return Color(asset: Asset.secureNoteBlue)
    case .purple:
      return Color(asset: Asset.secureNotePurple)
    case .pink:
      return Color(asset: Asset.secureNotePink)
    case .red:
      return Color(asset: Asset.secureNoteRed)
    case .brown:
      return Color(asset: Asset.secureNoteBrown)
    case .green:
      return Color(asset: Asset.secureNoteGreen)
    case .orange:
      return Color(asset: Asset.secureNoteOrange)
    case .yellow:
      return Color(asset: Asset.secureNoteYellow)
    case .gray:
      return Color(asset: Asset.secureNoteGray)
    }
  }

  public var localizedName: String {
    switch self {
    case .blue:
      return SecureNoteL10n.blue
    case .purple:
      return SecureNoteL10n.purple
    case .pink:
      return SecureNoteL10n.pink
    case .red:
      return SecureNoteL10n.red
    case .brown:
      return SecureNoteL10n.brown
    case .green:
      return SecureNoteL10n.green
    case .orange:
      return SecureNoteL10n.orange
    case .yellow:
      return SecureNoteL10n.yellow
    case .gray:
      return SecureNoteL10n.gray
    }
  }
}

typealias SecureNoteL10n = L10n.Core.KWSecureNoteIOS.`Type`
