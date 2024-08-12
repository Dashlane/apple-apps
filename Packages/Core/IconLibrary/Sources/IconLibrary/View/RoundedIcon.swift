import Foundation
import SwiftUI

public struct RoundedIcon: ViewModifier {

  let sizeType: IconSizeType

  public init(sizeType: IconSizeType) {
    self.sizeType = sizeType
  }

  public func body(content: Content) -> some View {
    content
      .clipShape(RoundedRectangle(cornerRadius: sizeType.radius))
  }
}
