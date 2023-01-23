import Foundation
import SwiftUI

struct Dashlane2FAMessageView: View {
    
    let completion: () -> Void
    
    @State
    var showSuccess = false
    
    var body: some View {
        ZStack {
            FeedbackView(title: L10n.Localizable.dashlaneTokenAddTitle,
                         message: L10n.Localizable.dashlaneTokenAddMessage1 + "\n" + L10n.Localizable.dashlaneTokenAddMessage2,
                         kind: .message,
                         helpCTA: (L10n.Localizable.dashlaneTokenAddHelpCta, UserSupportURL.protectAccountUsing2FA.url),
                         primaryButton: (L10n.Localizable.dashlaneTokenAddCta, {
                showSuccess = true
            }))
            
            if showSuccess {
                SuccessView(completion: completion)
            }
        }
        .animation(.easeInOut, value: showSuccess)
    }
}
