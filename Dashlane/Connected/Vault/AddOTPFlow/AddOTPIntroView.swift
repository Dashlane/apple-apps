import Combine
import CoreLocalization
import CorePersonalData
import CoreUserTracking
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct AddOTPIntroView: View {

  let credential: Credential?
  let completion: (Action) -> Void

  enum Action {
    case scanQRCode
    case enterToken(Credential?)
    case cancel
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Image.ds.healthPositive.outlined
        .resizable()
        .foregroundColor(.ds.text.brand.standard)
        .aspectRatio(contentMode: .fit)
        .frame(width: 80)
        .fiberAccessibilityHidden(true)

      Text(title)
        .font(.custom(GTWalsheimPro.medium.name, size: 26, relativeTo: .title).weight(.medium))
        .accessibilityAddTraits(.isHeader)
      Text(L10n.Localizable._2faSetupIntroSubtitle).font(.body)
        .minimumScaleFactor(0.6)
        .foregroundColor(.ds.text.neutral.standard)
      explanation.fixedSize(horizontal: false, vertical: true)
        .foregroundColor(.ds.text.neutral.standard)
      learnMore
      Spacer()
      actions
    }
    .padding(24)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        NavigationBarButton(CoreLocalization.L10n.Core.cancel) {
          completion(.cancel)
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .reportPageAppearance(.toolsAuthenticatorSetup)
  }

  private var title: String {
    guard let credentialTitle = credential?.displayTitle else {
      return CoreLocalization.L10n.Core._2faSetupCta
    }
    return L10n.Localizable._2faSetupIntroTitle(credentialTitle)
  }

  private var actions: some View {
    VStack(alignment: .leading, spacing: 16) {
      if !Device.isMac {
        Button(L10n.Localizable._2faSetupIntroScanQRCode) {
          completion(.scanQRCode)
        }
        .buttonStyle(.designSystem(.titleOnly))
      }
      Button(
        action: {
          completion(.enterToken(credential))
        }, title: L10n.Localizable._2faSetupIntroSetupWithCode
      ).buttonStyle(BorderlessActionButtonStyle())

    }
  }

  private var explanation: some View {
    struct Line: Hashable {
      let prefix: String
      let content: String

      init(_ prefix: String, _ content: String) {
        self.prefix = prefix
        self.content = content
      }
    }

    let lines = [
      L10n.Localizable._2faSetupIntroHelpStep1,
      L10n.Localizable._2faSetupIntroHelpStep2,
      L10n.Localizable._2faSetupIntroHelpStep3,
    ]

    return VStack(alignment: .leading, spacing: 4) {
      ForEach(lines, id: \.self) { line in
        HStack(alignment: .top) {
          Text("• ").font(Font.body.monospacedDigit())
          Text(line).font(.body)
        }
      }
    }
  }

  private var learnMore: some View {
    Button {
      UIApplication.shared.open(URL(string: "_")!, options: [:])
    } label: {
      Text(L10n.Localizable._2faSetupIntroLearnMore)
        .foregroundColor(.ds.text.brand.quiet)
        .multilineTextAlignment(.leading)
    }
    .accessibilityAddTraits(.isLink)
    .accessibilityRemoveTraits(.isButton)
  }

}
struct AddOTPIntroView_Previews: PreviewProvider {

  static var previews: some View {
    NavigationView {
      AddOTPIntroView(credential: PersonalDataMock.Credentials.amazon, completion: { _ in })
    }
    .navigationTitle(Text("Heeey").foregroundColor(.black))
    .previewDevice("iPhone SE (2nd generation)")
    .navigationBarTitleDisplayMode(.inline)
  }
}
