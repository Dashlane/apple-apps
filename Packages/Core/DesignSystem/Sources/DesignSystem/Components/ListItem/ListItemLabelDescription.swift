import Foundation
import SwiftUI

public struct ListItemLabelDescription: View {
  @Environment(\.highlightedValue) private var highlightedValue
  @ScaledMetric private var iconHeight = 12

  private let icon: Image?
  private let text: String?

  public init(_ text: String?, icon: Image? = nil) {
    self.text = text
    self.icon = icon
  }

  public var body: some View {
    if let text, !text.isEmpty {
      Label(
        title: {
          if let attributedText = AttributedString.highlightedValue(highlightedValue, in: text) {
            Text(attributedText)
          } else {
            Text(verbatim: text)
          }
        },
        icon: {
          if let icon {
            icon
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: iconHeight)
          }
        }
      )
    } else {
      EmptyView()
    }
  }
}

#Preview("w/ icon") {
  ListItemLabelDescription("Description", icon: .ds.attachment.outlined)
    .highlightedValue("script")
}

#Preview("w/o icon") {
  ListItemLabelDescription("Description")
    .highlightedValue("script")
}
