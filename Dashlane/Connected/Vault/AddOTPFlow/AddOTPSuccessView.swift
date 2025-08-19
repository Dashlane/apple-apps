import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI
import TOTPGenerator
import UIComponents
import VaultKit

struct AddOTPSuccessView: View {

  enum Mode {
    case credentialPrefilled(Credential)
    case promptToEnterCredential(configuration: OTPConfiguration)
  }
  let mode: Mode
  let action: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      Spacer()
      DS.ExpressiveIcon(.ds.feedback.success.outlined)
        .style(mood: .brand, intensity: .quiet)
        .controlSize(.extraLarge)

      Text(L10n.Localizable._2faSetupSuccessTitle(domainName)).textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)

      Text(description)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)

      Spacer()

      Button(buttonTitle, action: action)
        .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 24)
    .navigationBarHidden(true)
    .frame(maxWidth: .infinity, maxHeight: .infinity)

  }

  private var domainName: String {
    switch mode {
    case let .credentialPrefilled(credential):
      return credential.displayTitle
    case let .promptToEnterCredential(configuration):
      return configuration.issuerOrTitle
    }
  }

  private var buttonTitle: String {
    switch mode {
    case .credentialPrefilled:
      return L10n.Localizable.modalOkGotIt
    case .promptToEnterCredential:
      return L10n.Localizable.otptoolAddLoginCta
    }
  }

  var description: String {
    return L10n.Localizable._2fasetupSuccessSubtitle
  }
}

struct AddOTPSuccessView_Previews: PreviewProvider {

  static var previews: some View {
    Group {
      AddOTPSuccessView(
        mode: .credentialPrefilled(PersonalDataMock.Credentials.wikipedia), action: {})
      AddOTPSuccessView(mode: .promptToEnterCredential(configuration: .mock), action: {})
        .preferredColorScheme(.dark)
    }
  }

}
