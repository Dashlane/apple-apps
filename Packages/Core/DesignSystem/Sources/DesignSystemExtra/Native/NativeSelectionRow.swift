import DesignSystem
import SwiftUI
import UIDelight

public struct NativeSelectionRow<Content: View>: View {
  let content: Content
  let isSelected: Bool

  let spacing: CGFloat?
  let size: CGFloat

  public init(
    isSelected: Bool,
    spacing: CGFloat? = nil,
    size: CGFloat = 24,
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.spacing = spacing
    self.isSelected = isSelected
    self.size = size
  }

  public var body: some View {
    HStack(spacing: spacing) {
      NativeCheckmarkIcon(isChecked: isSelected)
        .frame(width: size, height: size)
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .animation(.easeInOut, value: isSelected)
    .accessibilityAddTraits(isSelected ? .isSelected : .isButton)
  }
}

extension AnyTransition {
  static var selectAnyTransition: AnyTransition {
    AnyTransition.asymmetric(
      insertion: .scale(scale: 1.6),
      removal: .scale(scale: 0.5)
    )
    .combined(with: .opacity)
  }
}

private struct TestView: View {
  @State
  var isSelected: Bool
  let text: String

  var body: some View {
    NativeSelectionRow(isSelected: isSelected) {
      Text(text)
    }
    .onTapWithFeedback {
      isSelected.toggle()
    }
    .padding()
    .background(.ds.background.default)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  VStack {
    TestView(isSelected: false, text: "The Spice must Flow")
    Divider()
    TestView(isSelected: true, text: "Fear is the mind-killer")
  }
}
