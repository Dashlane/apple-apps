import Foundation
import SwiftUI
import DesignSystem

struct PrivacyLock: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(asset: AuthenticatorAsset.authLogomark)
                .padding(.top, 40)
                .foregroundColor(.ds.text.brand.quiet)
            Spacer()
            Image(asset: AuthenticatorAsset.logoLockUp)
                .foregroundColor(.ds.text.brand.quiet)
                .padding(.bottom, 20)
        }
        .padding(24)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }
}

struct PrivacyLockScreen_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyLock()
    }
}
