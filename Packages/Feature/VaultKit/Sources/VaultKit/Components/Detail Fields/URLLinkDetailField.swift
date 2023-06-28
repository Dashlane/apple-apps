#if os(iOS)
import SwiftUI
import CoreLocalization
import CorePersonalData
import DesignSystem
import UIComponents

public struct URLLinkDetailField: DetailField {
    let personalDataURL: PersonalDataURL

    var canOpen: Bool {
        personalDataURL.openableURL != nil
    }

    var onOpenUrl: (() -> Void)

    public init(personalDataURL: PersonalDataURL, onOpenUrl: @escaping () -> Void) {
        self.personalDataURL = personalDataURL
        self.onOpenUrl = onOpenUrl
    }

    @ViewBuilder
    public var body: some View {
        if canOpen {
            personalDataURL.openableURL.map { url in
                base.action(L10n.Core.kwGoToUrl) {
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
                .foregroundColor(.ds.text.brand.standard))
    }
}

struct URLLinkDetailField_Previews: PreviewProvider {
    static var previews: some View {
        URLLinkDetailField(personalDataURL: PersonalDataURL(rawValue: "_"), onOpenUrl: {})
    }
}
#endif
