import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

public struct AddCredentialConfirmationView: View {
  let item: Credential
  let didFinish: (Credential) -> Void

  public var body: some View {
    VStack(spacing: 25) {
      LottieView(
        .passwordAddSuccess,
        loopMode: .playOnce,
        contentMode: .scaleAspectFill,
        animated: true
      )
      .frame(width: 78, height: 78)
      .padding(.bottom, 45)
      Text(L10n.Core.addNewPasswordSuccessMessage)
        .font(DashlaneFont.custom(20, .medium).font)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 35)
    .frame(maxWidth: .infinity)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationBarButton(L10n.Core.kwDoneButton) {
          didFinish(item)
        }
      }
    }
    .reportPageAppearance(.autofillExplorePasswordsCreateConfirmation)
  }
}

struct AddCredentialConfirmationView_Previews: PreviewProvider {
  static var credential: Credential = Credential()

  static var previews: some View {
    AddCredentialConfirmationView(item: credential, didFinish: { _ in })
  }
}
