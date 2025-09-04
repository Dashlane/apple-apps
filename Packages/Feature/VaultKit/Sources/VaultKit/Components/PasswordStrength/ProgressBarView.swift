import Combine
import DesignSystem
import Foundation
import SwiftUI

struct ProgressBarView: View {
  let progress: CGFloat
  let total: CGFloat

  let fillColor: Color
  let backgroundColor: Color

  init(
    progress: CGFloat,
    total: CGFloat = 5,
    fillColor: Color,
    backgroundColor: Color = .ds.text.inverse.standard
  ) {
    self.progress = progress
    self.total = total
    self.fillColor = fillColor
    self.backgroundColor = backgroundColor
  }

  var body: some View {
    ProgressBarLayout(progress: progress / total) {
      Capsule()
        .foregroundStyle(fillColor)
    }
    .background(
      Capsule()
        .foregroundStyle(backgroundColor)
    )
    .frame(height: 4)
  }
}

struct ProgressBarLayout: Layout {
  let progress: Double

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    return proposal.replacingUnspecifiedDimensions()
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    assert(subviews.count == 1)
    subviews[0].place(
      at: .init(x: bounds.minX, y: bounds.midY), anchor: .leading,
      proposal: .init(width: progress * bounds.width, height: bounds.height))
  }
}

struct ProgressBarView_Previews: PreviewProvider {

  static var previews: some View {
    Group {
      ForEach(0..<5) { value in
        ProgressBarView(progress: CGFloat(value), fillColor: Color.red)
          .previewDisplayName("Progress \(value)")
      }
    }.padding().previewLayout(.sizeThatFits)
  }
}
