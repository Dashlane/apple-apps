import Foundation
import UIDelight
import UIComponents
import SwiftUI
import DesignSystem

struct AuthenticatorToolIntroView: View {

    let completion: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            LottieView(.authenticator2faDemoAnimation)
                .frame(height: 183)
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.Localizable.authenticatorToolOnboardingSheetTitle)
                    .font(.custom(GTWalsheimPro.medium.name, size: 26, relativeTo: .title))
                Text(L10n.Localizable.authenticatorToolOnboardingSheetDescription).foregroundColor(.ds.text.neutral.quiet)
                    .font(.body)
            }
            .fixedSize(horizontal: false, vertical: true)
            .minimumScaleFactor(0.01)
            RoundedButton(L10n.Localizable.onboardingChecklistTitle, action: completion)
                .roundedButtonLayout(.fill)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 32)
        .backgroundColorIgnoringSafeArea(.ds.background.default)

    }
}

struct AuthenticatorToolIntroView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AuthenticatorToolIntroView(completion: {}).previewLayout(.sizeThatFits)
        }
    }
}
