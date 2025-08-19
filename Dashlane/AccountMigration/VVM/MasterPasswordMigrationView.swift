import DesignSystem
import Foundation
import LoginKit
import SwiftUI
import UIComponents

struct MasterPasswordMigrationView: View {
  let title: String
  let subtitle: String
  let migrateButtonTitle: String
  let cancelButtonTitle: String
  let completion: (MigrationDecision) -> Void

  var body: some View {
    ScrollView {
      mainView
    }
    .overlay(overlayButtons)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  var mainView: some View {
    VStack {
      Image(.multidevices)
        .accessibilityHidden(true)

      VStack(spacing: 24) {
        Text(title)
          .font(.title)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .bold()
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)

        Text(subtitle)
          .font(.subheadline)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)

        Infobox(L10n.Localizable.changeMpInfoLabel)

      }.padding(.top, 43)
      Spacer()
    }
    .navigationBarBackButtonHidden(true)
    .padding(.top, 48)
    .padding(.horizontal, 24)
    .loginAppearance()
    .toolbar(.hidden, for: .navigationBar)
  }

  var overlayButtons: some View {
    VStack {
      Spacer()
      VStack(spacing: 8) {
        Button(
          action: {
            completion(.migrate)
          },
          label: {
            Text(migrateButtonTitle)
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity)
          })
        Button(
          action: {
            completion(.cancel)
          },
          label: {
            Text(cancelButtonTitle)
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity)
          }
        )
        .style(mood: .brand, intensity: .quiet)
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
  }
}

struct MasterPasswordMigrationView_Previews: PreviewProvider {
  static var previews: some View {
    MasterPasswordMigrationView(
      title: "Create a Master Password for Dashlane",
      subtitle:
        "Your account rights have changed. Create a strong Master Password to log into Dashlane going forward.",
      migrateButtonTitle: "Create Master Password",
      cancelButtonTitle: "Log out",
      completion: { _ in })
  }
}
