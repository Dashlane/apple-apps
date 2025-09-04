import CoreLocalization
import CoreSession
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

struct AccountRecoveryActivationIntroView: View {

  enum Completion {
    case generateKey
    case cancel
  }

  let authenticationMethod: AuthenticationMethod
  let canSkip: Bool
  let completion: (Completion) -> Void

  @State
  var showSkipAlert = false

  var body: some View {
    ScrollView {
      mainView
        .navigationBarBackButtonHidden(true)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            if !canSkip {
              Button(CoreL10n.cancel) {
                completion(.cancel)
              }
            }
          }
        }
    }
    .scrollContentBackgroundStyle(.alternate)
    .overlay(overlayButton)
    .alert(
      L10n.Localizable.mplessRecoverySkipAlertTitle,
      isPresented: $showSkipAlert,
      actions: {
        Button(L10n.Localizable.mplessRecoverySkipAlertCta) {
          completion(.cancel)
        }
        Button(CoreL10n.cancel) {}
      },
      message: {
        Text(L10n.Localizable.mplessRecoverySkipAlertMessage)
      }
    )
    .navigationTitle(CoreL10n.recoveryKeySettingsLabel)
    .loginAppearance()
  }

  var mainView: some View {
    VStack(alignment: .leading, spacing: 33) {
      DS.ExpressiveIcon(.ds.recoveryKey.outlined)
        .style(mood: .brand, intensity: .quiet)
        .controlSize(.extraLarge)
      VStack(alignment: .leading, spacing: 16) {
        Text(L10n.Localizable.recoveryKeyActivationIntroTitle)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .textStyle(.title.section.large)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        Text(authenticationMethod.message)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .textStyle(.body.standard.regular)
      }
      Spacer()
    }
    .padding(.all, 24)
    .padding(.bottom, 24)
  }

  var overlayButton: some View {
    VStack(spacing: 8) {
      Spacer()
      Button(
        action: {
          completion(.generateKey)
        },
        label: {
          Text(L10n.Localizable.recoveryKeyActivationIntroCta)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
        })
      if canSkip {
        Button(
          action: {
            showSkipAlert = true
          },
          label: {
            Text(L10n.Localizable.mplessRecoverySkipCta)
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity)
          }
        )
        .style(mood: .brand, intensity: .quiet)
      }
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
  }
}

extension AuthenticationMethod {
  fileprivate var message: String {
    switch self {
    case .masterPassword:
      return L10n.Localizable.recoveryKeyActivationIntroMessage
    default:
      return L10n.Localizable.mplessRecoveryIntroMessage
    }
  }
}

struct AccountRecoveryActivationIntroView_Previews: PreviewProvider {
  static var previews: some View {
    AccountRecoveryActivationIntroView(
      authenticationMethod: .masterPassword("_"),
      canSkip: false
    ) { _ in }

    AccountRecoveryActivationIntroView(
      authenticationMethod: .invisibleMasterPassword("_"),
      canSkip: true
    ) { _ in }
  }
}
