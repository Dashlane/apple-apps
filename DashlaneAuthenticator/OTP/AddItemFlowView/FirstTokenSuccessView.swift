import DesignSystem
import SwiftUI

struct FirstTokenSuccessView: View {

  let tokenTitle: String
  let completion: () -> Void

  @State
  var showTokenHelp = false

  var body: some View {
    ZStack {
      VStack {
        Spacer()
        Image.ds.feedback.success.outlined
          .resizable()
          .frame(width: 60, height: 60)
          .foregroundColor(.ds.text.brand.quiet)
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .overlay(overLayButton)
      if showTokenHelp {
        TokenHelpView(
          title: L10n.Localizable.firstTokenAddHelpTitle(tokenTitle),
          message: L10n.Localizable.firstTokenAddHelpMessage(tokenTitle),
          cta: L10n.Localizable.firstTokenAddViewTokenCta,
          completion: completion)
      }
    }.animation(.easeInOut, value: showTokenHelp)
      .navigationBarBackButtonHidden(true)
  }

  var overLayButton: some View {
    VStack(spacing: 24) {
      Spacer()
      Button(L10n.Localizable.firstTokenAddViewTokenCta, action: completion)
        .buttonStyle(.designSystem(.titleOnly))
      Button(L10n.Localizable.firstTokenAddHelpCta, action: { showTokenHelp = true })
        .font(.body.weight(.medium))
        .foregroundColor(.ds.text.brand.standard)
    }
    .padding(24)
  }
}

struct FirstTokenSuccessView_Previews: PreviewProvider {
  static var previews: some View {
    FirstTokenSuccessView(tokenTitle: "Facebook") {}
  }
}
