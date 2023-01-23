import SwiftUI
import CorePersonalData

struct URLLinkDetailField: DetailField {
    let personalDataURL: PersonalDataURL

    var canOpen: Bool {
        personalDataURL.openableURL != nil
    }

    var onOpenUrl: (() -> Void)

    @ViewBuilder
    var body: some View {
        if canOpen {
            personalDataURL.openableURL.map { url in
                base.action(L10n.Localizable.kwGoToUrl) {
                    self.onOpenUrl()
                    #if !EXTENSION
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    #endif
                }
            }
        } else {
            base
        }
    }

    @ViewBuilder
    var base: some View {
        (Text(personalDataURL.displayedScheme) +
            Text(personalDataURL.displayDomain)
                .foregroundColor(Color(asset: FiberAsset.accentColor)))
    }
}

struct URLLinkDetailField_Previews: PreviewProvider {
    static var previews: some View {
        URLLinkDetailField(personalDataURL: PersonalDataURL(rawValue: "_"), onOpenUrl: {})
    }
}
