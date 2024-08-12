import DesignSystem
import Foundation
import SwiftUI

public struct BorderedIcon: ViewModifier {

  let sizeType: IconSizeType
  let color: SwiftUI.Color

  public init(
    sizeType: IconSizeType,
    color: SwiftUI.Color = .ds.border.neutral.quiet.idle
  ) {
    self.sizeType = sizeType
    self.color = color
  }

  public func body(content: Content) -> some View {
    content
      .overlay(
        RoundedRectangle(cornerRadius: sizeType.radius)
          .inset(by: 0.5)
          .stroke(color, lineWidth: 1)
      )
  }
}
