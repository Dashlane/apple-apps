import SwiftUI
import LoginKit

struct LoginView: View {
    
    @ObservedObject
    var viewModel: LoginViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            enableReactivationWebcards
            HStack {
                Asset
                    .logomark
                    .swiftUIImage
                    .foregroundColor(Color(asset: Asset.dashGreenCopy))
                    .frame(alignment: .leading)
                    .padding(.leading, 32)
                    .fiberAccessibilityHidden(true)
                Spacer()
            }
            .frame(alignment: .top)
            .padding(.top, 52)
            
            Spacer()
            
            Text(L10n.Localizable.safariPreLoginText)
                .font(Typography.largeHeader)
                .lineSpacing(10)
                .foregroundColor(Color(asset: Asset.dashGreenCopy))
                .padding(.bottom, 20)
                .padding([.leading,.trailing], 24)
            
            Spacer()
                .frame(alignment: .center)

            if let error = viewModel.loginError {
                Text(error)
                    .font(.footnote)
            }
            
            HStack {
                Spacer()
                
                Button(L10n.Localizable.safariPreLoginButtonText, action: {
                    viewModel.openMainApplication()
                })
                .buttonStyle(.login)
                .font(.system(size: 16))
                .padding([.leading,.trailing], 24)
                
                Spacer()
            }
            .frame(alignment: .bottom)
            .padding(.bottom, 32)
        }
        .onAppear {
            viewModel.appeared()
        }
    }
    
    @ViewBuilder
    private var enableReactivationWebcards: some View {
        if viewModel.shouldShowReactivationWebcardEnabler {
            Button("Enable reactivation webcards") {
                viewModel.enableReactivationWebcard()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverPreviewScheme(size: .popover) {
            LoginView(viewModel: LoginViewModel.mock)
        }
    }
}
