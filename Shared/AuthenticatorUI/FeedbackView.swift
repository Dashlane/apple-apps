import SwiftUI
import UIDelight
import DesignSystem
import UIComponents

struct FeedbackView: View {
   
    enum Kind {
        case error
        case message
        case twoFA
        
        var image: Image {
            switch self {
            case .error:
                return Image(asset: SharedAsset.error)
            case .message:
                return Image(asset: SharedAsset.shield)
            case .twoFA:
                return Image(asset: SharedAsset.authenticator)
            }
        }
        
        var color: Color {
            switch self {
            case .error:
                return .ds.text.danger.quiet
            default:
                return .ds.text.brand.quiet
            }
        }
    }
    
    let title: String
    let message: String
    let type: Kind
    let hideBackButton: Bool
    let helpCTA: (title: String, urlToOpen: URL)?
    let primaryButton: (title: String, action: () -> Void)
    let secondaryButton: (title: String, action: () -> Void)?
    
    init(title: String,
         message: String,
         kind: Kind = .error,
         hideBackButton: Bool = true,
         helpCTA: (title: String, urlToOpen: URL)? = nil,
         primaryButton: (title: String, action: () -> Void),
         secondaryButton: (title: String, action: () -> Void)? = nil) {
        self.title = title
        self.message = message
        self.type = kind
        self.hideBackButton = hideBackButton
        self.helpCTA = helpCTA
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
    
    var body: some View {
        ScrollView {
            mainView
                .navigationBarStyle(.alternate)
                .navigationBarBackButtonHidden(hideBackButton)
                .hiddenNavigationTitle()
        }
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .overlay(overlayButton)
        
    }
    
    var mainView: some View {
        VStack(alignment: .leading, spacing: 33) {
            type.image
                .foregroundColor(type.color)
                .padding(.horizontal, 16)
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.custom(GTWalsheimPro.regular.name,
                                  size: 28,
                                  relativeTo: .title)
                        .weight(.medium))
                    .foregroundColor(.ds.text.neutral.catchy)
                Text(message)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.ds.text.neutral.standard)
                    .font(.body)
                if let helpCTA = helpCTA {
                    Link(title: helpCTA.title,
                         url: helpCTA.urlToOpen)
                }
            }
            Spacer()
        }.padding(.all,24)
        .padding(.bottom, 24)

    }
    
    var overlayButton: some View {
        VStack(spacing: 24) {
            Spacer()
            RoundedButton(primaryButton.title, action: primaryButton.action)
                .roundedButtonLayout(.fill)
            if let secondaryButton = secondaryButton {
                Button(secondaryButton.title, action: secondaryButton.action)
                    .font(.body.weight(.medium))
                    .foregroundColor(.ds.text.brand.standard)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            NavigationView {
                FeedbackView(title: "L10n.Localizable.biometryUnlockErrorTitle",
                          message: "L10n.Localizable.biometryUnlockErrorMessage",
                          hideBackButton: true,
                          helpCTA: ("L10n.Localizable.biometryUnlockErrorCta", URL(string: "google.com")!),
                          primaryButton: ("L10n.Localizable.biometryUnlockErrorRetryButtonTitle", {}),
                          secondaryButton: ("L10n.Localizable.biometryUnlockErrorRetryButtonTitle", {}))
            }
        }
    }
}
