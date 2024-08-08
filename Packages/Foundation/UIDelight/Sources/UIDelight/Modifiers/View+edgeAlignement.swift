import SwiftUI

extension View {
  public func alignmentGuide(
    _ alignement: VerticalAlignment, to alignementComputed: VerticalAlignment
  ) -> some View {
    return self.alignmentGuide(alignement) {
      $0[alignementComputed]
    }
  }
}
