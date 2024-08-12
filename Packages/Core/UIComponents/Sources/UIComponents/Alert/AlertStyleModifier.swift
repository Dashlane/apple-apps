#if canImport(UIKit)
  import SwiftUI
  import UIDelight

  public struct AlertStyle: ViewModifier {
    @State
    private var isDisplayed: Bool = false

    public init() {}

    public func body(content: Content) -> some View {
      content
        .background(Material.regular)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .opacity(isDisplayed ? 1.0 : 0)
        .frame(width: 270)
        .padding()
        .scaleEffect(isDisplayed ? 1.0 : 1.5)
        .offset(x: 0, y: isDisplayed ? 0 : 300)
        .onAppear {
          withAnimation(.spring(response: 0.404)) {
            self.isDisplayed = true
          }
        }
    }
  }

  struct AlertStyleModifier_Previews: PreviewProvider {
    static var previews: some View {
      ZStack {
        Text("Hello, World!")
          .padding()
          .modifier(AlertStyle())

      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.gray)

    }
  }
#endif
