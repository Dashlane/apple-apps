import SwiftUI
import UIDelight
import UIComponents
import DesignSystem

struct AddTokenMethodSelectionView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State var showSupportPage = false

    enum Action {
        case scanCode
        case enterCodeManually
    }
    
    let completion: (Action) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    title
                        .padding(.trailing)
                    Image(asset: AuthenticatorAsset.addTokenMethod)
                }.padding(.top, 40)
            }
            Spacer()
            buttons
                .padding(.bottom)
        }
        .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.Localizable.addOtpFlowHelpCta) {
                        self.showSupportPage = true
                    }
                    .foregroundColor(.ds.text.neutral.standard)
                }
        })
        .padding(.horizontal, 24)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
        .hiddenNavigationTitle()
        .navigationTitle(L10n.Localizable.addOtpFlowSetupLabel)
        .safariSheet(isPresented: $showSupportPage, .dashlaneTwoStepsVerification)
    }
    var title: some View {
        Text(L10n.Localizable.setupHelpAddTokenCta)
            .font(.authenticator(.largeTitle))
            .foregroundColor(.ds.text.neutral.catchy)
    }
    
    var buttons: some View {
        VStack(spacing: 24) {
            RoundedButton(L10n.Localizable.addOtpFlowScanCodeCta) {
                self.completion(.scanCode)
            }.roundedButtonLayout(.fill)
            
            Button(L10n.Localizable.addOtpFlowEnterManualCta) {
                self.completion(.enterCodeManually)
            }
            .font(.body.weight(.medium))
            .foregroundColor(.ds.text.brand.standard)
        }
    }
}

struct AddTokenMethodSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            NavigationView {
                AddTokenMethodSelectionView(){ _ in }
            }
            NavigationView {
                AddTokenMethodSelectionView(){ _ in }
            }
        }
    }
}
