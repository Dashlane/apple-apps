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
  let completion: (MigrationCompletionType) -> Void

  var body: some View {
    ScrollView {
      mainView
    }
    .overlay(overlayButtons)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  var mainView: some View {
    VStack {
      Image(asset: FiberAsset.multidevices)
        .accessibilityHidden(true)

      VStack(spacing: 24) {
        Text(title)
          .font(.title)
          .bold()
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)

        Text(subtitle)
          .font(.subheadline)
          .foregroundColor(.ds.text.neutral.quiet)
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
          })
        Button(
          action: {
            completion(.cancel)
          },
          label: {
            Text(cancelButtonTitle)
              .fixedSize(horizontal: false, vertical: true)
          }
        )
        .style(mood: .brand, intensity: .quiet)
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(24)
  }
}

extension MasterPasswordMigrationView: NavigationBarStyleProvider {
  var navigationBarStyle: NavigationBarStyle {
    return .hidden()
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
