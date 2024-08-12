#if canImport(UIKit)

  import SwiftUI
  import UIDelight
  import DesignSystem

  public struct LoginFieldBox<Content: View>: View {
    private let content: Content
    private let height: CGFloat
    private let backgroundColor: Color

    public init(
      height: CGFloat = 60,
      backgroundColor: Color = .ds.container.agnostic.neutral.quiet,
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
      .foregroundColor(.primary)
      .frame(height: height)
      .background(backgroundColor)
    }
  }

  struct LoginFieldBox_Previews: PreviewProvider {
    static var previews: some View {
      MultiContextPreview {
        VStack {
          LoginFieldBox {
            TextField("", text: .constant("a text field"))
          }
        }.backgroundColorIgnoringSafeArea(.ds.background.default)
      }
    }
  }

#endif
