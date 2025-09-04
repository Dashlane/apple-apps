import SwiftUI

struct LabelContainer: Layout {
  let isReduced: Bool

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    return CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    guard let labelView = subviews.first else { return }
    let size = labelView.dimensions(in: proposal)
    let origin = CGPoint(
      x: bounds.origin.x,
      y: isReduced
        ? bounds.minY + (size.height / 2)
        : bounds.midY
    )
    labelView.place(at: origin, anchor: .leading, proposal: proposal)
  }
}

extension ShapeStyle where Self == LabelShapeStyle {
  static func label(isFocused: Bool) -> Self {
    LabelShapeStyle(isFocused: isFocused)
  }
}

struct LabelShapeStyle: ShapeStyle {
  private let isFocused: Bool

  init(isFocused: Bool) {
    self.isFocused = isFocused
  }

  func resolve(in environment: EnvironmentValues) -> Color {
    guard environment.style.mood == .brand && !isFocused && environment.isEnabled else {
      return TextShapeStyle().resolve(in: environment)
    }

    return .ds.text.neutral.quiet
  }
}
