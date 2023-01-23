import SwiftUI
import UIDelight
import UIComponents
import DesignSystem

struct EnableOtherBrowserOnboardingView: View {

    let browser: MacBrowser
    let isExtensionInstalled: Bool
    let getExtension: () -> Void
    let openExtension: () -> Void
    let otherBrowsers: () -> Void
    let skip: () -> Void

    var body: some View {
        VStack(spacing: 48) {
            browser.artwork().swiftUIImage
                .frame(width: 480, height: 280)
            explanations
            buttons
        }
        .frame(width: 480)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(action: skip, title: L10n.Localizable.extensionsOnboardingSkipCta)
            }
        }
    }

    var explanations: some View {
        VStack(spacing: 8) {
            Text(L10n.Localizable.extensionsOnboardingOtherBrowserTitle(browser.title))
                .font(DashlaneFont.custom(26, .medium).font)
            Text(L10n.Localizable.extensionsOnboardingOtherBrowserDescription(browser.title))
                .font(.title3)
        }.multilineTextAlignment(.center)
    }

    var buttons: some View {
        HStack {
            Spacer()
            VStack(spacing: 30) {
                RoundedButton(isExtensionInstalled ? L10n.Localizable.extensionsOnboardingOtherBrowserOpenExtensionCta : L10n.Localizable.extensionsOnboardingOtherBrowserGetExtensionCta,
                              action: {
                    if isExtensionInstalled {
                        openExtension()
                    } else {
                        getExtension()
                    }
                })
                .roundedButtonLayout(.fill)
                Button(action: otherBrowsers, title: L10n.Localizable.extensionsOnboardingOtherBrowserOthersCta)
                    .foregroundColor(Color(asset: FiberAsset.guidedOnboardingSecondaryAction))
                    .font(.headline)
            }.frame(width: 320)
            Spacer()
        }
    }
}

private extension EnableOtherBrowserOnboardingView {
    init(browser: MacBrowser,
         isExtensionInstalled: Bool) {
        self.init(browser: browser, isExtensionInstalled: isExtensionInstalled, getExtension: {}, openExtension: {}, otherBrowsers: {}, skip: {})
    }
}

struct EnableOtherBrowserOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPadPro])) {
            EnableOtherBrowserOnboardingView(browser: .chrome, isExtensionInstalled: false)
            EnableOtherBrowserOnboardingView(browser: .edge, isExtensionInstalled: false)
            EnableOtherBrowserOnboardingView(browser: .firefox, isExtensionInstalled: true)
        }
    }
}
