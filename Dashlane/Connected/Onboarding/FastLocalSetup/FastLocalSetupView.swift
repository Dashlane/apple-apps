import Combine
import DesignSystem
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct FastLocalSetupView<Model: FastLocalSetupViewModel>: View {
  @Environment(\.layoutDirection) private var layoutDirection

  @ScaledMetric(relativeTo: .callout) private var arrowDimension = 14
  @ScaledMetric private var buttonsArrowSpacing = 6
  @ScaledMetric private var togglesInnerSpacing = 2

  @StateObject
  var model: Model

  @State private var shouldDisplayHowItWorksDescription = false

  @Environment(\.toast) var toast

  init(model: @autoclosure @escaping () -> Model) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    FullScreenScrollView {
      VStack(alignment: .leading, spacing: 0) {
        Text(L10n.Localizable.fastLocalSetupTitle)
          .font(DashlaneFont.custom(24, .medium).font)
          .foregroundColor(.ds.text.neutral.standard)
          .multilineTextAlignment(.leading)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.bottom, 32)

        VStack(alignment: .leading, spacing: 24) {
          if shouldDisplayHowItWorksDescription, case let .biometry(biometry) = model.mode {
            howItWorksDescription(biometry: biometry)
          } else {
            settingsView
          }
        }
        .padding(24)
        .background(.ds.container.agnostic.neutral.supershy)
        .cornerRadius(8)

        Spacer()

        continueButton
      }
      .animation(.easeOut, value: shouldDisplayHowItWorksDescription)
      .padding(.top, 40)
      .padding(.horizontal, 24)
    }
    .reportPageAppearance(.accountCreationUnlockOption)
    .loginAppearance()
    .onReceive(model.biometryNeededPublisher, perform: showBiometryNeededToast)
    .onAppear {
      model.markDisplay()
    }
  }

  @ViewBuilder
  private var settingsView: some View {
    switch model.mode {
    case .biometry(let biometry):
      biometryView(biometry: biometry)
    case .rememberMasterPassword:
      rememberMasterPasswordView
    }
  }

  private func biometryView(biometry: Biometry) -> some View {
    Group {
      DS.Toggle(isOn: $model.isBiometricsOn) {
        VStack(alignment: .leading, spacing: togglesInnerSpacing) {
          Text(biometry.displayableName)
            .font(.system(.body).weight(.semibold))
            .foregroundColor(.ds.text.neutral.standard)

          Text(biometry.localizedDescription)
            .font(.system(.footnote))
            .foregroundColor(.ds.text.neutral.quiet)
        }
      }

      if model.shouldShowMasterPasswordReset {
        DS.Toggle(isOn: $model.isMasterPasswordResetOn) {
          VStack(alignment: .leading, spacing: togglesInnerSpacing) {
            Text(L10n.Localizable.fastLocalSetupMasterPasswordReset)
              .font(.system(.body).weight(.semibold))
              .foregroundColor(.ds.text.neutral.standard)

            Text(L10n.Localizable.fastLocalSetupMasterPasswordResetDescription)
              .font(.system(.footnote))
              .foregroundColor(.ds.text.neutral.quiet)
          }
        }
      }

      Button(action: showHowItWorksDescription) {
        howItWorksButtonLabel
      }
    }
  }

  private var rememberMasterPasswordView: some View {
    DS.Toggle(isOn: $model.isRememberMasterPasswordOn) {
      VStack(alignment: .leading, spacing: togglesInnerSpacing) {
        Text(L10n.Localizable.fastLocalSetupRememberMPTitle)
          .font(.system(.body).weight(.semibold))
          .foregroundColor(.ds.text.neutral.standard)

        Text(L10n.Localizable.fastLocalSetupRememberMPDescription)
          .font(.system(.footnote))
          .foregroundColor(.ds.text.neutral.quiet)
      }
    }
  }

  private var howItWorksButtonLabel: some View {
    Label {
      Text(L10n.Localizable.fastLocalSetupHowItWorksTitle)
        .font(.system(.callout).weight(.semibold))
    } icon: {
      (layoutDirection == .rightToLeft ? Image.ds.arrowLeft.outlined : .ds.arrowRight.outlined)
        .resizable()
        .frame(width: arrowDimension, height: arrowDimension)
    }
    .labelStyle(TrailingIconLabelStyle(spacing: buttonsArrowSpacing))
    .fixedSize(horizontal: false, vertical: true)
  }

  private var backButtonTitle: some View {
    Label {
      Text(L10n.Localizable.fastLocalSetupHowItWorksBack)
        .font(.system(.callout).weight(.semibold))
    } icon: {
      (layoutDirection == .rightToLeft ? Image.ds.arrowRight.outlined : .ds.arrowLeft.outlined)
        .resizable()
        .frame(width: arrowDimension, height: arrowDimension)
    }
    .labelStyle(LeadingIconLabelStyle(spacing: buttonsArrowSpacing))
    .fixedSize()
  }

  private func howItWorksDescription(biometry: Biometry) -> some View {
    Group {
      Button(action: hideHowItWorksDescription) {
        backButtonTitle
      }

      Group {
        Text(
          L10n.Localizable.fastLocalSetupHowItWorksResetAvailableDescription(
            biometry.displayableName))
        Text(L10n.Localizable.fastLocalSetupHowItWorksNote(biometry.displayableName))
      }
      .foregroundColor(.ds.text.neutral.quiet)
    }
  }

  private var continueButton: some View {
    Button(L10n.Localizable.fastLocalSetupContinue, action: model.next)
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.bottom, 35)
  }

  func showHowItWorksDescription() {
    shouldDisplayHowItWorksDescription = true
  }

  func hideHowItWorksDescription() {
    shouldDisplayHowItWorksDescription = false
  }

  private func showBiometryNeededToast() {
    guard let biometry = model.biometry else { return }
    toast(
      L10n.Localizable.fastLocalSetupBiometryRequiredForMasterPasswordReset(
        biometry.displayableName), image: .ds.feedback.info.outlined)
  }
}

extension Biometry {
  fileprivate var localizedDescription: String {
    switch self {
    case .touchId:
      return L10n.Localizable.fastLocalSetupTouchIDDescription
    case .faceId:
      return L10n.Localizable.fastLocalSetupFaceIDDescription
    }
  }
}

struct FastLocalSetupView_Previews: PreviewProvider {

  class FakeModel: FastLocalSetupViewModel {
    var mode: FastLocalSetupMode
    var isBiometricsOn: Bool = true
    var isMasterPasswordResetOn: Bool = true
    var shouldShowMasterPasswordReset: Bool = true
    var shouldShowBackButton: Bool = true
    var biometryNeededPublisher = PassthroughSubject<Void, Never>()
    var biometry: Biometry? = .faceId
    var isRememberMasterPasswordOn: Bool = true

    func next() {}
    func back() {}
    func markDisplay() {}

    init(mode: FastLocalSetupMode = .biometry(.faceId)) {
      self.mode = mode
    }
  }

  static var previews: some View {
    MultiContextPreview(deviceRange: .some([.iPhoneSE, .iPhone11, .iPadPro])) {
      FastLocalSetupView(model: FakeModel())
      FastLocalSetupView(model: FakeModel(mode: .rememberMasterPassword))
    }
  }
}
