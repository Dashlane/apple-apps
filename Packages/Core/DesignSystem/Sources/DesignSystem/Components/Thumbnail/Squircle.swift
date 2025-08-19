import Foundation
import SwiftUI

struct Squircle: InsettableShape {
  private let insetAmount: CGFloat

  init(insetAmount: CGFloat = 0) {
    self.insetAmount = insetAmount
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width - 2 * insetAmount
    let height = rect.size.height - 2 * insetAmount

    path.move(
      to: CGPoint(
        x: 0.77085 * width + insetAmount,
        y: 0.03741 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.96259 * width + insetAmount,
        y: 0.22915 * height + insetAmount
      ),
      control1: CGPoint(
        x: 0.86365 * width + insetAmount,
        y: 0.06368 * height + insetAmount
      ),
      control2: CGPoint(
        x: 0.93632 * width + insetAmount,
        y: 0.13635 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: width + insetAmount,
        y: 0.5 * height + insetAmount
      ),
      control1: CGPoint(
        x: 0.98696 * width + insetAmount,
        y: 0.31524 * height + insetAmount
      ),
      control2: CGPoint(
        x: width + insetAmount,
        y: 0.4061 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.96259 * width + insetAmount,
        y: 0.77085 * height + insetAmount
      ),
      control1: CGPoint(
        x: width + insetAmount,
        y: 0.5939 * height + insetAmount
      ),
      control2: CGPoint(
        x: 0.98696 * width + insetAmount,
        y: 0.68476 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.77085 * width + insetAmount,
        y: 0.96259 * height + insetAmount
      ),
      control1: CGPoint(
        x: 0.93632 * width + insetAmount,
        y: 0.86365 * height + insetAmount
      ),
      control2: CGPoint(
        x: 0.86365 * width + insetAmount,
        y: 0.93632 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.5 * width + insetAmount,
        y: height + insetAmount
      ),
      control1: CGPoint(
        x: 0.68476 * width + insetAmount,
        y: 0.98696 * height + insetAmount
      ),
      control2: CGPoint(
        x: 0.5939 * width + insetAmount,
        y: height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.22915 * width + insetAmount,
        y: 0.96259 * height + insetAmount
      ),
      control1: CGPoint(
        x: 0.4061 * width + insetAmount,
        y: height + insetAmount
      ),
      control2: CGPoint(
        x: 0.31524 * width + insetAmount,
        y: 0.98696 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.03741 * width + insetAmount,
        y: 0.77085 * height + insetAmount
      ),
      control1: CGPoint(
        x: 0.13635 * width + insetAmount,
        y: 0.93632 * height + insetAmount
      ),
      control2: CGPoint(
        x: 0.06368 * width + insetAmount,
        y: 0.86365 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: insetAmount,
        y: 0.5 * height + insetAmount
      ),
      control1: CGPoint(
        x: 0.01304 * width + insetAmount,
        y: 0.68476 * height + insetAmount
      ),
      control2: CGPoint(
        x: insetAmount,
        y: 0.5939 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.03741 * width + insetAmount,
        y: 0.22915 * height + insetAmount
      ),
      control1: CGPoint(
        x: insetAmount,
        y: 0.4061 * height + insetAmount
      ),
      control2: CGPoint(
        x: 0.01304 * width + insetAmount,
        y: 0.31524 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.22915 * width + insetAmount,
        y: 0.03741 * height + insetAmount
      ),
      control1: CGPoint(
        x: 0.06368 * width + insetAmount,
        y: 0.13635 * height + insetAmount
      ),
      control2: CGPoint(
        x: 0.13635 * width + insetAmount,
        y: 0.06368 * height + insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.5 * width + insetAmount,
        y: insetAmount
      ),
      control1: CGPoint(
        x: 0.31524 * width + insetAmount,
        y: 0.01304 * height + insetAmount
      ),
      control2: CGPoint(
        x: 0.4061 * width + insetAmount,
        y: insetAmount
      )
    )
    path.addCurve(
      to: CGPoint(
        x: 0.77085 * width + insetAmount,
        y: 0.03741 * height + insetAmount
      ),
      control1: CGPoint(
        x: 0.5939 * width + insetAmount,
        y: insetAmount
      ),
      control2: CGPoint(
        x: 0.68476 * width + insetAmount,
        y: 0.01304 * height + insetAmount
      )
    )
    path.closeSubpath()

    return path
  }
  func inset(by amount: CGFloat) -> some InsettableShape {
    Squircle(insetAmount: amount)
  }
}

#Preview {
  Squircle()
    .frame(width: 128, height: 128)
    .overlay(
      Squircle()
        .inset(by: 8)
        .foregroundStyle(Color.yellow)
    )
}
