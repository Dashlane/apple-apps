import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight

extension View {
  public func loginAppearance(backgroundColor: SwiftUI.Color? = nil) -> some View {
    modifier(
      LoginViewStyle(backgroundColor: backgroundColor ?? .ds.background.alternate)
    )
  }
}

struct LoginViewStyle: ViewModifier {
  let backgroundColor: SwiftUI.Color

  func body(content: Content) -> some View {
    ZStack {
      let limitSize = Device.is(.pad, .mac, .vision)
      backgroundColor.edgesIgnoringSafeArea(.all)
      content
        .frame(
          maxWidth: limitSize ? 550 : nil,
          maxHeight: limitSize ? 890 : nil
        )
    }.frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
