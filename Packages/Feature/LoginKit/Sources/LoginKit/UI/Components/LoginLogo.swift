import SwiftUI
import CoreSession
import UIDelight
import DashTypes
import DesignSystem

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

                login.map { login in
                    Text(login.email)
                        .fontWeight(.light)
                        .allowsTightening(true)
                        .font(.body)
                        .lineLimit(1)
                        .padding(.horizontal)
                }
            }.frame(maxHeight: .infinity)
                .frame(alignment: .center)
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
