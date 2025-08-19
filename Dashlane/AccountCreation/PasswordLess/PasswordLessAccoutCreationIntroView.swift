import CoreLocalization
import DesignSystem
import LoginKit
import SwiftUI

struct PasswordLessAccountCreationIntroView: View {
  let l10n = L10n.Localizable.PasswordlessAccountCreation.Intro.self
  let completion: () -> Void

  @State
  var isLearnMoreDisplayed: Bool = false

  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading) {
          Text(l10n.title)
            .textStyle(.specialty.brand.small)
          InstructionsCardView(cardContent: [
            l10n.message1,
            l10n.message2,
            l10n.message3,
          ])
          Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 51)
      }
      actions
    }
    .loginAppearance()
    .navigationTitle(L10n.Localizable.kwTitle)
    .safariSheet(isPresented: $isLearnMoreDisplayed, url: URL(string: "_")!)
  }

  var actions: some View {
    VStack(spacing: 8) {
      Button(l10n.getStartedButton) {
        completion()
      }
      .style(mood: .brand, intensity: .catchy)
      Button(l10n.learnMoreButton) {
        isLearnMoreDisplayed = true
      }
      .style(mood: .brand, intensity: .quiet)
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(24)
  }
}

struct PasswordLessAccoutCreationIntroView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordLessAccountCreationIntroView {

    }
  }
}
