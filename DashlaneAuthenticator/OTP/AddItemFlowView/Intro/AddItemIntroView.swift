import SwiftUI
import UIDelight
import DesignSystem
import CoreLocalization

struct AddItemIntroView: View {

    @Environment(\.dismiss)
    private var dismiss

    enum Action {
        case addToken
        case showHelp
    }

        let hasAtLeastOneTokenStoredInVault: Bool
    let completion: (Action) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    title
                        .padding(.trailing)
                    Image(asset: AuthenticatorAsset.addTokenIntro)
                        .padding(.horizontal, 26)
                }.padding(.top, 40)
            }
            Spacer()
            buttons
                .padding(.bottom)
        }
        .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(CoreLocalization.L10n.Core.cancel, action: dismiss.callAsFunction)
                        .foregroundColor(.ds.text.neutral.standard)
                }
        })
        .padding(.horizontal, 24)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .navigationTitle(L10n.Localizable.addOtpFlowSetupLabel)
    }

    var title: some View {
        Text(hasAtLeastOneTokenStoredInVault ? L10n.Localizable.addOtpFlowSetupLabel : L10n.Localizable.addOtpFlowFirstSetupLabel)
            .font(.authenticator(.largeTitle))
            .foregroundColor(.ds.text.neutral.catchy)
    }

    var buttons: some View {
        VStack(spacing: 24) {
            RoundedButton(L10n.Localizable.introButtonTitle) {
                self.completion(.addToken)
            }

            Button(L10n.Localizable.tokenListHelpLabel) {
                self.completion(.showHelp)
            }
            .font(.body.weight(.medium))
            .foregroundColor(.ds.text.brand.standard)
        }
        .roundedButtonLayout(.fill)
    }
}

struct AddItemIntroView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            NavigationView {
                AddItemIntroView(hasAtLeastOneTokenStoredInVault: false, completion: { _ in })
            }
            NavigationView {
                AddItemIntroView(hasAtLeastOneTokenStoredInVault: true, completion: { _ in })
            }
        }
    }
}
