import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

extension SecureNoteColor {
  public var color: Color {
    switch self {
    case .blue:
      return Color(.secureNoteBlue)
    case .purple:
      return Color(.secureNotePurple)
    case .pink:
      return Color(.secureNotePink)
    case .red:
      return Color(.secureNoteRed)
    case .brown:
      return Color(.secureNoteBrown)
    case .green:
      return Color(.secureNoteGreen)
    case .orange:
      return Color(.secureNoteOrange)
    case .yellow:
      return Color(.secureNoteYellow)
    case .gray:
      return Color(.secureNoteGray)
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

typealias SecureNoteL10n = CoreL10n.KWSecureNoteIOS.`Type`
