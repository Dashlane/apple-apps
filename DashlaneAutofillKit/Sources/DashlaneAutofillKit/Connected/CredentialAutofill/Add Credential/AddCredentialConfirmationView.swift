import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import SwiftUILottie
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
      Text(CoreL10n.addNewPasswordSuccessMessage)
        .textStyle(.specialty.spotlight.small)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 35)
    .frame(maxWidth: .infinity)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(CoreL10n.kwDoneButton) {
          didFinish(item)
        }
      }
    }
    .reportPageAppearance(.autofillExplorePasswordsCreateConfirmation)
  }
}

#Preview {
  AddCredentialConfirmationView(item: PersonalDataMock.Credentials.netflix, didFinish: { _ in })
}
