import DesignSystem
import SwiftUI
import UIDelight

public struct LoginFieldBox<Content: View>: View {
  private let content: Content
  private let height: CGFloat
  private let backgroundColor: Color

  public init(
    height: CGFloat = 60,
    backgroundColor: Color = .ds.background.alternate,
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.height = height
    self.backgroundColor = backgroundColor
  }

  public var body: some View {
    HStack {
      content
    }
    .foregroundStyle(.primary)
    .frame(height: height)
    .background(backgroundColor)
  }
}

#Preview {
  VStack {
    LoginFieldBox {
      TextField("", text: .constant("a text field"))
    }
  }
  .background(Color.ds.background.default)
}
