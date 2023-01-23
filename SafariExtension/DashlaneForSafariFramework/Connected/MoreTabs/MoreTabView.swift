import SwiftUI

struct MoreTabView: View {
    
    var viewModel: MoreTabViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            
            VStack(spacing: 8) {
                otherButton(image: Image(asset: Asset.computerLogo), text: L10n.Localizable.safariOtherOpenApp, action: {
                    viewModel.openMainApp()
                })

                otherButton(image: Image(asset: Asset.helpLogo), text: L10n.Localizable.safariOtherOpenSupport, action: {
                    viewModel.askForSupport()
                })
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            
            Spacer()
            
            Divider()
    
            HStack(spacing: 2) {
                Text(L10n.Localizable.safariOtherLoggedInAs)
                    .font(Typography.caption2)
                
                Text(viewModel.login)
                    .font(Typography.caption)
                
                Spacer()
            }
            .frame(alignment: .bottom)
            .padding(.top, 12)
            .padding(.leading, 12)
            
        }
        .padding(.vertical, 20)

    }

    func otherButton(image: SwiftUI.Image, text: String, action: @escaping () -> ()) -> some View {
        return Button(action: action, label : {
            HStack(spacing: 12) {
                image
                Text(text)
                    .font(Typography.smallHeader)
                Spacer()
            }
        })
        .buttonStyle(DashlaneDefaultButtonStyle(backgroundColor: Color(asset: Asset.otherTabsButton),
                                                borderColor: Color(asset: Asset.separation),
                                                foregroundColor: Color(asset: Asset.primaryHighlight),
                                                shouldTakeAllWidth: false))
        .frame(height: 60)
    }
    
}

struct MoreTabView_Previews: PreviewProvider {
    static var previews: some View {
        MoreTabView(viewModel: MoreTabViewModel.mock)
    }
}
