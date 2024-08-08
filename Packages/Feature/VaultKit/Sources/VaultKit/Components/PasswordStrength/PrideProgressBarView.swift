import Combine
import DesignSystem
import Foundation
import SwiftUI

struct PrideProgressBarView: View {
  let progress: CGFloat
  let total: CGFloat

  let fillColor: Color
  let backgroundColor: Color
  let prideColors = [
    Color(asset: Asset.pride1),
    Color(asset: Asset.pride2),
    Color(asset: Asset.pride3),
    Color(asset: Asset.pride4),
    Color(asset: Asset.pride5),
    Color(asset: Asset.pride6),
    Color(asset: Asset.pride7),
    Color(asset: Asset.pride8),
  ]

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
      progress(withColors: progress >= total ? prideColors : [fillColor])
        .cornerRadius(2)
    }
    .background(
      Capsule()
        .foregroundColor(backgroundColor)
    )
    .frame(height: 4)
  }

  func progress(withColors colors: [Color]) -> some View {
    HStack(alignment: .top, spacing: 0) {
      ForEach(colors, id: \.self) { color in
        Rectangle()
          .fill(color)
          .frame(minWidth: 0, maxWidth: .infinity)
      }
    }
  }
}

struct PrideProgressBarView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ForEach(0..<6) { value in
        PrideProgressBarView(progress: CGFloat(value), fillColor: Color.red)
          .previewDisplayName("Progress \(value)")
      }
    }.padding().previewLayout(.sizeThatFits)
  }
}
