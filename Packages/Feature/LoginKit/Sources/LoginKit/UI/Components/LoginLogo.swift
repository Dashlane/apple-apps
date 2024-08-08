import CoreSession
import DashTypes
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
        Image(asset: Asset.logomark)
          .foregroundColor(.ds.oddity.brand)
          .fiberAccessibilityHidden(true)

        login.map { login in
          Text(login.email)
            .fontWeight(.light)
            .allowsTightening(true)
            .font(.body)
            .padding(.horizontal)
        }
      }
      .frame(maxHeight: .infinity, alignment: .center)
    }
  }
}

struct Logo_Previews: PreviewProvider {

  static var previews: some View {
    MultiContextPreview {
      VStack {
        LoginLogo(login: Login("_"))
        Divider()
        LoginLogo(login: Login("_"))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.ds.background.default)
    }
  }
}
