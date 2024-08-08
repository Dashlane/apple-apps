import DesignSystem
import Foundation
import SwiftUI

extension ItemCategory {
  public var icon: SwiftUI.Image {
    switch self {
    case .credentials:
      return .ds.item.login.outlined
    case .secureNotes:
      return .ds.item.secureNote.outlined
    case .payments:
      return .ds.item.payment.outlined
    case .personalInfo:
      return .ds.item.personalInfo.outlined
    case .ids:
      return .ds.item.id.outlined
    case .secrets:
      return .ds.item.secret.outlined
    }
  }

  public var placeholderIcon: SwiftUI.Image { icon }
}
