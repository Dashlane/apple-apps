import SwiftUI

public enum ScrollContentBackgroundStyle {
  case `default`
  case alternate

  var backgroundColor: Color {
    switch self {
    case .default:
      return Color.ds.background.default
    case .alternate:
      return .ds.background.alternate
    }
  }
}

extension View {
  public func scrollContentBackgroundStyle(_ style: ScrollContentBackgroundStyle) -> some View {
    self
      .background(style.backgroundColor)
      .scrollContentBackground(.hidden)
  }
}

#Preview("default") {
  ScrollView {
    Text("Text")
    DS.TextField("Firstname", text: .constant("Walter"))
  }.scrollContentBackgroundStyle(.default)
}

#Preview("alternate") {
  ScrollView {
    Text("Text")
    DS.TextField("Firstname", text: .constant("Walter"))
  }.scrollContentBackgroundStyle(.alternate)
}
