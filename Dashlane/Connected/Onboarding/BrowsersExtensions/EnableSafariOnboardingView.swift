import SwiftUI
import UIDelight
import UIComponents
import DesignSystem

struct EnableSafariOnboardingView: View {

    let isLegacyApplicationInstalled: Bool
    let openSafari: () -> Void
    let otherBrowsers: () -> Void
    let skip: () -> Void

    var body: some View {
        VStack(spacing: 48) {
            MacBrowser.safari.artwork(isLegacyInstalled: isLegacyApplicationInstalled).swiftUIImage
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

    @ViewBuilder
    var explanations: some View {
        VStack(spacing: 16) {
            Text(L10n.Localizable.extensionsOnboardingSafariTitle)
                .font(DashlaneFont.custom(26, .medium).font)
            HStack(alignment: .center) {
                tutorial
            }.frame(maxWidth: .infinity)

        }
    }

    @ViewBuilder
    var tutorial: some View {
        LazyVGrid(columns: [GridItem(.fixed(24), alignment: .top),
                            GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 200, alignment: .leading)],
                  alignment: .center,
                  spacing: 2) {
            explanationRow(image: FiberAsset.safariLogo,
                           text: L10n.Localizable.extensionsOnboardingSafariOpenSafariExample)
            separatorRow()
            explanationRow(image: FiberAsset.safariExtensions,
                           text: L10n.Localizable.extensionsOnboardingSafariNavigateExample)
            separatorRow()
            explanationRow(image: FiberAsset.safariDashlaneSmall,
                           text: L10n.Localizable.extensionsOnboardingSafariEnable)
            if isLegacyApplicationInstalled {
                separatorRow()
                explanationRow(image: FiberAsset.safariDashlaneLegacy,
                               text: L10n.Localizable.extensionsOnboardingSafariDisableLegacy("Dashlane Legacy"))
            }
        }
        .frame(width: 320)
    }

    @ViewBuilder
    private func explanationRow(image: ImageAsset,
                                text: String) -> some View {
        image.swiftUIImage
            .frame(width: 24, height: 24)
            .foregroundColor(Color.red)
        MarkdownText(text)
            .foregroundColor(Color(asset: FiberAsset.settingsSecondaryHighlight))
    }

    @ViewBuilder
    private func separatorRow() -> some View {
        ZStack {
            Rectangle()
                .frame(width: 1, height: 14)
        }.frame(width: 24)
        Color.clear
    }

    var buttons: some View {
        HStack {
            Spacer()
            VStack(spacing: 30) {
                RoundedButton(L10n.Localizable.extensionsOnboardingSafariOpenSafariCta, action: openSafari)
                    .roundedButtonLayout(.fill)
                Button(action: otherBrowsers, title: L10n.Localizable.extensionsOnboardingOtherBrowserOthersCta)
                    .foregroundColor(Color(asset: FiberAsset.guidedOnboardingSecondaryAction))
                    .font(.headline)
            }.frame(width: 320)
            Spacer()
        }
    }

}

 struct EnableSafariOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPadPro])) {
            EnableSafariOnboardingView(isLegacyApplicationInstalled: false, openSafari: {}, otherBrowsers: {}, skip: {})
            EnableSafariOnboardingView(isLegacyApplicationInstalled: true, openSafari: {}, otherBrowsers: {}, skip: {})
        }
    }
 }
