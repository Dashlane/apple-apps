#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIKit

  struct ScaledFont: ViewModifier {

    @Environment(\.sizeCategory) var sizeCategory
    var size: CGFloat

    func body(content: Content) -> some View {
      let scaledSize = UIFontMetrics.default.scaledValue(for: size)
      return content.font(.system(size: scaledSize))
    }
  }

  extension View {
    public func scaledFont(size: CGFloat) -> some View {
      return self.modifier(ScaledFont(size: size))
    }
  }
#endif
