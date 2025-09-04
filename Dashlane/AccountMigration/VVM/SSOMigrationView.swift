import CoreLocalization
import CoreTypes
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

enum MigrationDecision {
  case cancel
  case migrate
}

struct SSOMigrationView: View {
  let completion: (MigrationDecision) -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Image.ds.sso.outlined
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 99)
          .foregroundStyle(Color.ds.text.brand.standard)
        Text(L10n.Localizable.ssoMigrationTitle).font(.headline)
        Group {
          Text(L10n.Localizable.ssoMigrationMessage)
          Text(L10n.Localizable.ssoMigrationMessage2)
          Button(
            action: {
              UIApplication.shared.open(DashlaneURLFactory.ssoEnabled)
            },
            label: {
              Text(L10n.Localizable.ssoMigrationAboutTitle)
                .underline()

            })
        }
        .font(.caption)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .lineLimit(nil)

        Infobox(L10n.Localizable.ssoMigrationNote)
      }
      .padding(.horizontal, 24)
    }
    .scrollBounceBehavior(.basedOnSize)
    .safeAreaInset(edge: .bottom) {
      Button(L10n.Localizable.activateSSOButtonTitle) {
        completion(.migrate)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 24)
      .padding(.bottom, 10)
    }
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(CoreL10n.cancel) { self.completion(.cancel) }
      }
    }
  }
}

#Preview {
  NavigationStack {
    SSOMigrationView { _ in }
  }
}
