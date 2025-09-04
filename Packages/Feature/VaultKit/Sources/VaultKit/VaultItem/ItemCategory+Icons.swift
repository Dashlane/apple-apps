import DesignSystem
import SwiftUI

extension ItemCategory {
  public var icon: Image {
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
    case .wifi:
      return .ds.item.wifi.outlined
    }
  }
}
