import Foundation
import SwiftUI
import DashTypes
import CoreLocalization
import DesignSystem

public struct SSOUnlockView: View {

    let login: Login
    let completion: @MainActor () -> Void

    public init(login: Login, completion: @escaping @MainActor () -> Void) {
        self.login = login
        self.completion = completion
    }

    public var body: some View {
        VStack {
            LoginLogo(login: login)
            Spacer()
                .frame(maxHeight: .infinity)
            RoundedButton(L10n.Core.unlockWithSSOTitle, action: completion)
                .roundedButtonLayout(.fill)
                .padding()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SSOUnlockView_Previews: PreviewProvider {
    static var previews: some View {
        SSOUnlockView(login: Login("_")) {}
    }
}
