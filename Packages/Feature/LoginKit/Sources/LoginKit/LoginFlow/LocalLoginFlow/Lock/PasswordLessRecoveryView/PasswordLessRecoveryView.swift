import CoreLocalization
import CoreSession
import CoreTypes
import DesignSystem
import SwiftUI
import UIComponents

public struct PasswordLessRecoveryView: View {

  @Environment(\.openURL) private var openURL

  enum Flow: String, Identifiable {
    case recovery
    case deviceToDevice

    var id: String {
      return rawValue
    }
  }

  let l10n = CoreL10n.Unlock.PasswordlessRecovery.self

  @StateObject
  var model: PasswordLessRecoveryViewModel

  @State
  var displayedFlow: Flow?

  public init(model: @autoclosure @escaping () -> PasswordLessRecoveryViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 33) {
        if model.recoverFromFailure {
          Image.ds.feedback.fail.outlined
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.ds.text.danger.quiet)
            .frame(width: 62)
        }

        description
      }
      Spacer()
      actions
    }
    .padding(.top, 51)
    .padding(.bottom, 35)
    .padding(.horizontal, 24)
    .loginAppearance()
    .fullScreenCover(item: $displayedFlow) { flow in
      switch flow {
      case .deviceToDevice:
        DeviceTransferQRCodeFlow(
          model: model.makeDeviceToDeviceLoginFlowViewModel(),
          progressState: .constant(.inProgress("")))
      case .recovery:
        NavigationView {
          AccountRecoveryKeyLoginFlow(model: model.makeAccountRecoveryKeyLoginFlowModel())
        }
      }
    }
    .navigationBarBackButtonHidden(true)
  }
  var description: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(l10n.title)
        .textStyle(.title.section.large)

      VStack(alignment: .leading, spacing: 20) {
        Text(l10n.message)
          .textStyle(.body.reduced.regular)
        Text(l10n.alternativeMessage)
          .textStyle(.body.reduced.regular)
      }
    }
  }

  var actions: some View {
    VStack(spacing: 8) {
      Button(CoreL10n.Unlock.PasswordlessRecovery.goToLoginButton) {
        model.logout()
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .catchy)

      Button(CoreL10n.Unlock.PasswordlessRecovery.contactUserSupportButton) {
        openURL(DashlaneURLFactory.cantAccessPasswordlessAccount)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .quiet)
    }

  }
}

struct PasswordLessRecoveryView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordLessRecoveryView(model: .mock(recoverFromFailure: false))
      .previewDisplayName("Regular")
    PasswordLessRecoveryView(model: .mock(recoverFromFailure: true))
      .previewDisplayName("from Failure")
  }
}
