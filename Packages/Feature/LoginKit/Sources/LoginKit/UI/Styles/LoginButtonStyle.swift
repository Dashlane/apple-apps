import DesignSystem
import SwiftUI

extension ButtonStyle where Self == LoginButtonStyle {
  public static var login: Self {
    .init()
  }
}

public struct LoginButtonStyle: ButtonStyle {
  public func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .frame(minWidth: 0, maxWidth: .infinity)
      .frame(height: 50)
      .aspectRatio(9, contentMode: .fit)
      .foregroundColor(.ds.text.inverse.catchy.opacity(configuration.isPressed ? 0.7 : 1))
      .background(
        .ds.container.expressive.brand.catchy.idle.opacity(configuration.isPressed ? 0.7 : 1)
      )
      .cornerRadius(10)
  }
}
