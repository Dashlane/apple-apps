import Foundation
import SwiftUI

struct PrivacyLock: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(asset: AuthenticatorAsset.authLogomark)
                .padding(.top, 40)
                .foregroundColor(Color(asset: AuthenticatorAsset.oddityBrand))
            Spacer()
            Image(asset: AuthenticatorAsset.logoLockUp)
                .foregroundColor(Color(asset: AuthenticatorAsset.oddityBrand))
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
