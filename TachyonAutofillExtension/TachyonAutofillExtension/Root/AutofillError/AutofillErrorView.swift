import SwiftUI
import DesignSystem
import UIComponents
import CoreLocalization

protocol AutofillURLOpener {
    func openUrl(_ url: URL)
}

struct AutofillErrorView: View {
    let error: AutofillError
    let cancelAction: () -> Void
    let urlOpener: AutofillURLOpener

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Image(asset: FiberAsset.logomark)
                    .fiberAccessibilityHidden(true)
                VStack(spacing: 20) {
                    Text(L10n.Localizable.tachyonLoginRequiredScreenTitle)
                        .foregroundColor(.ds.text.neutral.catchy)
                        .multilineTextAlignment(.center)
                        .font(DashlaneFont.custom(26, .bold).font)
                        .accessibilitySortPriority(2)

                    Text(error.title)
                        .foregroundColor(.ds.text.neutral.standard)
                        .multilineTextAlignment(.center)
                }
                .accessibilityElement(children: .contain)

                Button {
                    handleAction()
                } label: {
                    Text(error.actionTitle)
                        .foregroundColor(.ds.text.brand.standard)
                }
            }
            .padding(.horizontal, 24)
            .frame(maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                Text("Code: \(error.code)")
                    .font(.footnote)
                    .foregroundColor(.ds.text.neutral.quiet)
            }
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        cancelAction()
                    } label: {
                        Text(CoreLocalization.L10n.Core.cancel)
                            .foregroundColor(.ds.text.brand.standard)
                    }
                }
            }
        }
    }

    private func handleAction() {
        switch error {
            case .noUserConnected: goToMainApp()
            case .ssoUserWithNoConvenientLoginMethod: goToSecuritySettings()
        }
    }

    private func goToMainApp() {
        urlOpener.openUrl(URL(string: "dashlane:///")!)
    }

    private func goToSecuritySettings() {
        urlOpener.openUrl(URL(string: "dashlane:///settings/security")!)
    }
}

struct AutofillErrorView_Previews: PreviewProvider {
    private struct FakeAutofillURLOpener: AutofillURLOpener {
        func openUrl(_ url: URL) {}
    }

    static var fakeURLOpener: AutofillURLOpener {
        FakeAutofillURLOpener()
    }

    static var previews: some View {
        AutofillErrorView(error: .ssoUserWithNoConvenientLoginMethod,
                          cancelAction: {},
                          urlOpener: fakeURLOpener)
    }
}
