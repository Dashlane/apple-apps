import CoreKeychain
import CoreSession
import DashTypes
import DesignSystem
import LoginKit
import SwiftTreats
import SwiftUI
import UIDelight

struct BiometryUnlockView: View {

  @StateObject
  var model: BiometryUnlockViewModel

  init(model: @autoclosure @escaping () -> BiometryUnlockViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    mainView
      .onAppear {
        if !model.inProgress {
          model.inProgress = true
          Task {
            await model.validate()
          }
        }
      }
      .navigation(isActive: $model.showError) {

        FeedbackView(
          title: L10n.Localizable.biometryUnlockErrorTitle,
          message: L10n.Localizable.biometryUnlockErrorMessage(model.biometryType.displayableName)
            + "\n\n" + L10n.Localizable.biometryUnlockErrorMessage2,
          helpCTA: (
            L10n.Localizable.biometryUnlockErrorCta(model.biometryType.displayableName),
            UserSupportURL.useBiomtryOrPin.url
          ),
          primaryButton: (
            L10n.Localizable.biometryUnlockErrorPinButtonTitle,
            {
              UIApplication.shared.open(.securitySettings)
            }
          ),
          secondaryButton: nil)
      }
  }

  var mainView: some View {
    VStack {
      topView
      Spacer()
      centerView
      Spacer()
      if model.showRetry {
        bottomView
      }
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  var centerView: some View {
    VStack {
      Text(
        model.showRetry
          ? L10n.Localizable.biometryUnlockRetryTitle(model.biometryType.displayableName)
          : L10n.Localizable.biometryUnlockTitle(model.biometryType.displayableName)
      )
      .foregroundColor(.ds.text.neutral.catchy)
      .font(.body)
      Button(
        action: {
          Task {
            await model.validate()
          }
        },
        label: {
          (model.biometryType == .touchId
            ? Image.ds.fingerprint.outlined : Image.ds.faceId.outlined)
            .foregroundColor(.ds.text.neutral.catchy)
        }
      ).disabled(model.inProgress)
    }
  }

  var topView: some View {
    VStack {
      Image(asset: AuthenticatorAsset.logoLockUp)
        .foregroundColor(.ds.text.brand.quiet)
      Text(model.login.email)
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)
    }
  }

  var bottomView: some View {
    VStack(spacing: 8) {
      Button(L10n.Localizable.biometryUnlockErrorRetryButtonTitle) {
        Task {
          await model.validate()
        }
      }

      Button(L10n.Localizable.biometryUnlockRetrySetupPinCta) {
        UIApplication.shared.open(.securitySettings)
      }
      .style(mood: .brand, intensity: .quiet)
    }
    .buttonStyle(.designSystem(.titleOnly))
  }
}

struct BiometryUnlockView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(dynamicTypePreview: true) {
      NavigationView {
        BiometryUnlockView(
          model: BiometryUnlockViewModel(
            login: Login("_"),
            biometryType: .faceId,
            keychainService: .fake,
            validateMasterKey: { _ in throw AccountError.unknown },
            completion: { _ in }))
      }
      NavigationView {
        BiometryUnlockView(
          model: BiometryUnlockViewModel(
            login: Login("_"),
            biometryType: .touchId,
            keychainService: .fake,
            validateMasterKey: { _ in throw AccountError.unknown },
            completion: { _ in }))
      }
    }
  }
}
