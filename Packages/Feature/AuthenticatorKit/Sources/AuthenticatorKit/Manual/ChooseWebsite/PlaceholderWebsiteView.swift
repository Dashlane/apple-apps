import Foundation
import SwiftUI
import CoreSync
import IconLibrary
import DashTypes

public struct PlaceholderWebsiteView: View {
    let model: PlaceholderWebsiteViewModel

    public var body: some View {
        HStack(spacing: 16) {
            icon
                .fiberAccessibilityHidden(true)
            Text(model.title)
                .font(.body.weight(.medium))
                .foregroundColor(.ds.text.neutral.catchy)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(model.title)
    }

    @ViewBuilder
    var icon: some View {
        DomainIconView(model: model.makeDomainIconViewModel(size: .small),
                       placeholderTitle: model.title)
    }
}

public struct PlaceholderWebsiteViewModel: AuthenticatorServicesInjecting, AuthenticatorMockInjecting {
    let title: String
    let website: String
    let domainIconLibrary: DomainIconLibraryProtocol

    public init(website: String,
                domainIconLibrary: DomainIconLibraryProtocol) {
        self.website = website
        self.title = (website.components(separatedBy: ".").first ?? website).capitalizingFirstLetter()
        self.domainIconLibrary = domainIconLibrary
    }

    public func makeDomainIconViewModel(size: IconStyle.SizeType) -> DomainIconViewModel {
        return DomainIconViewModel(domain: Domain(name: website, publicSuffix: nil),
                                   size: size,
                                   iconLibrary: domainIconLibrary)
    }

}

struct PlaceholderWebsiteView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderWebsiteView(model: .init(website: "facebook.com", domainIconLibrary: FakeDomainIconLibrary(icon: nil)))
        .previewLayout(.sizeThatFits)
    }
}
