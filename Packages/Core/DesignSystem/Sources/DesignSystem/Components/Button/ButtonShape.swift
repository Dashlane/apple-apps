import SwiftTreats
import SwiftUI

struct ButtonShape: InsettableShape {
  private let shape: any InsettableShape

  init(cornerRadius: CGFloat) {
    if Device.is(.vision) {
      self.shape = Capsule()
    } else {
      self.shape = RoundedRectangle(cornerRadius: cornerRadius)
    }
  }

  private init(shape: any InsettableShape) {
    self.shape = shape
  }

  nonisolated func path(in rect: CGRect) -> Path {
    return shape.path(in: rect)
  }

  nonisolated func inset(by amount: CGFloat) -> some InsettableShape {
    ButtonShape(shape: shape.inset(by: amount))
  }
}
