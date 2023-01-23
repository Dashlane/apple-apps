import SwiftUI
import CorePersonalData
import DashlaneAppKit
import UIComponents
import VaultKit

struct AddCredentialConfirmationView: View {
    
    let item: Credential
    let iconViewModel: VaultItemIconViewModel
    let didFinish: (Credential) -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            LottieView(.passwordAddSuccess,
                       loopMode: .playOnce,
                       contentMode: .scaleAspectFill,
                       animated: true)
                .frame(width: 78, height: 78)
                .padding(.bottom, 45)
            credentialBlock
            Text(L10n.Localizable.addNewPasswordSuccessMessage)
                .font(DashlaneFont.custom(20, .medium).font)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 35)
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationBarButton(L10n.Localizable.kwDoneButton) {
                    didFinish(item)
                }
            }
        }
    }
    
    var credentialBlock: some View {
        VStack(spacing: 5) {
            VaultItemIconView(isListStyle: true, model: iconViewModel)
                .padding(.bottom, 5)
            if !item.displayTitle.isEmpty {
                Text(item.displayTitle)
            }
            if !item.email.isEmpty {
                Text(item.email)
                    .foregroundColor(Color(asset: FiberAsset.grey01))
                    .font(.system(.footnote))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(Color(asset: FiberAsset.appBackground))
        .cornerRadius(8.0)
    }
}



extension AddCredentialConfirmationView: NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = FiberAsset.tachyonBackground.color

        return .custom(appearance: appearance,
                       tintColor: FiberAsset.midGreen.color,
                       statusBarStyle: .default)
    }
}
