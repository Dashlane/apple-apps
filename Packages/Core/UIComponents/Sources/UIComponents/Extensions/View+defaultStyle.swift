import DesignSystem
import SwiftUI

extension View {
  #if !targetEnvironment(macCatalyst)
    func dashlaneDefaultStyle() -> some View {
      self
    }
  #else
    func dashlaneDefaultStyle() -> some View {
      self
        .buttonStyle(ColoredButtonStyle(color: .ds.text.brand.standard))
    }
  #endif
}
