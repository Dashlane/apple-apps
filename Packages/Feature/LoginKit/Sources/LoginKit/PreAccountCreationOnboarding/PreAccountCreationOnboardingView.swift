import CoreKeychain
import CoreLocalization
import CoreTypes
import DesignSystem
import LogFoundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct PreAccountCreationOnboardingView: View {
  private var model: PreAccountCreationOnboardingViewModel
  @State
  private var alertContent: AlertContent?

  public init(model: PreAccountCreationOnboardingViewModel) {
    self.model = model
  }

  public var body: some View {
    VStack {
      TabView {
        Group {
          PreAccountCreationOnboardingPage(step: .trust)
          PreAccountCreationOnboardingPage(step: .vault)
          PreAccountCreationOnboardingPage(step: .autofill)
          PreAccountCreationOnboardingPage(step: .privacy)
          PreAccountCreationOnboardingPage(step: .security)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.bottom, 40)
      }
      .frame(maxHeight: .infinity)
      .tabViewStyle(PageTabViewStyle())

      VStack(spacing: 8) {
        Button(CoreL10n.onboardingV3CTACreateAccount, action: model.showAccountCreation)
        Button(CoreL10n.onboardingV3CTALogIn, action: model.showLogin)
          .style(intensity: .supershy)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .toolbar {
      if BuildEnvironment.current != .appstore {
        ToolbarItem(placement: .principal) {
          Button {
            alertContent = analyticsAlert
          } label: {
            Image.ds.feedback.info.outlined
          }
        }
      }
    }
    .loginAppearance()
    .alert(presenting: $alertContent)
    .onAppear {
      guard PreAccountCreationOnboardingViewModel.shouldDeleteLocalData else { return }
      alertContent = localDeletionAlert
    }
    .navigationBarTitleDisplayMode(.inline)
    .reportPageAppearance(.onboardingTrustScreens)
  }

  var analyticsAlert: AlertContent {
    AlertContent(
      title: "Analytics Installation Id",
      message: model.analyticsInstallationId.uuidString,
      buttons: .two(
        primaryButton: .init(
          title: "Copy",
          action: {
            UIPasteboard.general.string = model.analyticsInstallationId.uuidString
          }),
        secondaryButton: .init(title: "Cancel", action: {})
      )
    )
  }

  var localDeletionAlert: AlertContent {
    AlertContent(
      title: CoreL10n.deleteLocalDataAlertTitle,
      message: CoreL10n.deleteLocalDataAlertMessage,
      buttons: .two(
        primaryButton: .init(
          title: CoreL10n.deleteLocalDataAlertDeleteCta,
          action: model.deleteAllLocalData
        ),
        secondaryButton: .init(
          title: CoreL10n.cancel,
          action: model.disableShouldDeleteLocalData
        )
      )
    )
  }
}

struct PreAccountCreationOnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    PreAccountCreationOnboardingView(
      model: .init(
        keychainService: .mock,
        logger: .mock,
        completion: { _ in }
      ))
  }
}
