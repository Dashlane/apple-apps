import CoreSession
import CoreTypes
import DesignSystem
import SwiftUI
import UIDelight

public struct LoginLogo: View {
  private let login: Login?

  public init(login: Login? = nil) {
    self.login = login
  }

  public var body: some View {
    Group {
      VStack(spacing: 17.0) {
        Image(.logomark)
          .foregroundStyle(Color.ds.oddity.brand)
          .fiberAccessibilityHidden(true)

        login.map { login in
          Text(login.email)
            .fontWeight(.light)
            .allowsTightening(true)
            .font(.body)
            .padding(.horizontal)
            .foregroundStyle(Color.ds.text.neutral.standard)
        }
      }
      .frame(maxHeight: .infinity, alignment: .center)
    }
  }
}

#Preview {
  VStack {
    LoginLogo(login: Login("_"))
    Divider()
    LoginLogo(login: Login("_"))
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  .background(.ds.background.default)
}
