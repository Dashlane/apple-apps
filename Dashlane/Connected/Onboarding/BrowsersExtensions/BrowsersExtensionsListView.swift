import SwiftUI
import UIDelight
import UIComponents

struct BrowsersExtensionsListView: View {

    let availableBrowsers: [MacBrowser]

    let back: () -> Void
    let skip: () -> Void
    let getExtension: (MacBrowser) -> Void
    let isExtensionInstalled: (MacBrowser) -> Bool
    let openExtension: (MacBrowser) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Image(asset: FiberAsset.logomark)
                .foregroundColor(Color(asset: FiberAsset.dashGreen))
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Localizable.extensionsOnboardingAllBrowsersTitle)
                    .font(DashlaneFont.custom(26, .bold).font)
                Text(L10n.Localizable.extensionsOnboardingAllBrowsersDescription)
                    .foregroundColor(Color(asset: FiberAsset.dwmDashGreen01))
                    .font(.title3)
            }
            browsersList
        }
        .padding(.horizontal, 100)
        .frame(maxWidth: 720)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(action: back)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(action: skip, title: L10n.Localizable.extensionsOnboardingSkipCta)
            }
        }
    }

    var browsersList: some View {
        VStack(spacing: 0) {
            ForEach(availableBrowsers, id: \.self) { browser in
                browserRow(for: browser)
                    .frame(height: 80)
                Divider()
            }
        }
    }

    func browserRow(for browser: MacBrowser) -> some View {
        HStack(spacing: 32) {
            browser.logo.swiftUIImage
                .frame(width: 48, height: 48)
            Text(L10n.Localizable.extensionsOnboardingDashlaneOn(browser.title))
                .font(DashlaneFont.custom(24, .bold).font)
            Spacer()
            browserRowButton(for: browser)
                .font(.callout.weight(.semibold))
                .foregroundColor(Color(asset: FiberAsset.guidedOnboardingSecondaryAction))
        }
    }

    @ViewBuilder
    func browserRowButton(for browser: MacBrowser) -> some View {
        if isExtensionInstalled(browser) {
        Button(action: { openExtension(browser) },
               title: L10n.Localizable.extensionsOnboardingOtherBrowserOpenExtensionCta)
        } else {
            Button(action: { getExtension(browser) },
                   title: browser.getExtensionTitle)
        }
    }
}

private extension MacBrowser {
    var getExtensionTitle: String {
        switch self {
        case .safari:
            return L10n.Localizable.extensionsOnboardingSafariEnableExtensionCta
        default:
            return L10n.Localizable.extensionsOnboardingOtherBrowserGetExtensionCta
        }
    }

    var logo: ImageAsset {
        switch self {
        case .safari, .safariTechPreview:
            return FiberAsset.browserSafariLogo
        case .chrome:
            return FiberAsset.browserChromeLogo
        case .firefox:
            return FiberAsset.browserFirefoxLogo
        case .edge:
            return FiberAsset.browserEdgeLogo
        }
    }
}

struct BrowsersExtensionsListView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPadPro])) {
            BrowsersExtensionsListView(availableBrowsers: [.chrome, .edge, .firefox, .safari], back: {}, skip: {}, getExtension: { _ in }, isExtensionInstalled: { _ in false }, openExtension: { _ in })
        }
    }
}
